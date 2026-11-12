import 'package:flutter/material.dart';
import 'package:my_project/Doctor/Doctorprofilescreen.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';
import 'package:my_project/Doctor/AI.dart';
import 'package:my_project/Doctor/Schdule.dart';
import 'package:my_project/Doctor/Patients.dart';
import 'package:my_project/Doctor/records.dart';
import 'package:my_project/Doctor/Patdetails.dart';
import 'package:my_project/Doctor/Prescriptions.dart';
import 'package:my_project/Doctor/doctor_video_call_screen.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_project/Roleselection/RoleSelectionScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorDashboardScreen extends StatefulWidget {
  final String doctorId;

  const DoctorDashboardScreen({
    super.key,
    required this.doctorId,
  });

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  List<dynamic> appointments = [];
  List<dynamic> todayAppointments = [];
  bool appointmentsLoading = true;
  Map<String, dynamic>? doctorData;
  bool _hasNewNotification = false;
  // Track last known appointment count for change detection
  int _lastAppointmentCount = -1;
  // Polling timer
  Timer? _pollingTimer;
  // Reminder timers
  final List<Timer> _reminderTimers = [];
  // Local notifications plugin
  final FlutterLocalNotificationsPlugin _notifPlugin =
      FlutterLocalNotificationsPlugin();

  static const Color bgColor = Color(0xFF181818);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color bluePrimary = Color(0xFF145DA0);
  static const Color textSecondary = Color(0xFFA0A0A0);

  @override
  void initState() {
    super.initState();
    _initNotifications();
    loadDoctorData();
    // Poll for new appointments every 30 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (doctorData != null) {
        await _pollForChanges();
      }
    });
  }

  Future<void> _initNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
        android: androidSettings, iOS: iosSettings);
    await _notifPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  Future<void> _showLocalNotification(
      String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'doctor_channel',
      'Doctor Appointments',
      channelDescription: 'Appointment booking notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
        android: androidDetails, iOS: iosDetails);
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100000;
    await _notifPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Compare against last known state and fire notifications on changes
  Future<void> _pollForChanges() async {
    if (doctorData == null) return;
    final data =
        await ApiService.getDoctorAppointments(doctorData!["full_name"]);
    final now = DateTime.now();

    final todayList = data.where((a) {
      if ((a["booking_status"] ?? "") == "Cancelled") return false;
      return _isSameDay(a["appointment_date"], now);
    }).toList();


    if (_lastAppointmentCount >= 0 &&
        data.length != _lastAppointmentCount) {
      final diff = data.length - _lastAppointmentCount;
      if (diff > 0) {
        await _showLocalNotification(
          '📅 New Appointment Booked',
          'A patient has booked an appointment with you.',
        );
      } else {
        await _showLocalNotification(
          '❌ Appointment Cancelled',
          'A patient has cancelled their appointment.',
        );
      }
      if (mounted) setState(() => _hasNewNotification = true);
    }
    _lastAppointmentCount = data.length;

    // Schedule 10-min reminders for today's appointments
    _scheduleReminders(todayList);

    if (mounted) {
      setState(() {
        appointments = data;
        todayAppointments = todayList;
      });
    }
  }

  void _scheduleReminders(List<dynamic> todayList) {
    // Cancel existing reminder timers
    for (final t in _reminderTimers) {
      t.cancel();
    }
    _reminderTimers.clear();

    final now = DateTime.now();
    for (final appt in todayList) {
      final slotStr = (appt["appointment_slot"] ?? "").toString();
      final dateStr = (appt["appointment_date"] ?? "").toString();
      // Parse time like "10:30 AM"
      final dt = _parseSlotDateTime(dateStr, slotStr);
      if (dt == null) continue;
      final reminderTime = dt.subtract(const Duration(minutes: 10));
      final diff = reminderTime.difference(now);
      if (diff.isNegative) continue; // already passed
      final timer = Timer(diff, () async {
        await _showLocalNotification(
          '⏰ Appointment in 10 minutes',
          '${appt["patient_name"] ?? "A patient"} at $slotStr',
        );
      });
      _reminderTimers.add(timer);
    }
  }

  /// Parse "2024-06-17" + "10:30 AM" → DateTime
  DateTime? _parseSlotDateTime(String date, String slot) {
    try {
      final d = DateTime.parse(date);
      final parts = slot.split(' ');
      if (parts.length < 2) return null;
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final min = int.parse(timeParts[1]);
      final isPm = parts[1].toUpperCase() == 'PM';
      if (isPm && hour != 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      return DateTime(d.year, d.month, d.day, hour, min);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    for (final t in _reminderTimers) {
      t.cancel();
    }
    super.dispose();
  }

  bool _isSameDay(dynamic rawDate, DateTime target) {
    if (rawDate == null) return false;
    final s = rawDate.toString().trim();
    if (s.isEmpty) return false;

    // 1) Match YYYY-MM-DD prefix
    final ymdMatch = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(s);
    if (ymdMatch != null) {
      final y = int.tryParse(ymdMatch.group(1)!);
      final m = int.tryParse(ymdMatch.group(2)!);
      final d = int.tryParse(ymdMatch.group(3)!);
      if (y == target.year && m == target.month && d == target.day) return true;
    }

    // 2) Try standard DateTime parsing (ISO 8601)
    final parsed = DateTime.tryParse(s);
    if (parsed != null) {
      if (parsed.year == target.year &&
          parsed.month == target.month &&
          parsed.day == target.day) {
        return true;
      }
    }

    // 3) Try HTTP/RFC 822 format (e.g. "Wed, 28 Oct 2026 00:00:00 GMT")
    try {
      final httpDate = HttpDate.parse(s);
      if (httpDate.year == target.year &&
          httpDate.month == target.month &&
          httpDate.day == target.day) {
        return true;
      }
    } catch (_) {}

    // 4) Substring match YYYY-MM-DD
    final targetYmd =
        '${target.year}-${target.month.toString().padLeft(2, '0')}-${target.day.toString().padLeft(2, '0')}';
    if (s.contains(targetYmd)) return true;

    return false;
  }

  Future loadAppointments() async {
    if (doctorData == null) return;
    final data =
        await ApiService.getDoctorAppointments(doctorData!["full_name"]);
    final now = DateTime.now();
    setState(() {
      appointments = data;
      // Filter to only TODAY's active appointments
      todayAppointments = data.where((a) {
        if ((a["booking_status"] ?? "") == "Cancelled") return false;
        return _isSameDay(a["appointment_date"], now);
      }).toList();
      appointmentsLoading = false;

      // If any new confirmed appointment was just booked, show dot
      SharedPreferences.getInstance().then((prefs) {
        final lastSeenCount = prefs.getInt("last_seen_doctor_appointments_${widget.doctorId}") ?? 0;
        setState(() {
          _hasNewNotification = todayAppointments.length > lastSeenCount;
        });
      });
      // Set baseline for polling
      if (_lastAppointmentCount < 0) _lastAppointmentCount = data.length;
      // Schedule 10-min reminders for today's slots
      _scheduleReminders(todayAppointments);
    });
  }

  Future loadDoctorData() async {
    final res = await ApiService.getDoctorSummary(widget.doctorId);
    setState(() {
      doctorData = res;
    });
    await loadAppointments();
  }

  int get _pendingCount =>
      todayAppointments.where((a) => a["booking_status"] == "Pending").length;
  int get _doneCount =>
      todayAppointments.where((a) => a["booking_status"] == "Completed").length;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
        );
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => await loadDoctorData(),
            color: bluePrimary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(context),
                  const SizedBox(height: 24),
                  _buildOverviewCard(),
                  const SizedBox(height: 20),
                  _buildInsightsCard(),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Today's patient queue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (todayAppointments.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: bluePrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: bluePrimary.withOpacity(0.5), width: 0.8),
                          ),
                          child: Text(
                            '${todayAppointments.length} today',
                            style: const TextStyle(
                                color: Color(0xFF64B5F6),
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPatientQueue(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DoctorProfileScreen(doctorId: widget.doctorId),
            ),
          ),
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              doctorData?["full_name"]
                      ?.split(" ")
                      .map((e) => e[0])
                      .take(2)
                      .join()
                      .toUpperCase() ??
                  widget.doctorId.substring(0, 2).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctorData?["full_name"] ?? "",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "${doctorData?["specialization"] ?? ""} · ${doctorData?["hospital_name"] ?? ""}",
                style: const TextStyle(color: Color(0xFF64B5F6), fontSize: 13),
              ),
            ],
          ),
        ),
        // Logout Button
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(Icons.logout, color: Colors.white, size: 20),
          ),
        ),
        // Notification Bell
        GestureDetector(
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt("last_seen_doctor_appointments_${widget.doctorId}", todayAppointments.length);
            setState(() => _hasNewNotification = false);
            if (!mounted) return;
            _showNotificationSheet(context);
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white12),
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: Colors.white, size: 20),
              ),
              if (_hasNewNotification)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: bgColor, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
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
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Text('Appointment Notifications',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (todayAppointments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('No appointments today',
                      style: TextStyle(color: Colors.white54)),
                ),
              )
            else
              ...todayAppointments.map((a) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF1A3A2A),
                      child: Icon(Icons.calendar_today,
                          color: Color(0xFF00C48C), size: 18),
                    ),
                    title: Text(
                      a["patient_name"] ?? "Patient",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${a["appointment_slot"] ?? ""} · ${a["booking_status"] ?? ""}',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    final total = todayAppointments.length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bluePrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's overview",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        height: 1),
                  ),
                  const Text('patients',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.1)),
                  const SizedBox(height: 12),
                  if (total > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_pendingCount pending · $_doneCount done',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            MyScheduleScreen(doctorId: widget.doctorId))),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 36),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress bar
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              if (total > 0)
                FractionallySizedBox(
                  widthFactor: _doneCount / total,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1724),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF382A52), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                    color: Color(0xFF2C2244), shape: BoxShape.circle),
                child:
                    const Icon(Icons.star, color: Color(0xFF8A6CF2), size: 16),
              ),
              const SizedBox(width: 12),
              const Text('AI clinical insights',
                  style: TextStyle(
                      color: Color(0xFF8A6CF2),
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2244),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Today',
                    style: TextStyle(
                        color: Color(0xFF8A6CF2),
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightRow(
              color: Colors.redAccent,
              text: "Review any elevated readings in today's patient queue"),
          const SizedBox(height: 12),
          _buildInsightRow(
              color: Colors.orangeAccent,
              text:
                  "${todayAppointments.length} appointment${todayAppointments.length == 1 ? '' : 's'} scheduled for today"),
          const SizedBox(height: 12),
          _buildInsightRow(
              color: const Color(0xFF2E7D32),
              text:
                  "Tap a patient card to view details or write a prescription"),
        ],
      ),
    );
  }

  Widget _buildInsightRow({required Color color, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4)),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color.fromRGBO(20, 93, 160, 0.5)),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Color(0xFF64B5F6), size: 20),
          SizedBox(width: 12),
          Text('Search patient by name...',
              style: TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPatientQueue() {
    if (appointmentsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (todayAppointments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.event_available, color: Colors.white38, size: 40),
              SizedBox(height: 12),
              Text('No appointments today',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: 6),
              Text('Pull to refresh',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ),
      );
    }
    return Column(
      children: todayAppointments.map((appointment) {
        final patientName = appointment["patient_name"] ?? "";
        final slot = appointment["appointment_slot"] ?? "";
        final date = appointment["appointment_date"] ?? "";
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildPatientCard(
            initials: patientName.isNotEmpty
                ? patientName.substring(0, 1).toUpperCase()
                : "?",
            avatarColor: Colors.green.shade900,
            textColor: Colors.greenAccent,
            name: patientName,
            details: "$slot · $date",
            status: appointment["booking_status"] ?? "Booked",
            statusBgColor: Colors.green.shade900,
            statusTextColor: Colors.greenAccent,
            showActions: true,
            appointment: appointment,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPatientCard({
    required String initials,
    required Color avatarColor,
    required Color textColor,
    required String name,
    required String details,
    required String status,
    required Color statusBgColor,
    required Color statusTextColor,
    required bool showActions,
    required Map appointment,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: showActions
              ? const Color.fromRGBO(76, 175, 80, 0.3)
              : Colors.white12,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                    BoxDecoration(color: avatarColor, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(initials,
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(details,
                        style: const TextStyle(
                            color: textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status,
                    style: TextStyle(
                        color: statusTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorVideoCallScreen(
                            callID: appointment["id"].toString(),
                            doctorId: widget.doctorId,
                            doctorName: doctorData?["full_name"] ?? "Doctor",
                            patientName: appointment["patient_name"]?.toString() ?? "Patient",
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.videocam, size: 16),
                      label: const Text("Start"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bluePrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () async {
                        final patientData = await ApiService.getPatientProfile(
                            appointment["patient_email"]);
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PatientDetailsScreen(patient: patientData),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1976D2)),
                        foregroundColor: const Color(0xFF64B5F6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('View',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WritePrescriptionScreen(appointment: appointment),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7E57C2)),
                        foregroundColor: const Color(0xFFB388FF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Write Rx',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Theme(
      data: ThemeData(
          splashColor: Colors.transparent, highlightColor: Colors.transparent),
      child: BottomNavigationBar(
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        MyScheduleScreen(doctorId: widget.doctorId)));
          } else if (index == 2) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        MyPatientsScreen(doctorId: widget.doctorId)));
          } else if (index == 3) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        MyRecordsScreen(doctorId: widget.doctorId)));
          } else if (index == 4) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        DoctorAssistantScreen(doctorId: widget.doctorId)));
          }
        },
        backgroundColor: const Color(0xFF121212),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: Colors.white38,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        currentIndex: 0,
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
              label: 'Schedule'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 8),
                  child: Icon(Icons.person_outline)),
              label: 'Patients'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 8),
                  child: Icon(Icons.receipt_long_outlined)),
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
