import 'package:flutter/material.dart';
import 'package:my_project/Doctor/Schdule.dart';
import 'package:my_project/Doctor/Patients.dart';
import 'package:my_project/Doctor/records.dart';
import 'package:my_project/Doctor/Doctordashscreen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../Patientdashboard/services/api_service.dart';

class DoctorAssistantScreen extends StatefulWidget {
  final String doctorId;

  const DoctorAssistantScreen({super.key, required this.doctorId});

  @override
  State<DoctorAssistantScreen> createState() => _DoctorAssistantScreenState();
}

class _DoctorAssistantScreenState extends State<DoctorAssistantScreen> {
  static const Color bgColor = Color(0xFF2C2A2A);
  static const Color cardBg = Color(0xFF3A3838);
  static const Color primary = Color(0xFF0F6E56);
  static const Color borderColor = Color(0xFF4A4848);
  static const Color inputBg = Color(0xFFE8E6E6);

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasMessages = false;
  bool _isListening = false;

  final List<List<Map<String, dynamic>>> _sessionHistory = [];
  final List<Map<String, dynamic>> _messages = [];

  late stt.SpeechToText _speech;
  bool _speechAvailable = false;

  final List<String> _quickSuggestions = [
    'What are the symptoms of diabetes?',
    'Drug interaction between aspirin and warfarin',
    'Best treatment for hypertension stage 2',
    'Interpret HbA1c of 8.5%',
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (e) => debugPrint('Speech error: $e'),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<String> _getAiReply(String message) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/ai-chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );
      final data = jsonDecode(response.body);
      if (data["success"] == true) return data["reply"];
      return "Unable to get response from AI.";
    } catch (e) {
      return "Error connecting to AI: $e";
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }

    setState(() {
      _hasMessages = true;
      _messages.add({
        'type': 'user',
        'text': text.trim(),
        'time': _currentTime(),
      });
    });
    _controller.clear();
    _scrollToBottom();

    _getAiReply(text).then((reply) {
      setState(() {
        _messages.add({
          'type': 'ai',
          'text': reply,
          'time': _currentTime(),
        });
      });
      _scrollToBottom();
    });
  }

  String _currentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : now.hour == 0
            ? 12
            : now.hour;
    final min = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $ampm';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      _sendMessage('[Attached file: ${file.name}]');
    }
  }

  void _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice not available on this device'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_isListening) {
      setState(() => _isListening = false);
      await _speech.stop();
      if (_controller.text.isNotEmpty) {
        _sendMessage(_controller.text);
      }
    } else {
      setState(() => _isListening = true);
      _controller.clear();
      await _speech.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          }
          if (result.finalResult && _isListening) {
            setState(() => _isListening = false);
            if (_controller.text.isNotEmpty) {
              _sendMessage(_controller.text);
            }
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          localeId: 'en_US',
        ),
      );
    }
  }

  void _showChatHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF3A3838),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (__, sc) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Chat history',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const SizedBox(height: 14),
              if (_messages.isEmpty && _sessionHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('No history yet',
                        style: TextStyle(color: Colors.white38)),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    controller: sc,
                    children: [
                      ..._sessionHistory.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final session = entry.value;
                        final firstMsg = session.firstWhere(
                          (m) => m['type'] == 'user',
                          orElse: () => {'text': 'Session ${idx + 1}'},
                        );
                        return _historyItem(
                          Icons.chat_bubble_outline_rounded,
                          firstMsg['text'].toString(),
                          'Session ${idx + 1}',
                        );
                      }),
                      if (_messages.isNotEmpty)
                        _historyItem(
                          Icons.chat_bubble_rounded,
                          _messages
                              .firstWhere((m) => m['type'] == 'user',
                                  orElse: () =>
                                      {'text': 'Current session'})['text']
                              .toString(),
                          'Current session',
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  if (_messages.isNotEmpty) {
                    setState(() {
                      _sessionHistory.add(List.from(_messages));
                      _messages.clear();
                      _hasMessages = false;
                    });
                  }
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFFE24B4A), width: 0.5),
                  ),
                  child: const Center(
                    child: Text('Clear & save current chat',
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFE24B4A),
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _historyItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2A2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: const Color(0xFF1A2A22),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF1D9E75), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.length > 40 ? '${title.substring(0, 40)}...' : title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.white38)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: Colors.white38, size: 18),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavBar(context),
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _hasMessages ? _buildChatArea() : _buildEmptyState(),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cardBg,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: const Icon(Icons.chevron_left_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showChatHistory(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history_rounded,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    'History${_sessionHistory.isNotEmpty ? ' (${_sessionHistory.length})' : ''}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'How can I\nhelp you?',
            style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.2,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF378ADD),
                decorationThickness: 2),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ask health, wellness, nutrition, fitness or medical questions only.',
            style: TextStyle(fontSize: 14, color: Colors.white54),
          ),
          const SizedBox(height: 28),
          ..._quickSuggestions.map(
            (s) => GestureDetector(
              onTap: () => _sendMessage(s),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(s,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.white70)),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white38, size: 12),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg = _messages[i];
        return msg['type'] == 'user'
            ? _buildUserMessage(msg)
            : _buildAiMessage(msg);
      },
    );
  }

  Widget _buildUserMessage(Map<String, dynamic> msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(msg['text'] as String,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.white, height: 1.4)),
              ),
              const SizedBox(height: 4),
              Text(msg['time'] as String,
                  style: const TextStyle(fontSize: 10, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiMessage(Map<String, dynamic> msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration:
                const BoxDecoration(color: primary, shape: BoxShape.circle),
            child: const Center(
              child: Text('AI',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(color: borderColor, width: 0.5),
                ),
                child: Text(msg['text'] as String,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.white, height: 1.5)),
              ),
              const SizedBox(height: 4),
              Text(msg['time'] as String,
                  style: const TextStyle(fontSize: 10, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(fontSize: 14, color: Color(0xFF2C2A2A)),
              decoration: InputDecoration(
                hintText: _isListening ? 'Listening...' : 'Ask Med AI',
                hintStyle: TextStyle(
                    fontSize: 14,
                    color: _isListening ? primary : const Color(0xFF888888)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                  color: Color(0xFFD0CDCD), shape: BoxShape.circle),
              child: const Icon(Icons.attach_file_rounded,
                  color: Color(0xFF555555), size: 18),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _toggleListening,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _isListening
                    ? primary.withOpacity(0.2)
                    : const Color(0xFFD0CDCD),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: _isListening ? primary : const Color(0xFF555555),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _sendMessage(_controller.text),
            child: Container(
              width: 34,
              height: 34,
              decoration:
                  const BoxDecoration(color: primary, shape: BoxShape.circle),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Theme(
      data: ThemeData(
          splashColor: Colors.transparent, highlightColor: Colors.transparent),
      child: BottomNavigationBar(
        onTap: (index) {
          if (index == 4) return;
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => DoctorDashboardScreen(
                        doctorId: widget.doctorId,
                      )),
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => MyScheduleScreen(
                          doctorId: widget.doctorId,
                        )));
          } else if (index == 2) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => MyPatientsScreen(
                          doctorId: widget.doctorId,
                        )));
          } else if (index == 3) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => MyRecordsScreen(
                          doctorId: widget.doctorId,
                        )));
          }
        },
        backgroundColor: const Color(0xFF2C2A2A),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey[500],
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        currentIndex: 4,
        items: const [
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 8),
                  child: Icon(Icons.home_outlined)),
              activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 8),
                  child: Icon(Icons.home)),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 8),
                  child: Icon(Icons.calendar_today_outlined)),
              activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 8),
                  child: Icon(Icons.calendar_today)),
              label: 'Schedule'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 8),
                  child: Icon(Icons.people_outline)),
              activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 8),
                  child: Icon(Icons.people)),
              label: 'Patients'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 8),
                  child: Icon(Icons.folder_open_outlined)),
              activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 8),
                  child: Icon(Icons.folder_open)),
              label: 'Records'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 8),
                  child: Icon(Icons.smart_toy_outlined)),
              activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 8),
                  child: Icon(Icons.smart_toy)),
              label: 'AI'),
        ],
      ),
    );
  }
}
