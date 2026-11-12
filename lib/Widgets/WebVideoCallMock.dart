import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_project/Patientdashboard/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'platform_view_registry_stub.dart'
    if (dart.library.html) 'platform_view_registry_web.dart';

class WebVideoCallMock extends StatefulWidget {
  final String title;
  final String roomName;
  final String peerName;

  const WebVideoCallMock({
    super.key,
    required this.title,
    required this.roomName,
    required this.peerName,
  });

  @override
  State<WebVideoCallMock> createState() => _WebVideoCallMockState();
}

class _WebVideoCallMockState extends State<WebVideoCallMock> {
  int _secondsElapsed = 0;
  Timer? _timer;
  bool _isMuted = false;
  bool _isVideoOff = false;

  Timer? _statusTimer;
  bool _otherJoined = false;
  String _role = '';

  @override
  void initState() {
    super.initState();
    // Register the platform view factory via conditional import
    registerWebCameraView();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });

    _role = widget.peerName.toLowerCase().contains('doctor') ? 'patient' : 'doctor';
    _joinCall();
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkCallStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _statusTimer?.cancel();
    _leaveCall();
    stopWebCameraVideo();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _joinCall() async {
    try {
      await http.post(
        Uri.parse("${ApiService.baseUrl}/join-call"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"room_name": widget.roomName, "role": _role}),
      );
    } catch (e) {
      print("Error joining call: $e");
    }
  }

  Future<void> _leaveCall() async {
    try {
      await http.post(
        Uri.parse("${ApiService.baseUrl}/leave-call"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"room_name": widget.roomName, "role": _role}),
      );
    } catch (e) {
      print("Error leaving call: $e");
    }
  }

  Future<void> _checkCallStatus() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/call-status/${widget.roomName}"),
      );
      if (response.statusCode == 200) {
        final status = jsonDecode(response.body);
        final bool doctorJoined = status["doctor_joined"] ?? false;
        final bool patientJoined = status["patient_joined"] ?? false;

        if (_role == 'patient' && doctorJoined && !_otherJoined) {
          setState(() {
            _otherJoined = true;
          });
          _showNotification('Doctor has joined the call!');
        } else if (_role == 'doctor' && patientJoined && !_otherJoined) {
          setState(() {
            _otherJoined = true;
          });
          _showNotification('Patient is ready / has joined the call!');
        }
      }
    } catch (e) {
      print("Error checking call status: $e");
    }
  }

  void _showNotification(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.videocam_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1D9E75),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            // Remote Video / Avatar background
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1E3A2F),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1D9E75).withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.peerName.isNotEmpty ? widget.peerName[0].toUpperCase() : 'P',
                        style: const TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D9E75),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.peerName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1D9E75),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Connected • ${_formatDuration(_secondsElapsed)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Top Status Bar / Header
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_rounded, size: 14, color: Color(0xFF1D9E75)),
                        const SizedBox(width: 6),
                        Text(
                          'Room: ${widget.roomName}',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Local Video Preview (Bottom Right Overlay)
            Positioned(
              bottom: 120,
              right: 20,
              child: Container(
                width: 110,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      if (kIsWeb && !_isVideoOff)
                        const HtmlElementView(viewType: 'camera-view-element')
                      else if (!_isVideoOff)
                        Container(
                          color: const Color(0xFF1B2A23),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person, color: Color(0xFF1D9E75), size: 36),
                                SizedBox(height: 4),
                                Text('Live', style: TextStyle(color: Color(0xFF1D9E75), fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          color: Colors.black,
                          child: const Center(
                            child: Icon(Icons.videocam_off_rounded, color: Colors.white38, size: 24),
                          ),
                        ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Text(
                          'You',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Actions Control Panel
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mute Button
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isMuted = !_isMuted;
                          });
                        },
                        icon: Icon(
                          _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                          color: _isMuted ? Colors.red : Colors.white,
                        ),
                        iconSize: 24,
                      ),
                      const SizedBox(width: 20),

                      // End Call Button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.redAccent,
                          ),
                          child: const Icon(
                            Icons.call_end_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Video Toggle Button
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isVideoOff = !_isVideoOff;
                            if (_isVideoOff) {
                              stopWebCameraVideo();
                            } else {
                              registerWebCameraView();
                            }
                          });
                        },
                        icon: Icon(
                          _isVideoOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                          color: _isVideoOff ? Colors.red : Colors.white,
                        ),
                        iconSize: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
