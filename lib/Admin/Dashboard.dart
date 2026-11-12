import 'package:flutter/material.dart';
import '../Patientdashboard/services/api_service.dart';
import 'package:my_project/Admin/AdProfile.dart';
import 'package:my_project/Admin/BedsS.dart';
import 'package:my_project/Admin/Doctors.dart';
import 'package:my_project/Admin/Analytis.dart';
import 'package:my_project/Admin/HospitalAppointmentsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
class HospitalDashboardScreen extends StatefulWidget {
  final String hospitalId;

  const HospitalDashboardScreen({
    super.key,
    required this.hospitalId,
  });

  @override
  State<HospitalDashboardScreen> createState() => _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState
extends State<HospitalDashboardScreen> {
int currentIndex = 0;
Map<String, dynamic>? hospitalData;
bool _hasUnreadNotifications = false;

bool isLoading = true;

@override
void initState() {

  super.initState();

  fetchHospitalData();
}

  int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? fallback;
    return fallback;
  }

  Future<void> fetchHospitalData() async {
    try {
      var res = await ApiService.getAdminHospitalSummary(widget.hospitalId);
      var analyticsRes = await ApiService.getHospitalAnalytics(widget.hospitalId);

      if (mounted) {
        setState(() {
          // 1. Load the dynamic core profile data returned from the backend
          hospitalData = res["hospital"] ?? {};
          
          // 2. Safely bind the dynamic backend analytics values if they exist
          if (analyticsRes["success"] == true) {
            hospitalData!['total_doctors'] = _parseInt(analyticsRes['total_doctors']);
            hospitalData!['total_beds'] = _parseInt(analyticsRes['total_beds']);
            hospitalData!['total_departments'] = _parseInt(analyticsRes['total_departments']);
            hospitalData!['today_appointments'] = _parseInt(analyticsRes['today_appointments']);
            hospitalData!['critical_beds'] = _parseInt(analyticsRes['critical_beds']);
            hospitalData!['critical_alerts'] = analyticsRes['critical_alerts'] ?? [];
            hospitalData!['recent_alerts'] = analyticsRes['recent_alerts'] ?? [];

            final int todayCount = _parseInt(analyticsRes['today_appointments']);
            SharedPreferences.getInstance().then((prefs) {
              final lastSeenCount = prefs.getInt("last_seen_admin_appointments_${widget.hospitalId}") ?? 0;
              if (mounted) {
                setState(() {
                  _hasUnreadNotifications = todayCount > lastSeenCount;
                });
              }
            });
          } else {
            // 3. Fallback: If analyticsRes fields are missing, read directly from the main hospital model
            hospitalData!['total_doctors'] = _parseInt(hospitalData!['total_doctors']);
            hospitalData!['total_beds'] = _parseInt(hospitalData!['total_beds']);
            hospitalData!['total_departments'] = _parseInt(hospitalData!['total_departments']);
            hospitalData!['today_appointments'] = _parseInt(hospitalData!['today_appointments']);
            hospitalData!['critical_beds'] = _parseInt(hospitalData!['critical_beds']);
            hospitalData!['critical_alerts'] = hospitalData!['critical_alerts'] ?? [];
            hospitalData!['recent_alerts'] = hospitalData!['recent_alerts'] ?? [];
          }

          
          // 4. CRITICAL FIX: Make sure loading state is closed so UI draws itself
          isLoading = false; 
        });
      }
    } catch (e) {
      debugPrint("Error fetching hospital data: $e");
      if (mounted) {
        setState(() {
          // Dynamic catch-all initialization
          hospitalData ??= {
            'hospital_name': 'Unknown Hospital',
            'hospital_id': widget.hospitalId,
            'total_doctors': 0,
            'total_beds': 0,
            'total_departments': 0,
            'today_appointments': 0,
            'critical_beds': 0,
            'critical_alerts': [],
            'recent_alerts': [],
          };
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF252525);
    const Color primaryColor = Color(0xFFC7781E);
    const Color cardBgColor = Color(0xFF1E1E1E);

    if (isLoading) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    final String hospitalName = hospitalData?['hospital_name'] ?? 'Apollo Hospital';
    String initials = '';
    final parts = hospitalName.trim().split(RegExp(r'\s+'));
    if (parts.isNotEmpty) {
      initials = parts.take(2).map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').join();
    }
    if (initials.isEmpty) initials = 'AH';

    final int totalDoctors = _parseInt(hospitalData?['total_doctors']);
    final int totalBeds = _parseInt(hospitalData?['total_beds']);
    final int totalDepts = _parseInt(hospitalData?['total_departments']);
    final int criticalBeds = _parseInt(hospitalData?['critical_beds'], 12);
    final int todayAppts = _parseInt(hospitalData?['today_appointments']);


    final List<dynamic> criticalAlerts = hospitalData?['critical_alerts'] ?? [];
    final List<dynamic> recentAlerts = hospitalData?['recent_alerts'] ?? [];

    final String alert1Text = criticalAlerts.isNotEmpty
        ? (criticalAlerts[0]['title'] ?? 'ICU beds critical — only 2 available')
        : 'ICU beds critical — only 2 available';
    final String alert1Time = criticalAlerts.isNotEmpty
        ? (criticalAlerts[0]['time'] ?? 'Now')
        : 'Now';

    final String alert2Text = recentAlerts.isNotEmpty
        ? (recentAlerts[0]['title'] ?? 'Dr. Anjali Kumar requested leave — Apr 10')
        : 'Dr. Anjali Kumar requested leave — Apr 10';
    final String alert2Time = recentAlerts.isNotEmpty
        ? (recentAlerts[0]['time'] ?? '1h ago')
        : '1h ago';
    debugPrint("DEBUG: Hospital dashboard body is building");
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        toolbarHeight: 80,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 12, bottom: 12),
          child: CircleAvatar(
            backgroundColor: primaryColor,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hospitalName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.hospitalId,
              style: const TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final int todayCount = _parseInt(hospitalData?['today_appointments']);
                  await prefs.setInt("last_seen_admin_appointments_${widget.hospitalId}", todayCount);

                  setState(() {
                    _hasUnreadNotifications = false;
                  });
                  if (!context.mounted) return;
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hospital Location & Alerts', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Text('Address: ${hospitalData?['hospital_address'] ?? 'Main Campus'}', style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 10),
                            Text('Status: ${hospitalData?['status'] ?? 'Open 24/7'}', style: const TextStyle(color: Colors.greenAccent)),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: const Icon(Icons.location_on_outlined, color: Colors.white, size: 22),
                    ),
                    if (_hasUnreadNotifications)
                      Positioned(
                        right: 1,
                        top: 1,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE53935),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hospital Overview Amber Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFB56A15),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hospital overview',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$totalDoctors doctors',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$totalBeds beds • $totalDepts depts',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 170,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 120,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ManageDoctorsScreen(hospitalId: widget.hospitalId),
                      ),
                    ),
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.28),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 34),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4 Stats Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('$totalDoctors', 'Doctors', const Color(0xFF42A5F5), cardBgColor),
                _buildStatCard('$totalBeds', 'Beds', const Color(0xFF66BB6A), cardBgColor),
                _buildStatCard('$criticalBeds', 'Critical', const Color(0xFFEF5350), cardBgColor),
                _buildStatCard('$todayAppts', 'Today', const Color(0xFFFFA726), cardBgColor),
              ],
            ),
            const SizedBox(height: 24),

            // Quick actions
            const Text(
              'Quick actions',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            // Quick Actions Grid (2x2)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ManageDoctorsScreen(hospitalId: widget.hospitalId)),
                    ),
                    child: _buildActionCard(Icons.person_add_alt_1_outlined, 'Add doctor', const Color(0xFF42A5F5), cardBgColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BedManagementScreen(hospitalId: widget.hospitalId)),
                    ),
                    child: _buildActionCard(Icons.bed_outlined, 'Manage beds', const Color(0xFF66BB6A), cardBgColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HospitalAppointmentsScreen(hospitalId: widget.hospitalId)),
                    ),
                    child: _buildActionCard(Icons.calendar_today_outlined, 'Appointments', const Color(0xFFFFA726), cardBgColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AnalyticsScreen(hospitalId: widget.hospitalId)),
                    ),
                    child: _buildActionCard(Icons.show_chart, 'Analytics', const Color(0xFFB388FF), cardBgColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent alerts section
            const Text(
              'Recent alerts',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            _buildAlertCard(
              alert1Text,
              alert1Time,
              const Color(0xFFEF5350),
              cardBgColor,
            ),
            const SizedBox(height: 12),
            _buildAlertCard(
              alert2Text,
              alert2Time,
              const Color(0xFFFFA726),
              cardBgColor,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex) return;
          setState(() {
            currentIndex = index;
          });

          // HOME
          if (index == 0) {
            fetchHospitalData();
          }
          // DOCTORS
          else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ManageDoctorsScreen(
                  hospitalId: widget.hospitalId,
                ),
              ),
            );
          }
          // BEDS
          else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BedManagementScreen(
                  hospitalId: widget.hospitalId,
                ),
              ),
            );
          }
          // ANALYTICS
          else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnalyticsScreen(
                  hospitalId: widget.hospitalId,
                ),
              ),
            );
          }
          // PROFILE
          else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HospitalProfileScreen(
                  hospitalData: hospitalData,
                  hospitalId: widget.hospitalId,
                ),
              ),
            );
          }
        },
        backgroundColor: const Color(0xFF1E1E1E),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            label: 'Beds',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(String text, String time, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}