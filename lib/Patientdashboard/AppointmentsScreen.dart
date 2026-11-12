import 'package:flutter/material.dart';
import 'package:my_project/patientdashboard/HospitalSearchScreen.dart';
import 'package:my_project/Patientdashboard/video_call_screen.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';

class AppointmentsScreen extends StatefulWidget {
  final String patientEmail;

  const AppointmentsScreen({
    super.key,
    required this.patientEmail,
  });

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  static Color primary = Color(0xFF0F6E56);
  static Color primaryBg = Color(0xFF2C2A2A);
  static Color cardBg = Color(0xFF1A1A1A);
  static Color borderColor = Color(0xFF3A3A3A);
  static Color textColor = Colors.white;
  static Color textMutedColor = Color(0xFF8F9CA8);
  static Color textDimColor = Color(0xFFB0B0B0);
  static Color white24Color = Colors.white24;

  static Color danger = Color(0xFFE24B4A);
  List<dynamic> appointments = [];
  bool isLoading = true;
  int _selectedTab = 0;
  final List<String> _tabs = ['Upcoming', 'Completed', 'Cancelled'];

  String getInitials(String doctorName) {
    if (doctorName.isEmpty) return "DR";
    String cleanName =
        doctorName.replaceAll("Dr. ", "").replaceAll("Dr.", "").trim();
    List<String> parts = cleanName.split(" ");
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Color getDoctorColor(String name) {
    final colors = [
      Color(0xFF185FA5),
      Color(0xFF1D9E75),
      Color(0xFFBA7517),
      Color(0xFF7F77DD),
    ];
    int hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }

  Color getDoctorBgColor(Color color) {
    if (color.toARGB32() == 0xFF185FA5) return Color(0xFF1A2A3A);
    if (color.toARGB32() == 0xFF1D9E75) return Color(0xFF1A2A22);
    if (color.toARGB32() == 0xFFBA7517) return Color(0xFF2A2215);
    return Color(0xFF1E1A2E);
  }

  String _formatApptDate(dynamic rawDate) {
    if (rawDate == null) return '';
    String str = rawDate.toString().trim();
    if (str.isEmpty) return '';
    try {
      if (str.contains(" 00:00:00")) {
        str = str.replaceAll(" 00:00:00 GMT", "").replaceAll(" 00:00:00", "").trim();
      }
      str = str.replaceAll(" GMT", "").trim();
      DateTime? dt = DateTime.tryParse(str);
      if (dt != null) {
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return "${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}";
      }
      return str;
    } catch (_) {
      return str;
    }
  }

  bool checkIfToday(dynamic dateVal) {
    if (dateVal == null) return false;
    String dateStr = dateVal.toString().toLowerCase();
    if (dateStr == "today") return true;

    DateTime now = DateTime.now();
    String ymd =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    if (dateStr.contains(ymd)) return true;

    String dmy = "${now.day}-${now.month}-${now.year}";
    if (dateStr == dmy) return true;

    final months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec'
    ];
    final fullMonths = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december'
    ];
    String mShort = months[now.month - 1];
    String mFull = fullMonths[now.month - 1];
    String dayStr = "${now.day}";

    if (dateStr.contains(dayStr) &&
        (dateStr.contains(mShort) || dateStr.contains(mFull))) {
      return true;
    }
    return false;
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 64, color: white24Color),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: textMutedColor),
          ),
        ],
      ),
    );
  }

  Future<void> fetchAppointments() async {
    try {
      final res = await ApiService.getPatientAppointments(widget.patientEmail);
      setState(() {
        appointments = res;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabs(),
            Expanded(
              child: _selectedTab == 0
                  ? _buildUpcomingList()
                  : _selectedTab == 1
                      ? _buildCompletedList()
                      : _buildCancelledList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                color: textColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Icon(Icons.chevron_left_rounded, color: primary, size: 22),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text('My appointments',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HospitalSearchScreen()),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF1A2A22),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primary, width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: primary, size: 14),
                  SizedBox(width: 4),
                  Text('Book',
                      style: TextStyle(
                          fontSize: 11,
                          color: primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tabs ──────────────────────────────────
  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final sel = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: sel ? Colors.white : Colors.white54,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                    )),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUpcomingList() {
    final upcomingList = appointments.where((appt) {
      final status = appt['booking_status']?.toString();
      return status == 'Confirmed' || status == 'Pending';
    }).toList();

    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: primary));
    }

    if (upcomingList.isEmpty) {
      return _buildEmptyState('No upcoming appointments');
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 30),
      itemCount: upcomingList.length,
      itemBuilder: (_, i) {
        final appt = upcomingList[i];
        final doctorName = appt['doctor_name'] ?? 'Doctor';
        final doctorColor = getDoctorColor(doctorName);
        final dateVal = appt['appointment_date'] ?? '';
        final isToday = checkIfToday(dateVal);

        final uiAppt = {
          'id': appt['id'],
          'doctor': doctorName,
          'specialization': appt['specialization'] ?? '',
          'hospital': appt['hospital_name'] ?? '',
          'date': _formatApptDate(dateVal),
          'raw_date': dateVal,
          'time': appt['appointment_slot'] ?? '',
          'type': appt['type'] ?? 'Video call',
          'initials': getInitials(doctorName),
          'color': doctorColor,
          'bg': getDoctorBgColor(doctorColor),
          'isToday': isToday,
          'fee': appt['consultation_fee'] ?? '₹500',
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (i == 0 && isToday) _sectionLabel('TODAY'),
            if (i == 0 && !isToday) _sectionLabel('UPCOMING'),
            if (i > 0) ...[
              if (isToday &&
                  !checkIfToday(upcomingList[i - 1]['appointment_date']))
                _sectionLabel('TODAY')
              else if (!isToday &&
                  checkIfToday(upcomingList[i - 1]['appointment_date']))
                _sectionLabel('UPCOMING')
            ],
            _buildUpcomingCard(uiAppt, isToday),
            SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              color: textMutedColor,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildUpcomingCard(Map<String, dynamic> appt, bool isToday) {
    return GestureDetector(
      onTap: () => _showAppointmentDetail(appt, isToday),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isToday ? primary : borderColor,
            width: isToday ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          children: [
            // Doctor info
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: appt['bg'] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(appt['initials'] as String,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: appt['color'] as Color)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appt['doctor'] as String,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor)),
                      SizedBox(height: 2),
                      Text(appt['specialization'] as String,
                          style: TextStyle(fontSize: 11, color: textDimColor)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isToday ? Color(0xFF1A2A22) : Color(0xFF1E1A2E),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(appt['date'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isToday ? Color(0xFF1D9E75) : Color(0xFF7F77DD),
                      )),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Time + hospital + type
            // Time + hospital + type
            Row(
              children: [
                _infoChip(Icons.access_time_rounded, appt['time'] as String),
                SizedBox(width: 8),
                _infoChip(
                    Icons.location_on_rounded, appt['hospital'] as String),
                Spacer(),
                // ── Change mode button ──────────
                GestureDetector(
                  onTap: () => _showChangeModeDialog(appt),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: appt['type'] == 'Video call'
                          ? Color(0xFF1A2A3A)
                          : Color(0xFF1A2A22),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: appt['type'] == 'Video call'
                            ? Color(0xFF185FA5)
                            : primary,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          appt['type'] == 'Video call'
                              ? Icons.videocam_rounded
                              : Icons.person_rounded,
                          size: 12,
                          color: appt['type'] == 'Video call'
                              ? Color(0xFF378ADD)
                              : primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          appt['type'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: appt['type'] == 'Video call'
                                ? Color(0xFF378ADD)
                                : primary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 12,
                          color: appt['type'] == 'Video call'
                              ? Color(0xFF378ADD)
                              : primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Action buttons
            if (isToday)
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _actionBtn(
                      label: 'Join video call',
                      icon: Icons.videocam_rounded,
                      bgColor: primary,
                      textColor: Colors.white,
                      onTap: () => _showWaitingRoom(appt),
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: _actionBtn(
                      label: 'Chat',
                      icon: Icons.chat_rounded,
                      bgColor: Color(0xFF1A2A3A),
                      textColor: Color(0xFF378ADD),
                      borderColor: Color(0xFF185FA5),
                      onTap: () => _openChat(appt),
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: _actionBtn(
                      label: appt['doctor_rating'] != null ? 'Rated (${appt['doctor_rating']}★)' : 'Rate',
                      icon: Icons.star_rounded,
                      bgColor: Color(0xFF2A2A1B),
                      textColor: Color(0xFFFFC107),
                      borderColor: Color(0xFFFFC107),
                      onTap: () => _showRatingDialog(appt),
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: _actionBtn(
                      label: 'Cancel',
                      icon: Icons.close_rounded,
                      bgColor: Color(0xFF2A1A1A),
                      textColor: danger,
                      borderColor: danger,
                      onTap: () => _showCancelDialog(appt),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _actionBtn(
                      label: 'Chat',
                      icon: Icons.chat_rounded,
                      bgColor: Color(0xFF1A2A3A),
                      textColor: Color(0xFF378ADD),
                      borderColor: Color(0xFF185FA5),
                      onTap: () => _openChat(appt),
                    ),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: _actionBtn(
                      label: 'Reschedule',
                      icon: Icons.schedule_rounded,
                      bgColor: Color(0xFF2A2215),
                      textColor: Color(0xFFBA7517),
                      borderColor: Color(0xFFBA7517),
                      onTap: () => _showRescheduleSheet(appt),
                    ),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: _actionBtn(
                      label: appt['doctor_rating'] != null ? 'Rated (${appt['doctor_rating']}★)' : 'Rate',
                      icon: Icons.star_rounded,
                      bgColor: Color(0xFF2A2A1B),
                      textColor: Color(0xFFFFC107),
                      borderColor: Color(0xFFFFC107),
                      onTap: () => _showRatingDialog(appt),
                    ),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: _actionBtn(
                      label: 'Cancel',
                      icon: Icons.close_rounded,
                      bgColor: Color(0xFF2A1A1A),
                      textColor: danger,
                      borderColor: danger,
                      onTap: () => _showCancelDialog(appt),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ── Completed list ────────────────────────
  Widget _buildCompletedCard(Map<String, dynamic> appt) {
    return GestureDetector(
      onTap: () => _showCompletedDetail(appt),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Column(
          children: [
            // ── Doctor info ─────────────────
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: appt['bg'] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(appt['initials'] as String,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: appt['color'] as Color)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appt['doctor'] as String,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor)),
                      SizedBox(height: 2),
                      Text('${appt['specialization']} · ${appt['hospital']}',
                          style: TextStyle(fontSize: 11, color: textDimColor)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A2A22),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: primary, width: 0.5),
                  ),
                  child: Text('Done',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: primary)),
                ),
              ],
            ),
            SizedBox(height: 8),

            // ── Date time ───────────────────
            Row(
              children: [
                _infoChip(Icons.calendar_today_rounded,
                    '${appt['date']} · ${appt['time']}'),
              ],
            ),
            SizedBox(height: 10),

            // ── Row 1 — View Rx + Book again ─
            Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    label: 'View Rx',
                    icon: Icons.description_rounded,
                    bgColor: Color(0xFF1A2A3A),
                    textColor: Color(0xFF378ADD),
                    borderColor: Color(0xFF185FA5),
                    onTap: () {},
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _actionBtn(
                    label: 'Book again',
                    icon: Icons.refresh_rounded,
                    bgColor: Color(0xFF1A2A22),
                    textColor: primary,
                    borderColor: primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HospitalSearchScreen()),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // ── Row 2 — Rate + Follow-up ────
            Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    label: appt['rated'] == true ? 'Rated ★' : 'Rate',
                    icon: Icons.star_rounded,
                    bgColor: Color(0xFF2A2215),
                    textColor: Color(0xFFBA7517),
                    borderColor: Color(0xFFBA7517),
                    onTap: () =>
                        appt['rated'] == false ? _showRatingDialog(appt) : null,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _actionBtn(
                    label: 'Follow-up',
                    icon: Icons.medical_services_rounded,
                    bgColor: Color(0xFF1A2A22),
                    textColor: Color(0xFF0F6E56),
                    borderColor: Color(0xFF0F6E56),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HospitalSearchScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedList() {
    final completedList = appointments.where((appt) {
      final status = appt['booking_status']?.toString();
      return status == 'Completed';
    }).toList();

    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: primary));
    }

    if (completedList.isEmpty) {
      return _buildEmptyState('No completed appointments');
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 30),
      itemCount: completedList.length,
      separatorBuilder: (_, __) => SizedBox(height: 10),
      itemBuilder: (_, i) {
        final appt = completedList[i];
        final doctorName = appt['doctor_name'] ?? 'Doctor';
        final doctorColor = getDoctorColor(doctorName);
        final uiAppt = {
          'id': appt['id'],
          'doctor': doctorName,
          'specialization': appt['specialization'] ?? '',
          'hospital': appt['hospital_name'] ?? '',
          'date': _formatApptDate(appt['appointment_date'] ?? ''),
          'raw_date': appt['appointment_date'] ?? '',
          'time': appt['appointment_slot'] ?? '',
          'initials': getInitials(doctorName),
          'color': doctorColor,
          'bg': getDoctorBgColor(doctorColor),
          'rated': appt['rated'] == 1 || appt['rated'] == true,
          'fee': appt['consultation_fee'] ?? '₹500',
        };
        return _buildCompletedCard(uiAppt);
      },
    );
  }

  // ── Cancelled list ────────────────────────
  Widget _buildCancelledList() {
    final cancelledList = appointments.where((appt) {
      final status = appt['booking_status']?.toString();
      return status == 'Cancelled';
    }).toList();

    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: primary));
    }

    if (cancelledList.isEmpty) {
      return _buildEmptyState('No cancelled appointments');
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 30),
      itemCount: cancelledList.length,
      separatorBuilder: (_, __) => SizedBox(height: 10),
      itemBuilder: (_, i) {
        final appt = cancelledList[i];
        final doctorName = appt['doctor_name'] ?? 'Doctor';
        final doctorColor = getDoctorColor(doctorName);
        final uiAppt = {
          'id': appt['id'],
          'doctor': doctorName,
          'specialization': appt['specialization'] ?? '',
          'hospital': appt['hospital_name'] ?? '',
          'date': _formatApptDate(appt['appointment_date'] ?? ''),
          'raw_date': appt['appointment_date'] ?? '',
          'time': appt['appointment_slot'] ?? '',
          'initials': getInitials(doctorName),
          'color': doctorColor,
          'bg': getDoctorBgColor(doctorColor),
          'cancelledBy': appt['cancelled_by'] ?? 'you',
          'cancelDate': appt['cancel_date'] ?? 'Recently',
        };
        return _buildCancelledCard(uiAppt);
      },
    );
  }

  Widget _buildCancelledCard(Map<String, dynamic> appt) {
    return Opacity(
      opacity: 0.85,
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: appt['bg'] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(appt['initials'] as String,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: appt['color'] as Color)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appt['doctor'] as String,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor)),
                      SizedBox(height: 2),
                      Text('${appt['specialization']} · ${appt['hospital']}',
                          style: TextStyle(fontSize: 11, color: textDimColor)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF2A1A1A),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: danger, width: 0.5),
                  ),
                  child: Text('Cancelled',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: danger)),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                _infoChip(Icons.calendar_today_rounded,
                    '${appt['date']} · ${appt['time']}'),
              ],
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF2A1A1A),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                  'Cancelled by ${appt['cancelledBy']} · ${appt['cancelDate']}',
                  style: TextStyle(fontSize: 11, color: danger)),
            ),
            SizedBox(height: 10),
            _actionBtn(
              label: 'Book again',
              icon: Icons.refresh_rounded,
              bgColor: Color(0xFF1A2A22),
              textColor: primary,
              borderColor: primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HospitalSearchScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper widgets ────────────────────────
  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: textMutedColor),
        SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 10, color: textDimColor)),
      ],
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: borderColor ?? Colors.transparent, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 11),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppointmentDetail(Map<String, dynamic> appt, bool isToday) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: white24Color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Doctor info
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: appt['bg'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(appt['initials'] as String,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: appt['color'] as Color)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appt['doctor'] as String,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                        Text(appt['specialization'] as String,
                            style:
                                TextStyle(fontSize: 12, color: textDimColor)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isToday ? Color(0xFF1A2A22) : Color(0xFF1E1A2E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(appt['date'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color:
                              isToday ? Color(0xFF1D9E75) : Color(0xFF7F77DD),
                        )),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Info rows
              _detailInfoCard(appt),
              SizedBox(height: 16),

              // Mode switcher
              _detailModeRow(appt),
              SizedBox(height: 16),

              // Buttons
              if (isToday && appt['type'] == 'Video call') ...[
                _detailBtn(
                  icon: Icons.videocam_rounded,
                  label: 'Join video call',
                  bgColor: Color(0xFF0F6E56),
                  textColor: Colors.white,
                  onTap: () {
                    Navigator.pop(context);
                    _showWaitingRoom(appt);
                  },
                ),
                SizedBox(height: 10),
              ],

              _detailBtn(
                icon: Icons.schedule_rounded,
                label: 'Reschedule appointment',
                bgColor: Color(0xFF2A2215),
                textColor: Color(0xFFBA7517),
                borderColor: Color(0xFFBA7517),
                onTap: () {
                  Navigator.pop(context);
                  _showRescheduleSheet(appt);
                },
              ),
              SizedBox(height: 10),

              _detailBtn(
                icon: Icons.receipt_rounded,
                label: 'View invoice',
                bgColor: Color(0xFF2A2215),
                textColor: Color(0xFFBA7517),
                borderColor: Color(0xFFBA7517),
                onTap: () {
                  Navigator.pop(context);
                  _showInvoiceSheet(appt);
                },
              ),
              SizedBox(height: 10),

              _detailBtn(
                icon: Icons.cancel_rounded,
                label: 'Cancel appointment',
                bgColor: Color(0xFF2A1A1A),
                textColor: Color(0xFFE24B4A),
                borderColor: Color(0xFFE24B4A),
                onTap: () {
                  Navigator.pop(context);
                  _showCancelDialog(appt);
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailInfoCard(Map<String, dynamic> appt) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2C2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF3A3A3A), width: 0.5),
      ),
      child: Column(
        children: [
          _detailRow(Icons.local_hospital_rounded, 'Hospital',
              appt['hospital'] as String),
          _dividerLine(),
          _detailRow(
              Icons.calendar_today_rounded, 'Date', appt['date'] as String),
          _dividerLine(),
          _detailRow(Icons.access_time_rounded, 'Time', appt['time'] as String),
          _dividerLine(),
          _detailRow(Icons.payments_rounded, 'Amount paid', '₹500',
              valueColor: Color(0xFF1D9E75)),
          _dividerLine(),
          _detailRow(Icons.confirmation_number_rounded, 'Booking ID',
              '#MED2026032001'),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Icon(icon, color: textMutedColor, size: 15),
          SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 12, color: textDimColor)),
          Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.white)),
        ],
      ),
    );
  }

  Widget _dividerLine() => Container(
      height: 0.5,
      color: Color(0xFF3A3A3A),
      margin: EdgeInsets.symmetric(horizontal: 14));

  Widget _detailModeRow(Map<String, dynamic> appt) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => appt['type'] = 'In-person'),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appt['type'] == 'In-person'
                    ? Color(0xFF1A2A22)
                    : Color(0xFF2C2A2A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: appt['type'] == 'In-person'
                      ? Color(0xFF0F6E56)
                      : Color(0xFF3A3A3A),
                  width: appt['type'] == 'In-person' ? 1.5 : 0.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.person_rounded,
                      color: appt['type'] == 'In-person'
                          ? Color(0xFF0F6E56)
                          : Colors.white38,
                      size: 22),
                  SizedBox(height: 4),
                  Text('In-person',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: appt['type'] == 'In-person'
                              ? Color(0xFF0F6E56)
                              : Colors.white54)),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => appt['type'] = 'Video call'),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appt['type'] == 'Video call'
                    ? Color(0xFF1A2A3A)
                    : Color(0xFF2C2A2A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: appt['type'] == 'Video call'
                      ? Color(0xFF185FA5)
                      : Color(0xFF3A3A3A),
                  width: appt['type'] == 'Video call' ? 1.5 : 0.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.videocam_rounded,
                      color: appt['type'] == 'Video call'
                          ? Color(0xFF185FA5)
                          : Colors.white38,
                      size: 22),
                  SizedBox(height: 4),
                  Text('Online',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: appt['type'] == 'Video call'
                              ? Color(0xFF185FA5)
                              : Colors.white54)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailBtn({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: borderColor ?? Colors.transparent, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 16),
            SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: textColor,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showChangeModeDialog(Map<String, dynamic> appt) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: white24Color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16),

            Text('Change appointment mode',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
            SizedBox(height: 6),
            Text(
                'You can switch between in-person and online anytime before your appointment.',
                style:
                    TextStyle(fontSize: 12, color: textDimColor, height: 1.5)),
            SizedBox(height: 20),

            // In-person option
            GestureDetector(
              onTap: () {
                setState(() => appt['type'] = 'In-person');
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(14),
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: appt['type'] == 'In-person'
                      ? Color(0xFF1A2A22)
                      : Color(0xFF2C2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: appt['type'] == 'In-person'
                        ? primary
                        : Color(0xFF3A3A3A),
                    width: appt['type'] == 'In-person' ? 1.5 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFF1A2A22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          Icon(Icons.person_rounded, color: primary, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('In-person visit',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textColor)),
                          SizedBox(height: 2),
                          Text('Visit the hospital on appointment day',
                              style:
                                  TextStyle(fontSize: 11, color: textDimColor)),
                        ],
                      ),
                    ),
                    if (appt['type'] == 'In-person')
                      Icon(Icons.check_circle_rounded,
                          color: primary, size: 20),
                  ],
                ),
              ),
            ),

            // Online option
            GestureDetector(
              onTap: () {
                setState(() => appt['type'] = 'Video call');
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: appt['type'] == 'Video call'
                      ? Color(0xFF1A2A3A)
                      : Color(0xFF2C2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: appt['type'] == 'Video call'
                        ? Color(0xFF185FA5)
                        : Color(0xFF3A3A3A),
                    width: appt['type'] == 'Video call' ? 1.5 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFF1A2A3A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.videocam_rounded,
                          color: Color(0xFF185FA5), size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Online video call',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textColor)),
                          SizedBox(height: 2),
                          Text('Join from home via video call',
                              style:
                                  TextStyle(fontSize: 11, color: textDimColor)),
                        ],
                      ),
                    ),
                    if (appt['type'] == 'Video call')
                      Icon(Icons.check_circle_rounded,
                          color: Color(0xFF185FA5), size: 20),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showRescheduleSheet(Map<String, dynamic> appt) {
    DateTime selectedDate = DateTime.now().add(Duration(days: 1));
    String selectedSlot = '10:00 AM';
    final List<String> slots = [
      '9:00 AM',
      '10:00 AM',
      '11:00 AM',
      '2:00 PM',
      '3:00 PM',
      '4:00 PM',
      '5:00 PM',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: white24Color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16),

              Text('Reschedule appointment',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              SizedBox(height: 4),
              Text('Current: ${appt['date']} · ${appt['time']}',
                  style: TextStyle(fontSize: 12, color: textDimColor)),
              SizedBox(height: 20),

              // Date picker
              Text('Select new date',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              SizedBox(height: 10),
              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  separatorBuilder: (_, __) => SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final date = DateTime.now().add(Duration(days: i + 1));
                    final isSelected = selectedDate.day == date.day;
                    final days = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun'
                    ];
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedDate = date),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: 52,
                        decoration: BoxDecoration(
                          color: isSelected ? primary : Color(0xFF2C2A2A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? primary : Color(0xFF3A3A3A),
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              days[date.weekday - 1],
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.white38,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color:
                                    isSelected ? Colors.white : Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),

              // Time slots
              Text('Select new time',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: slots.map((slot) {
                  final isSelected = selectedSlot == slot;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedSlot = slot),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Color(0xFF1A2A22) : Color(0xFF2C2A2A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? primary : Color(0xFF3A3A3A),
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Text(slot,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? primary : Colors.white54,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          )),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),

              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      appt['date'] =
                          '${selectedDate.day} ${_monthName(selectedDate.month)}';
                      appt['time'] = selectedSlot;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Appointment rescheduled!'),
                        backgroundColor: primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Confirm reschedule',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  void _showWaitingRoom(Map<String, dynamic> appt) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: white24Color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),

              // Waiting animation
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: primary, width: 2),
                ),
                child: Icon(Icons.videocam_rounded, color: primary, size: 34),
              ),
              SizedBox(height: 14),

              Text('Waiting room',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              SizedBox(height: 6),
              Text('${appt['doctor']} will join shortly',
                  style: TextStyle(fontSize: 13, color: textDimColor)),
              SizedBox(height: 18),

              // Status card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Color(0xFF2C2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF3A3A3A), width: 0.5),
                ),
                child: Column(
                  children: [
                    _waitingRow(Icons.access_time_rounded, 'Estimated wait time',
                        '~5 minutes'),
                    SizedBox(height: 10),
                    _waitingRow(Icons.calendar_today_rounded, 'Appointment time',
                        appt['time'] as String),
                    SizedBox(height: 10),
                    _waitingRow(Icons.person_rounded, 'Doctor status',
                        'With previous patient'),
                  ],
                ),
              ),
              SizedBox(height: 18),

              // Join button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoCallScreen(
                          userId: appt['patient_email']?.toString() ?? 'patient1',
                          userName: appt['patient_name']?.toString() ?? 'Patient',
                          callId: appt['id']?.toString() ?? 'room123',
                          doctorName: appt['doctor']?.toString() ?? 'Doctor',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_rounded, color: textColor, size: 18),
                      SizedBox(width: 8),
                      Text('Join when ready',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Leave button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('Leave waiting room',
                      style: TextStyle(fontSize: 13, color: textMutedColor)),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _waitingRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: textMutedColor, size: 14),
        SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, color: textDimColor)),
        Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
      ],
    );
  }

  void _showInvoiceSheet(Map<String, dynamic> appt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: white24Color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16),

            // Header
            Row(
              children: [
                Text('Invoice',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor)),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A2A22),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: primary, width: 0.5),
                  ),
                  child: Text('Paid',
                      style: TextStyle(
                          fontSize: 11,
                          color: primary,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Invoice details
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Color(0xFF2C2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF3A3A3A), width: 0.5),
              ),
              child: Column(
                children: [
                  _invoiceRow('Booking ID', '#MED2026032001'),
                  Divider(color: Color(0xFF3A3A3A), height: 16),
                  _invoiceRow('Doctor', appt['doctor'] as String),
                  SizedBox(height: 8),
                  _invoiceRow('Hospital', appt['hospital'] as String),
                  SizedBox(height: 8),
                  _invoiceRow('Date', appt['date'] as String),
                  SizedBox(height: 8),
                  _invoiceRow('Time', appt['time'] as String),
                  Divider(color: Color(0xFF3A3A3A), height: 16),
                  _invoiceRow('Consultation fee', '₹500'),
                  SizedBox(height: 8),
                  _invoiceRow('Platform fee', '₹0',
                      valueColor: Color(0xFF1D9E75)),
                  SizedBox(height: 8),
                  _invoiceRow('Discount', '-₹0', valueColor: Color(0xFF1D9E75)),
                  Divider(color: Color(0xFF3A3A3A), height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total paid',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor)),
                      Text('₹500',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D9E75))),
                    ],
                  ),
                  SizedBox(height: 8),
                  _invoiceRow('Payment method', 'UPI'),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Download button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_rounded, color: textColor, size: 18),
                    SizedBox(width: 8),
                    Text('Download invoice PDF',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _invoiceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: textDimColor)),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.white)),
      ],
    );
  }

  // ── Chat bottom sheet ─────────────────────
  void _openChat(Map<String, dynamic> appt) {
    final TextEditingController chatController = TextEditingController();
    final List<Map<String, String>> messages = [
      {'sender': 'doctor', 'text': 'Hello! How are you feeling today?'},
      {'sender': 'patient', 'text': 'I have been having some dizziness.'},
      {
        'sender': 'doctor',
        'text': 'I see. Have you been taking your medications regularly?'
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: white24Color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Chat header
              Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: appt['bg'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(appt['initials'] as String,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: appt['color'] as Color)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appt['doctor'] as String,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                        Text('Online',
                            style: TextStyle(
                                fontSize: 10, color: Color(0xFF1D9E75))),
                      ],
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close_rounded,
                          color: textDimColor, size: 20),
                    ),
                  ],
                ),
              ),
              Divider(color: Color(0xFF3A3A3A), height: 1),

              // Messages
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    final isPatient = msg['sender'] == 'patient';
                    return Align(
                      alignment: isPatient
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.65,
                        ),
                        decoration: BoxDecoration(
                          color: isPatient ? primary : Color(0xFF2C2A2A),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                            bottomLeft: Radius.circular(isPatient ? 14 : 4),
                            bottomRight: Radius.circular(isPatient ? 4 : 14),
                          ),
                        ),
                        child: Text(msg['text']!,
                            style: TextStyle(
                                fontSize: 13, color: textColor, height: 1.4)),
                      ),
                    );
                  },
                ),
              ),

              // Input
              Container(
                padding: EdgeInsets.fromLTRB(
                  12,
                  8,
                  12,
                  MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Color(0xFF3A3A3A), width: 0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: chatController,
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle:
                              TextStyle(color: textMutedColor, fontSize: 13),
                          filled: true,
                          fillColor: Color(0xFF2C2A2A),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (chatController.text.isNotEmpty) {
                          setModalState(() {
                            messages.add({
                              'sender': 'patient',
                              'text': chatController.text,
                            });
                            chatController.clear();
                          });
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: primary, shape: BoxShape.circle),
                        child: Icon(Icons.send_rounded,
                            color: textColor, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompletedDetail(Map<String, dynamic> appt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: white24Color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Doctor info
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: appt['bg'] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(appt['initials'] as String,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: appt['color'] as Color)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appt['doctor'] as String,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor)),
                      Text('${appt['specialization']} · ${appt['hospital']}',
                          style: TextStyle(fontSize: 11, color: textDimColor)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A2A22),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Color(0xFF0F6E56), width: 0.5),
                  ),
                  child: Text('Completed',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F6E56))),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Date time row
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 13, color: textMutedColor),
                SizedBox(width: 6),
                Text('${appt['date']} · ${appt['time']}',
                    style: TextStyle(fontSize: 12, color: textDimColor)),
              ],
            ),
            SizedBox(height: 20),

            // View prescription
            _detailBtn(
              icon: Icons.description_rounded,
              label: 'View prescription',
              bgColor: Color(0xFF1A2A3A),
              textColor: Color(0xFF378ADD),
              borderColor: Color(0xFF185FA5),
              onTap: () => Navigator.pop(context),
            ),
            SizedBox(height: 10),

            // Book follow-up
            _detailBtn(
              icon: Icons.refresh_rounded,
              label: 'Book follow-up with same doctor',
              bgColor: Color(0xFF1A2A22),
              textColor: Color(0xFF0F6E56),
              borderColor: Color(0xFF0F6E56),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HospitalSearchScreen()),
                );
              },
            ),
            SizedBox(height: 10),

            // Download invoice
            _detailBtn(
              icon: Icons.receipt_rounded,
              label: 'Download invoice',
              bgColor: Color(0xFF2A2215),
              textColor: Color(0xFFBA7517),
              borderColor: Color(0xFFBA7517),
              onTap: () {
                Navigator.pop(context);
                _showInvoiceSheet(appt);
              },
            ),
            SizedBox(height: 10),

            // Rate doctor
            if (appt['rated'] == false)
              _detailBtn(
                icon: Icons.star_rounded,
                label: 'Rate your experience',
                bgColor: Color(0xFF2A2215),
                textColor: Color(0xFFBA7517),
                borderColor: Color(0xFFBA7517),
                onTap: () {
                  Navigator.pop(context);
                  _showRatingDialog(appt);
                },
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Cancel dialog ─────────────────────────
  void _showCancelDialog(Map<String, dynamic> appt) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cancel appointment',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
        content: Text(
            'Are you sure you want to cancel your appointment with ${appt['doctor']}?',
            style: TextStyle(fontSize: 13, color: textDimColor, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep it', style: TextStyle(color: textDimColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final appointmentId = appt['id'];
              if (appointmentId != null) {
                try {
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
                    SnackBar(content: Text('Cancelling appointment...')),
                  );
                  final res = await ApiService.updateAppointmentStatus(
                      appointmentId, "Cancelled");
                  if (!mounted) return;
                  if (res["success"] == true) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Appointment cancelled successfully!'),
                        backgroundColor: primary,
                      ),
                    );
                    fetchAppointments();
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                            res["error"] ?? 'Failed to cancel appointment.'),
                        backgroundColor: danger,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint("Error cancelling appointment: $e");
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: danger,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child:
                Text('Cancel appointment', style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }

  // ── Rating dialog ─────────────────────────
  void _showRatingDialog(Map<String, dynamic> appt) {
    int rating = appt['doctor_rating'] ?? 0;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: cardBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Rate your experience',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How was your visit with ${appt['doctor_name'] ?? appt['doctor'] ?? "your doctor"}?',
                  style: TextStyle(fontSize: 13, color: textDimColor)),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    5,
                    (i) => GestureDetector(
                          onTap: () => setDialogState(() => rating = i + 1),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              i < rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: Color(0xFFEF9F27),
                              size: 32,
                            ),
                          ),
                        )),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: textDimColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (rating > 0) {
                  final apptId = appt['id'];
                  if (apptId != null) {
                    final res = await ApiService.rateDoctor(
                      appointmentId: apptId is int ? apptId : int.parse(apptId.toString()),
                      rating: rating,
                    );
                    if (res['success'] == true) {
                      Navigator.pop(context);
                      fetchAppointments();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thank you for rating!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${res['error'] ?? 'failed to submit rating'}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select at least 1 star'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Submit', style: TextStyle(color: textColor)),
            ),
          ],
        ),
      ),
    );
  }
}
