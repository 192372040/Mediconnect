import 'package:flutter/material.dart';
import 'package:my_project/Admin/AdProfile.dart';
import 'package:my_project/Admin/BedsS.dart';
import 'package:my_project/Admin/Doctors.dart';
import 'package:my_project/Admin/Dashboard.dart';
import '../Patientdashboard/services/api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  final String hospitalId;

  const AnalyticsScreen({
    Key? key,
    required this.hospitalId,
  }) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic>? analyticsData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    final res = await ApiService.getHospitalAnalytics(widget.hospitalId);
    setState(() {
      analyticsData = res;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF252525);
    const Color primaryColor = Color(0xFFC7781E); // Orange
    const Color cardBgColor = Color(0xFF1E1E1E);

    if (isLoading) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    // Safely extract values with fallbacks
    double rating = double.tryParse(analyticsData?['hospital_rating']?.toString() ?? '0') ?? 0.0;
    int todayPatients = int.tryParse(analyticsData?['today_appointments']?.toString() ?? '0') ?? 0;
    int todayAppointments = int.tryParse(analyticsData?['today_appointments']?.toString() ?? '0') ?? 0;
    double todayRevenue = double.tryParse(analyticsData?['today_revenue']?.toString() ?? '0') ?? 0.0;

    
    // Convert revenue to string format
    String formattedRevenue = todayRevenue >= 100000 
        ? '₹${(todayRevenue / 100000).toStringAsFixed(1)}L' 
        : '₹${todayRevenue.toStringAsFixed(0)}';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor, size: 18),
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Analytics',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      _buildFilterChip('Today', isActive: true, primaryColor: primaryColor),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[800], height: 1),
            
            // Scrollable Content
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Hospital Performance Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB56A15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Hospital rating', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                                      const Text(' / 5.0', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      rating >= 4.0 ? 'Excellent performance' : rating >= 3.0 ? 'Good performance' : 'Needs Improvement', 
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.star, color: Colors.white, size: 28),
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: rating / 5.0,
                              backgroundColor: Colors.black26,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 2x2 Stats Grid (Critical Patients removed)
                    Row(
                      children: [
                        _buildStatBox('$todayPatients', 'Patients today', 'Based on today\'s date', Colors.blue[400]!, cardBgColor),
                        const SizedBox(width: 12),
                        _buildStatBox(formattedRevenue, 'Revenue today', 'From today\'s fees', Colors.green[400]!, cardBgColor),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatBox('$todayAppointments', 'Appointments today', 'Scheduled for today', primaryColor, cardBgColor),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Top performing doctors
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        border: Border.all(color: Colors.grey[800]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Top performing doctors', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          if (analyticsData?['top_doctors'] != null && (analyticsData?['top_doctors'] as List).isNotEmpty)
                            ...((analyticsData?['top_doctors'] as List).map((doctorData) {
                              String docName = doctorData['doctor_name'] ?? 'Doctor';
                              int apptCount = doctorData['appointments_count'] ?? 0;
                              String initials = docName.replaceAll("Dr. ", "").replaceAll("Dr.", "").trim();
                              if (initials.isNotEmpty) {
                                List<String> parts = initials.split(" ");
                                initials = parts.length >= 2 ? (parts[0][0] + parts[1][0]).toUpperCase() : parts[0][0].toUpperCase();
                              } else {
                                initials = "DR";
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildTopDoctorRow(initials, docName, '$apptCount patients', doctorData['rating'] ?? '4.5', Colors.blue[800]!, primaryColor),
                              );
                            }).toList())
                          else
                            const Text('No top doctors data available', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF1E1E1E),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          currentIndex: 3,
          onTap: (index) {
            if (index == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HospitalDashboardScreen(hospitalId: widget.hospitalId)));
            } else if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ManageDoctorsScreen(hospitalId: widget.hospitalId)));
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => BedManagementScreen(hospitalId: widget.hospitalId)));
            } else if (index == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyticsScreen(hospitalId: widget.hospitalId)));
            } else if (index == 4) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HospitalProfileScreen(hospitalData: null, hospitalId: widget.hospitalId)));
            }
          },
          elevation: 10,
          items: const [
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home_outlined)), label: 'Home'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_outline)), label: 'Doctors'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.medical_services_outlined)), label: 'Beds'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.show_chart)), label: 'Analytics'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.circle_outlined)), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isActive, required Color primaryColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border.all(color: isActive ? primaryColor : Colors.grey[800]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? primaryColor : Colors.grey[500],
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatBox(String value, String title, String subtitle, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: color.withOpacity(0.8), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDoctorRow(String initials, String name, String details, String rating, Color avatarBg, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 20,
          backgroundColor: avatarBg,
          child: Text(initials, style: TextStyle(color: dotColor, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(details, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
        ),
        Row(
          children: [
            Text(rating, style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold)),
            const Icon(Icons.star, color: Colors.green, size: 14),
          ],
        ),
      ],
    );
  }
}
