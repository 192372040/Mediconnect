import 'dart:io';
import 'package:flutter/material.dart';

import 'package:my_project/Doctor/AI.dart';
import 'package:my_project/Doctor/AddSlotScreen.dart';
import 'package:my_project/Doctor/Doctordashscreen.dart';
import 'package:my_project/Doctor/Patients.dart';
import 'package:my_project/Doctor/records.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';

class MyScheduleScreen extends StatefulWidget {
  final String doctorId;

  const MyScheduleScreen({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<MyScheduleScreen> createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen> {
  static const Color bgColor = Color(0xFF252525);
  static const Color primaryBlue = Color(0xFF1E64B0);
  static const Color cardBgColor = Color(0xFF1E1E1E);
  static const Color successGreen = Color(0xFF00C48C);

  DateTime _selectedDate = DateTime.now();
  List<DateTime> _weekDates = [];
  List<dynamic> _allAppointments = [];
  List<dynamic> _filteredAppointments = [];
  List<Map<String, String>> _addedSlots = []; // locally added slots
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _buildWeekDates();
    _loadData();
  }

  void _buildWeekDates() {
    final now = DateTime.now();
    // Start from 3 days before today to 10 days ahead
    _weekDates = List.generate(14, (i) => now.subtract(Duration(days: 3 - i)));
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final res = await ApiService.getDoctorSummary(widget.doctorId);
    if (res == null) {
      setState(() => _loading = false);
      return;
    }
    final appts =
        await ApiService.getDoctorAppointments(res["full_name"] ?? "");
    setState(() {
      _allAppointments = appts;
      _filterByDate(_selectedDate);
      _loading = false;
    });
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

  void _filterByDate(DateTime date) {
    _filteredAppointments = _allAppointments.where((a) {
      if ((a["booking_status"] ?? "") == "Cancelled") return false;
      return _isSameDay(a["appointment_date"], date);
    }).toList();
  }


  List<Map<String, String>> get _slotsForDate {
    final dateStr = _formatDate(_selectedDate);
    return _addedSlots.where((s) => s["date"] == dateStr).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Divider(color: Colors.grey[800], height: 1),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryBlue))
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: primaryBlue,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        children: [
                          _buildDateStrip(),
                          const SizedBox(height: 12),
                          _buildScrollIndicator(),
                          const SizedBox(height: 24),
                          _buildAppointmentsSection(),
                          const SizedBox(height: 24),
                          _buildAvailableSlotsSection(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 18),
              onPressed: () => Navigator.pop(context),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text('My schedule',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddSlotScreen(doctorId: widget.doctorId)),
              );
              if (result != null && result is Map<String, String>) {
                setState(() {
                  _addedSlots.add(result);
                  // If the added slot is for the currently selected date, refresh view
                  _filterByDate(_selectedDate);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Slot ${result["time"]} on ${result["date"]} added!'),
                    backgroundColor: primaryBlue,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: primaryBlue),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: const Text('+ Add slot',
                  style: TextStyle(
                      color: primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStrip() {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _weekDates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final d = _weekDates[i];
          final isSelected = _formatDate(d) == _formatDate(_selectedDate);
          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          final dayLabel = days[d.weekday - 1];
          return GestureDetector(
            onTap: () => setState(() {
              _selectedDate = d;
              _filterByDate(d);
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              decoration: BoxDecoration(
                color: isSelected ? primaryBlue : cardBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected ? primaryBlue : Colors.grey[800]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dayLabel,
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[500],
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${d.day}',
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[400],
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScrollIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.arrow_left, color: Colors.grey[600]),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.3,
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          Icon(Icons.arrow_right, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayLabel = days[_selectedDate.weekday - 1];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Appointments · $dayLabel ${_selectedDate.day}',
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        if (_filteredAppointments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: const Center(
                child: Text('No appointments on this date',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: _filteredAppointments.map((a) {
                final name = a["patient_name"] ?? "Patient";
                final slot = a["appointment_slot"] ?? "";
                final status = a["booking_status"] ?? "";
                Color badgeColor;
                switch (status) {
                  case "Completed":
                    badgeColor = successGreen;
                    break;
                  case "Confirmed":
                    badgeColor = Colors.blue[300]!;
                    break;
                  default:
                    badgeColor = Colors.orange;
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      border: Border.all(color: badgeColor.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(slot,
                              style: TextStyle(
                                  color: badgeColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Container(
                            width: 1,
                            height: 36,
                            color: Colors.grey[800],
                            margin: const EdgeInsets.only(right: 14)),
                        Expanded(
                          child: Text(name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(status,
                              style: TextStyle(
                                  color: badgeColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildAvailableSlotsSection() {
    final slots = _slotsForDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Available slots',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        if (slots.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('No slots added for this date. Tap "+ Add slot".',
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: slots
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: successGreen.withOpacity(0.6)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(s["time"] ?? "",
                            style: const TextStyle(
                                color: successGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          splashColor: Colors.transparent, highlightColor: Colors.transparent),
      child: BottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        DoctorDashboardScreen(doctorId: widget.doctorId)),
                (r) => false);
          } else if (index == 1) {
            return;
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
        backgroundColor: const Color(0xFF1E1E1E),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        currentIndex: 1,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home_outlined)),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.calendar_today)),
              label: 'Schedule'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person_outline)),
              label: 'Patients'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.description_outlined)),
              label: 'Records'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.smart_toy_outlined)),
              label: 'AI'),
        ],
      ),
    );
  }
}
