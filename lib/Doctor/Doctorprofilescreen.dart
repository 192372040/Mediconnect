import 'package:flutter/material.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';
import 'package:my_project/Doctor/DoctorStep2Screen.dart';
import 'package:my_project/DoctorLogin.dart';
import 'package:my_project/Doctor/Doctordashscreen.dart';
import 'package:my_project/Doctor/Schdule.dart';
import 'package:my_project/Doctor/Patients.dart';
import 'package:my_project/Doctor/records.dart';
class DoctorProfileScreen extends StatefulWidget {
  final String doctorId;

  const DoctorProfileScreen({
    super.key,
    required this.doctorId,
  });

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  Map<String, dynamic>? doctorData;

  @override
  void initState() {
    super.initState();

    loadDoctorProfile();
  }

  Future<void> loadDoctorProfile() async {
    final res = await ApiService.getDoctorProfile(widget.doctorId);

    setState(() {
      doctorData = res;
    });
  }

  // Theme Colors
  static const Color bgColor = Color(0xFF242424);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color primaryBlue = Color(0xFF1976D2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const Divider(color: Colors.white12, height: 1),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildProfileInfo(),
                    const SizedBox(height: 24),
                    _buildDetailsCard(),
                    const SizedBox(height: 20),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildLogoutButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ==========================================
  // HEADER
  // ==========================================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            child: Text(
              'My profile',
              style: TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 32,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Step2PersonalDetailsScreen(
                      email: doctorData?["email"] ?? "",  
                      doctorId: widget.doctorId,
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryBlue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Edit',
                  style: TextStyle(color: primaryBlue, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // AVATAR & NAME SECTION
  // ==========================================
  Widget _buildProfileInfo() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            color: primaryBlue,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text(
            'RK',
            style: TextStyle(
                color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          doctorData?["full_name"] ?? "",
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          doctorData?["specialization"] ?? "",
          style: TextStyle(color: Color(0xFF64B5F6), fontSize: 16),
        ),
        const SizedBox(height: 12),
        // ID Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0F253F), // Very dark blue tint
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryBlue),
          ),
          child: Text(
            doctorData?["doctor_id"] ?? widget.doctorId,
            style: const TextStyle(
                color: Color(0xFF64B5F6),
                fontSize: 13,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // DETAILS CARD (Hospital, Experience, etc.)
  // ==========================================
  Widget _buildDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'Hospital',
            doctorData?["hospital_name"] ?? "",
          ),
          const Divider(color: Colors.white12, height: 1),
          _buildDetailRow(
            'Experience',
            "${doctorData?["experience"] ?? ""} years",
          ),
          const Divider(color: Colors.white12, height: 1),
          _buildDetailRow(
            'License',
            doctorData?["license_number"] ?? "",
          ),
          const Divider(color: Colors.white12, height: 1),
          _buildDetailRow('Fee', "₹${doctorData?["consultation_fee"] ?? ""}",
              valueColor: const Color(0xFF4CAF50)),
          const Divider(color: Colors.white12, height: 1),
          _buildDetailRow(
            'Rating',
            '',
            valueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                const SizedBox(width: 4),
                Text(doctorData?["rating"]?.toString() ?? "0.0",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Details Card Rows
  Widget _buildDetailRow(String label, String value,
      {Color? valueColor, Widget? valueWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
          if (valueWidget != null)
            valueWidget
          else
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // STATS BOXES ROW
  // ==========================================
  Widget _buildStatsRow() {
    return Row(
      children: [
        // Patients Stat
        Expanded(
          child: _buildStatBox(
            count: doctorData?["patients_count"]?.toString() ?? '0',
            label: 'Patients',
            color: const Color(0xFF64B5F6), // Light blue text
            borderColor: const Color(0xFF1976D2),
            bgColor: const Color(0xFF14243B),
          ),
        ),
        const SizedBox(width: 12),
        // Prescriptions Stat
        Expanded(
          child: _buildStatBox(
            count: doctorData?["prescriptions_count"]?.toString() ?? '0',
            label: 'Prescriptions',
            color: const Color(0xFF4CAF50), // Green text
            borderColor: const Color(0xFF388E3C),
            bgColor: const Color(0xFF14301C),
          ),
        ),
        const SizedBox(width: 12),
        // Rating Stat
        Expanded(
          child: _buildStatBox(
            count: doctorData?["rating"]?.toString() ?? '0.0',
            label: 'Rating',
            color: const Color(0xFFFFB300), // Orange text
            borderColor: const Color(0xFFF57C00),
            bgColor: const Color(0xFF3B2A12),
          ),
        ),
      ],
    );
  }

  // Helper for Individual Stat Boxes
  Widget _buildStatBox({
    required String count,
    required String label,
    required Color color,
    required Color borderColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LOGOUT BUTTON
  // ==========================================
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: () {

  Navigator.pushAndRemoveUntil(
    context,

    MaterialPageRoute(
      builder: (context) =>
           MyApp(),
    ),

    (route) => false,
  );
},
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF2C1414), // Dark red background
          side: const BorderSide(color: Color(0xFFD32F2F)), // Red border
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'Log out',
          style: TextStyle(
              color: Color(0xFFEF5350),
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ==========================================
  // BOTTOM NAVIGATION BAR
  // ==========================================
  Widget _buildBottomNavBar() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorDashboardScreen(doctorId: widget.doctorId),
              ),
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MyScheduleScreen(doctorId: widget.doctorId),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MyPatientsScreen(doctorId: widget.doctorId),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MyRecordsScreen(doctorId: widget.doctorId),
              ),
            );
          } else if (index == 4) {
            // Already on Profile
          }
        },
        backgroundColor: const Color(0xFF121212),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: Colors.white38,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        currentIndex: 4, // Profile tab is active
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
                padding: EdgeInsets.only(bottom: 4, top: 8),
                child: Icon(Icons.home_outlined)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
                padding: EdgeInsets.only(bottom: 4, top: 8),
                child: Icon(Icons.calendar_today_outlined)),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Padding(
                padding: EdgeInsets.only(bottom: 4, top: 8),
                child: Icon(Icons.person_outline)),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Padding(
                padding: EdgeInsets.only(bottom: 4, top: 8),
                child: Icon(Icons.receipt_long_outlined)),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Padding(
                padding: EdgeInsets.only(bottom: 4, top: 8),
                child: Icon(Icons.circle_outlined)),
            activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4, top: 8),
                child: Icon(Icons.circle, color: Color(0xFF1976D2))),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
