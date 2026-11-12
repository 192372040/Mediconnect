import 'package:flutter/material.dart';
import 'package:my_project/Patientdashboard/AppointmentsScreen.dart';
import 'package:my_project/Patientdashboard/health/HealthScreen.dart';
import 'package:my_project/Patientdashboard/reports/Myreports.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_project/Patientdashboard/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  final Map user;

  const NotificationsScreen({super.key, required this.user});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color primary = Color(0xFF0F6E56);
  static const Color primaryBg = Color(0xFF2C2A2A);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color borderColor = Color(0xFF3A3A3A);

  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Appointments',
    'Medicine',
  ];

  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  bool _enablePrescriptionReminders = true;
 
  @override
  void initState() {
    super.initState();
    _loadSettingsAndNotifications();
  }

  Future<void> _loadSettingsAndNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enablePrescriptionReminders = prefs.getBool('enable_prescription_reminders') ?? true;
    });
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final email = widget.user['email']?.toString() ?? '';
    if (email.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. Fetch appointments
      final apptResponse = await http.get(
        Uri.parse("${ApiService.baseUrl}/get-patient-appointments?patient_email=$email")
      );
      final apptData = jsonDecode(apptResponse.body);
      List<dynamic> appts = [];
      if (apptData["success"] == true) {
        appts = apptData["appointments"] ?? [];
      }

      // 2. Fetch prescriptions
      final prescResponse = await http.get(
        Uri.parse("${ApiService.baseUrl}/get-patient-prescriptions?email=$email")
      );
      final List<dynamic> prescs = jsonDecode(prescResponse.body) ?? [];

      final List<Map<String, dynamic>> loadedList = [];
      int index = 1;

      // Add appointment reminders
      for (var appt in appts) {
        final status = appt["booking_status"]?.toString();
        if (status == "Confirmed" || status == "Pending") {
          loadedList.add({
            'id': index++,
            'title': 'Appointment reminder',
            'body': 'Dr. ${appt["doctor_name"]} on ${appt["appointment_date"]} at ${appt["appointment_slot"]}. ${appt["hospital_name"]}.',
            'time': 'Just now',
            'date': 'today',
            'category': 'Appointments',
            'icon': Icons.calendar_today_rounded,
            'iconColor': const Color(0xFF185FA5),
            'iconBg': const Color(0xFF1A2A3A),
            'action': 'View appointment',
            'unread': true,
          });
        }
      }

      // Add medicine reminders based on prescriptions
      if (_enablePrescriptionReminders) {
        for (var presc in prescs) {
          final medicinesStr = presc["medicines"]?.toString() ?? '';
          final doctorName = presc["doctor_name"]?.toString() ?? 'doctor';
          if (medicinesStr.isNotEmpty) {
            final medList = medicinesStr.split(RegExp(r'[,\n]')).map((m) => m.trim()).where((m) => m.isNotEmpty).toList();
            for (var med in medList) {
              loadedList.add({
                'id': index++,
                'title': 'Medicine reminder',
                'body': 'Time to take $med. As prescribed by Dr. $doctorName.',
                'time': 'Scheduled',
                'date': 'today',
                'category': 'Medicine',
                'icon': Icons.medication_rounded,
                'iconColor': const Color(0xFF1D9E75),
                'iconBg': const Color(0xFF1A2A22),
                'action': 'Mark as taken',
                'unread': true,
              });
            }
          }
        }
      }

      setState(() {
        _notifications = loadedList;
        _isLoading = false;
      });
    } catch (e) {
      print("ERROR LOADING NOTIFICATIONS: $e");
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 'All') return _notifications;
    return _notifications
        .where((n) => n['category'] == _selectedFilter)
        .toList();
  }

  List<Map<String, dynamic>> get _todayNotifs =>
      _filtered.where((n) => n['date'] == 'today').toList();

  List<Map<String, dynamic>> get _yesterdayNotifs =>
      _filtered.where((n) => n['date'] == 'yesterday').toList();

  int get _unreadCount =>
      _notifications.where((n) => n['unread'] == true).length;

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n['unread'] = false;
      }
    });
  }

  void _markRead(int id) {
    setState(() {
      final notif = _notifications.firstWhere((n) => n['id'] == id);
      notif['unread'] = false;
    });
  }

  void _dismissNotification(int id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilters(),
            _buildPrescriptionToggle(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: primary))
                  : _filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                          children: [
                            if (_todayNotifs.isNotEmpty) ...[
                              _dateLabel('TODAY'),
                              ..._todayNotifs
                                  .map((n) => _buildNotifCard(n, context)),
                            ],
                            if (_yesterdayNotifs.isNotEmpty) ...[
                              _dateLabel('YESTERDAY'),
                              ..._yesterdayNotifs
                                  .map((n) => _buildNotifCard(n, context)),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: primaryBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1),
              ),
              child: const Icon(Icons.chevron_left_rounded,
                  color: primary, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Notifications',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
          if (_unreadCount > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$_unreadCount new',
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 10),
          ],
          GestureDetector(
            onTap: _markAllRead,
            child: const Text('Mark all read',
                style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF1D9E75),
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // ── Filters ───────────────────────────────
  Widget _buildFilters() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final sel = _selectedFilter == _filters[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = _filters[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: sel ? primary : cardBg,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: sel ? primary : borderColor, width: 0.5),
              ),
              child: Text(_filters[i],
                  style: TextStyle(
                    fontSize: 12,
                    color: sel ? Colors.white : Colors.white54,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                  )),
            ),
          );
        },
      ),
    );
  }

  // ── Date label ────────────────────────────
  Widget _dateLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10,
              color: Colors.white38,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w500)),
    );
  }

  // ── Notification card ─────────────────────
  Widget _buildNotifCard(Map<String, dynamic> notif, BuildContext context) {
    final isUnread = notif['unread'] as bool;
    final notifId = notif['id'] as int;
    return GestureDetector(
      onTap: () {
        _markRead(notifId);
        _handleAction(notif['action'] as String?, context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFF1A1E1D) : cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread ? primary.withValues(alpha: 0.4) : borderColor,
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: notif['iconBg'] as Color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(notif['icon'] as IconData,
                  color: notif['iconColor'] as Color, size: 17),
            ),
            const SizedBox(width: 10),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif['title'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: notif['title'] == 'Missed dose!'
                            ? const Color(0xFFE24B4A)
                            : Colors.white,
                      )),
                  const SizedBox(height: 3),
                  Text(notif['body'] as String,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white60, height: 1.4)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (notif['action'] != null) ...[
                        GestureDetector(
                          onTap: () =>
                              _handleAction(notif['action'] as String, context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A2A22),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: primary, width: 0.5),
                            ),
                            child: Text(notif['action'] as String,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF1D9E75),
                                  fontWeight: FontWeight.w500,
                                )),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Cancel button
                      GestureDetector(
                        onTap: () => _dismissNotification(notifId),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A1A1A),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.5), width: 0.5),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFE24B4A),
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(notif['time'] as String,
                          style: const TextStyle(
                              fontSize: 9, color: Colors.white38)),
                    ],
                  ),
                ],
              ),
            ),

            // Unread dot — only shows when unread
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration:
                    const BoxDecoration(color: primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  // ── Handle action ─────────────────────────
  void _handleAction(String? action, BuildContext context) {
    if (action == null) return;
    switch (action) {
      case 'View appointment':
        final patientEmail = widget.user["email"]?.toString() ?? '';
        if (patientEmail.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient email is missing.')),
          );
          return;
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AppointmentsScreen(
                      patientEmail: patientEmail,
                    )));
        break;
      case 'View health':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const HealthScreen()));
        break;
      case 'View report':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MyReportsScreen(
                      user: {},
                    )));
        break;
      case 'Mark as taken':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Medicine marked as taken!'),
            backgroundColor: primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        break;
      case 'Book now':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Redirecting to booking...'),
            backgroundColor: primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        break;
      case 'Order refill':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Refill order placed!'),
            backgroundColor: primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        break;
    }
  }

  // ── Empty state ───────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: cardBg,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: const Icon(Icons.notifications_off_rounded,
                color: Colors.white38, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No notifications',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 6),
          const Text('You are all caught up!',
              style: TextStyle(fontSize: 13, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildPrescriptionToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, color: Color(0xFF1D9E75), size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prescription Reminders',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _enablePrescriptionReminders ? 'Enabled' : 'Disabled',
                    style: const TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _enablePrescriptionReminders,
            activeColor: primary,
            activeTrackColor: primary.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.white10,
            onChanged: (val) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('enable_prescription_reminders', val);
              setState(() {
                _enablePrescriptionReminders = val;
                _isLoading = true;
              });
              _loadNotifications();
            },
          ),
        ],
      ),
    );
  }
}
