import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_project/Patientdashboard/HospitalSearchScreen.dart';
import 'package:my_project/Patientdashboard/AiSymptomChecker.dart';
import 'package:my_project/patientdashboard/reports/Myreports.dart';
import 'package:my_project/patientdashboard/AppointmentsScreen.dart';
import 'package:my_project/Patientdashboard/health/HealthScreen.dart';
import 'package:my_project/Patientdashboard/UserProfileScreen.dart';
import 'package:my_project/Patientdashboard/SettingsScreen.dart';
import 'package:my_project/Patientdashboard/NotificationsScreen.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientDashboardScreen extends StatefulWidget {
  final Map user;

  const PatientDashboardScreen({super.key, required this.user});
  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  static Color primary = Color(0xFF0F6E56);
  Color get primaryBg => Theme.of(context).brightness == Brightness.dark ? Color(0xFF2C2A2A) : Colors.white;
  Color get cardBg => Theme.of(context).brightness == Brightness.dark ? Color(0xFF1A1A1A) : Colors.grey.shade50;
  Color get borderColor => Theme.of(context).brightness == Brightness.dark ? Color(0xFF3A3A3A) : Colors.grey.shade200;
  Color get textLightColor => Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54;
  Color get textColor => Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;
  Color get textDimColor => Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black87;
  Color get textMutedColor => Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.black54;
  Color get white24Color => Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black12;

  List<dynamic> _appointments = [];
  bool _isLoadingAppointments = true;
  Map<String, dynamic>? _upcomingAppointment;
  bool _hasUnreadNotifications = true; // tracks notification dot
  late Map<String, dynamic> _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = Map<String, dynamic>.from(widget.user);
    _fetchUserProfile();
    _fetchAppointments();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final email = (_currentUser["email"] ?? widget.user["email"])?.toString() ?? "";
      if (email.isEmpty) return;
      final profile = await ApiService.getPatientProfile(email);
      if (profile != null && profile is Map<String, dynamic> && profile["email"] != null) {
        if (mounted) {
          setState(() {
            _currentUser = {..._currentUser, ...profile};
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching patient profile: $e");
    }
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

  Future<void> _fetchAppointments() async {
    if (!mounted) return;
    setState(() {
      _isLoadingAppointments = true;
    });
    try {
      final email = (_currentUser["email"] ?? widget.user["email"])?.toString() ?? "";
      if (email.isNotEmpty) {
        final appointments = await ApiService.getPatientAppointments(email);
        final confirmed = appointments.where((app) => app["booking_status"] == "Confirmed" || app["booking_status"] == "Pending").toList();
        if (confirmed.isNotEmpty) {
          _upcomingAppointment = confirmed.first;
        } else {
          _upcomingAppointment = null;
        }
        _appointments = appointments;

        int index = confirmed.length;
        try {
          final prescs = await ApiService.getPatientPrescriptions(email);
          for (var presc in prescs) {
            final medicinesStr = presc["medicines"]?.toString() ?? '';
            if (medicinesStr.isNotEmpty) {
              final medList = medicinesStr.split(RegExp(r'[,\n]')).map((m) => m.trim()).where((m) => m.isNotEmpty).toList();
              index += medList.length;
            }
          }
        } catch (_) {}

        final prefs = await SharedPreferences.getInstance();
        final lastSeenCount = prefs.getInt("last_seen_notifications_count") ?? 0;
        setState(() {
          _hasUnreadNotifications = index > lastSeenCount;
        });
      }
    } catch (e) {
      print("Error fetching appointments on dashboard: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAppointments = false;
        });
      }
    }
  }

  String getInitials(String doctorName) {
    if (doctorName.isEmpty) return "DR";
    String cleanName = doctorName.replaceAll("Dr. ", "").replaceAll("Dr.", "").trim();
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
  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return "Good morning,";
    if (hour < 17) return "Good afternoon,";
    return "Good evening,";
  }

  String getRiskLevel() {
    String history = _currentUser["medical_history"]?.toString() ?? "";

    if (history.isEmpty) {
      return "Low";
    }

    int count = history.split(",").length;

    if (count >= 3) {
      return "High";
    } else if (count == 2) {
      return "Moderate";
    } else {
      return "Low";
    }
  }

  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    _buildHealthScoreCard(),
                    SizedBox(height: 20),
                    _buildFindHospital(),
                    SizedBox(height: 20),
                    _buildSectionTitle('Quick actions'),
                    SizedBox(height: 12),
                    _buildQuickActions(),
                    SizedBox(height: 20),
                    _buildSectionTitle('Upcoming appointment'),
                    SizedBox(height: 12),
                    _buildAppointmentCard(),
                    SizedBox(height: 20),
                    _buildSectionTitle('Health tips'),
                    SizedBox(height: 12),
                    _buildHealthTips(),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: primaryBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfileScreen(user: _currentUser),
                ),
              );
              _fetchUserProfile();
              _fetchAppointments();
            },
            child: Container(
              width: 42,
              height: 42,
              decoration:
                  BoxDecoration(color: primary, shape: BoxShape.circle),
              child: Center(
                child: Text(
                    _currentUser["name"] != null &&
                            _currentUser["name"].toString().isNotEmpty
                        ? _currentUser["name"][0].toUpperCase()
                        : "U",
                    style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getGreeting(),
                  style: TextStyle(
                    fontSize: 12,
                    color: textDimColor,
                  ),
                ),
                Text(
                  _currentUser["name"] ?? "User",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 2), // optional spacing
                Text(
                  _currentUser["email"] ?? "",
                  style: TextStyle(
                    fontSize: 12,
                    color: textDimColor,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              int index = _appointments.where((app) => app["booking_status"] == "Confirmed" || app["booking_status"] == "Pending").length;
              try {
                final email = _currentUser["email"]?.toString() ?? "";
                final prescs = await ApiService.getPatientPrescriptions(email);
                for (var presc in prescs) {
                  final medicinesStr = presc["medicines"]?.toString() ?? '';
                  if (medicinesStr.isNotEmpty) {
                    final medList = medicinesStr.split(RegExp(r'[,\n]')).map((m) => m.trim()).where((m) => m.isNotEmpty).toList();
                    index += medList.length;
                  }
                }
              } catch (_) {}

              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt("last_seen_notifications_count", index);
              setState(() {
                _hasUnreadNotifications = false;
              });

              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationsScreen(user: _currentUser)),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: cardBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 0.5)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.notifications_outlined,
                      color: textColor, size: 20),
                  if (_hasUnreadNotifications)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: Color(0xFFE24B4A), shape: BoxShape.circle)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: primary, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your health score',
                    style: TextStyle(fontSize: 12, color: textLightColor)),
                SizedBox(height: 6),
                Text(
                  getRiskLevel() == "High"
                      ? '45 / 100'
                      : getRiskLevel() == "Moderate"
                          ? '72 / 100'
                          : '95 / 100',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: white24Color,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${getRiskLevel()} risk',
                    style: TextStyle(
                      fontSize: 11,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: getRiskLevel() == "High"
                        ? 0.45
                        : getRiskLevel() == "Moderate"
                            ? 0.72
                            : 0.95,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: white24Color, shape: BoxShape.circle),
            child: Icon(Icons.favorite_rounded,
                color: textColor, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildFindHospital() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Find a hospital'),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HospitalSearchScreen()),
          ).then((_) {
            _fetchAppointments();
          }),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Search hospital or clinic...',
                      style: TextStyle(fontSize: 13, color: textMutedColor)),
                ),
                GestureDetector(
                  onTap: () async {
                    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=hospitals');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFF1A2A22),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFF1D9E75), width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_rounded, color: Color(0xFF1D9E75), size: 14),
                        SizedBox(width: 4),
                        Text('Maps', style: TextStyle(fontSize: 11, color: Color(0xFF1D9E75), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: textColor));
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.calendar_today_rounded,
        'label': 'Book\nAppointment',
        'color': Color(0xFF185FA5),
        'bg': Color(0xFF1A2A3A)
      },
      {
        'icon': Icons.psychology_rounded,
        'label': 'AI Symptom\nChecker',
        'color': Color(0xFF7F77DD),
        'bg': Color(0xFF1E1A2E)
      },
      {
        'icon': Icons.description_rounded,
        'label': 'My\nReports',
        'color': Color(0xFF1D9E75),
        'bg': Color(0xFF1A2A22)
      },
     
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.8,
      children: actions
          .map((a) => GestureDetector(
                onTap: () {
                  if (a['label'] == 'Book\nAppointment') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HospitalSearchScreen(),
                      ),
                    ).then((_) {
                      _fetchAppointments();
                    });
                  } else if (a['label'] == 'AI Symptom\nChecker') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AiSymptomCheckerScreen(),
                      ),
                    );
                  } else if (a['label'] == 'My\nReports') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MyReportsScreen(
                                user: _currentUser,
                              )),
                    );
                  } 
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: a['bg'] as Color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(
                            ((a['color'] as Color).r * 255.0)
                                .round()
                                .clamp(0, 255),
                            ((a['color'] as Color).g * 255.0)
                                .round()
                                .clamp(0, 255),
                            ((a['color'] as Color).b * 255.0)
                                .round()
                                .clamp(0, 255),
                            0.15,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(a['icon'] as IconData,
                            color: a['color'] as Color, size: 18),
                      ),
                      SizedBox(width: 10),
                      Text(a['label'] as String,
                          style: TextStyle(
                              fontSize: 11,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                              height: 1.3)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildAppointmentCard() {
    if (_isLoadingAppointments) {
      return Container(
        height: 90,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: CircularProgressIndicator(color: primary),
      );
    }

    if (_upcomingAppointment == null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, color: textMutedColor, size: 36),
            SizedBox(height: 12),
            Text(
              'No upcoming appointments scheduled',
              style: TextStyle(fontSize: 13, color: textDimColor, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HospitalSearchScreen(),
                    ),
                  ).then((_) {
                    _fetchAppointments();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Book appointment now',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final doctorName = _upcomingAppointment!["doctor_name"] ?? "Doctor";
    final specialization = _upcomingAppointment!["specialization"] ?? "";
    final hospitalName = _upcomingAppointment!["hospital_name"] ?? "";
    final appointmentDate = _upcomingAppointment!["appointment_date"] ?? "";
    final appointmentSlot = _upcomingAppointment!["appointment_slot"] ?? "";

    final docColor = getDoctorColor(doctorName);
    final docBg = getDoctorBgColor(docColor);
    final initials = getInitials(doctorName);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: docBg,
              shape: BoxShape.circle,
              border: Border.all(color: docColor, width: 1.5),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: docColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '$specialization · $hospitalName',
                  style: TextStyle(fontSize: 11, color: textDimColor),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 11, color: textMutedColor),
                    SizedBox(width: 4),
                    Text(
                      '${_formatApptDate(appointmentDate)} · $appointmentSlot',
                      style: TextStyle(fontSize: 11, color: textDimColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AppointmentsScreen(
                    patientEmail: _currentUser["email"] ?? "",
                  ),
                ),
              ).then((_) {
                _fetchAppointments();
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'View',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTips() {
    final tips = [
      {
        'icon': Icons.water_drop_rounded,
        'color': Color(0xFF185FA5),
        'bg': Color(0xFF1A2A3A),
        'tip': 'Drink 8 glasses of water daily to maintain blood sugar levels.'
      },
      {
        'icon': Icons.directions_walk_rounded,
        'color': Color(0xFF1D9E75),
        'bg': Color(0xFF1A2A22),
        'tip': 'A 30-minute walk daily reduces diabetes risk by 30%.'
      },
    ];
    return Column(
      children: tips
          .map((t) => Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 0.5)),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: t['bg'] as Color,
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(t['icon'] as IconData,
                          color: t['color'] as Color, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                        child: Text(t['tip'] as String,
                            style: TextStyle(
                                fontSize: 12,
                                color: textLightColor,
                                height: 1.5))),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildBottomNav() {
    final tabs = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.calendar_today_rounded, 'label': 'Appointments'},
      {'icon': Icons.favorite_rounded, 'label': 'Health'},
      {'icon': Icons.settings_rounded, 'label': 'Settings'},
    ];
    return Container(
      height: 70,
      decoration: BoxDecoration(
          color: cardBg,
          border: Border(top: BorderSide(color: borderColor, width: 0.5))),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final sel = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (i == 1) {
                  final patientEmail = _currentUser["email"]?.toString() ?? '';
                  if (patientEmail.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Patient email is missing.')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AppointmentsScreen(
                        patientEmail: _currentUser["email"],
                      ),
                    ),
                  ).then((_) {
                    _fetchAppointments();
                  });
                } else if (i == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HealthScreen()),
                  ).then((_) {
                    _fetchAppointments();
                  });
                } else if (i == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SettingsScreen()),
                  ).then((_) {
                    _fetchAppointments();
                  });
                } else {
                  setState(() => _selectedTab = i);
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(tabs[i]['icon'] as IconData,
                      color: sel ? primary : textMutedColor, size: 22),
                  SizedBox(height: 4),
                  Text(tabs[i]['label'] as String,
                      style: TextStyle(
                          fontSize: 10,
                          color: sel ? primary : textMutedColor,
                          fontWeight:
                              sel ? FontWeight.w600 : FontWeight.normal)),
                  SizedBox(height: 4),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: sel ? 20 : 0,
                    height: 3,
                    decoration: BoxDecoration(
                        color: primary, borderRadius: BorderRadius.circular(2)),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
