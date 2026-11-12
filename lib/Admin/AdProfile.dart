import 'package:flutter/material.dart';
import 'package:my_project/Admin/BedsS.dart';
import 'package:my_project/Admin/Dashboard.dart';
import 'package:my_project/Admin/Doctors.dart';
import 'package:my_project/Admin/Analytis.dart';
import 'package:my_project/Admin/Hospitaldetails.dart';
import 'package:my_project/Admin/Regdata.dart';
import 'package:my_project/LoginScreen.dart';
import 'package:my_project/Roleselection/RoleSelectionScreen.dart';
import '../Patientdashboard/services/api_service.dart';

class HospitalProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? hospitalData;
  final String hospitalId;
  const HospitalProfileScreen({
    super.key,
    required this.hospitalData,
    required this.hospitalId,
  });

  @override
  State<HospitalProfileScreen> createState() => _HospitalProfileScreenState();
}

class _HospitalProfileScreenState extends State<HospitalProfileScreen> {
  Map<String, dynamic>? hospitalData;
  Map<String, dynamic>? analyticsData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    hospitalData = widget.hospitalData;
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    if (hospitalData == null) {
      final res = await ApiService.getAdminHospitalSummary(widget.hospitalId);
      hospitalData = res["hospital"];
    }
    final analyticsRes =
        await ApiService.getHospitalAnalytics(widget.hospitalId);
    if (analyticsRes["success"] == true) {
      analyticsData = analyticsRes;
    }
    setState(() => isLoading = false);
  }

  void _showChangePasswordDialog() {
    final TextEditingController newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Change Password',
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: newPasswordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: Colors.grey)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () {
                // Mock change password
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Password changed successfully')));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC7781E)),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
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

    String hospitalName = hospitalData?['hospital_name'] ?? 'Hospital Name';
    String initials = hospitalName.length >= 2
        ? hospitalName.substring(0, 2).toUpperCase()
        : 'H';
    String address = hospitalData?['hospital_address'] ?? 'Address details';
    String adminName = hospitalData?['admin_name'] ?? 'Admin Name';
    String hospitalRegId = hospitalData?['hospital_id'] ?? widget.hospitalId;

    int totalDoctors = int.tryParse(analyticsData?['total_doctors']?.toString() ?? '0') ?? 0;
    int totalBeds = int.tryParse(analyticsData?['total_beds']?.toString() ?? '0') ?? 0;
    double rating = double.tryParse(analyticsData?['hospital_rating']?.toString() ?? '0.0') ?? 0.0;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                      'Hospital profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HospitalDetailsPage(
                              email: hospitalData?['admin_email'] ?? hospitalData?['email'] ?? ''),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
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
                    // Profile Header
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        hospitalName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Center(
                      child: Text(
                        'Multi-specialty Hospital',
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hospitalRegId,
                          style: const TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Details Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        border: Border.all(color: Colors.grey[800]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Admin name', adminName),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('Address', address),
                          Divider(color: Colors.grey[800], height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Rating',
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14)),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Color(0xFFFFC107), size: 16),
                                    const SizedBox(width: 4),
                                    Text(rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats Row
                    Row(
                      children: [
                        _buildStatCard('$totalDoctors', 'Doctors',
                            Colors.blue[400]!, cardBgColor),
                        const SizedBox(width: 12),
                        _buildStatCard('$totalBeds', 'Beds', Colors.green[400]!,
                            cardBgColor),
                        const SizedBox(width: 12),
                        _buildStatCard(
                            'Active', 'Status', primaryColor, cardBgColor),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Settings Section
                    const Text(
                      'Settings',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // Settings Options
                    GestureDetector(
                      onTap: _showChangePasswordDialog,
                      child: _buildSettingsTile(
                          Icons.adjust, 'Change password', cardBgColor),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HospitalDetailsPage(
                              email: hospitalData?['admin_email'] ?? hospitalData?['email'] ?? '',
                            ),
                          ),
                        );
                      },
                      child: _buildSettingsTile(Icons.crop_square,
                          'Edit hospital details', cardBgColor),
                    ),
                    const SizedBox(height: 20),

                    // Log out Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RoleSelectionScreen()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A1C1C), // Deep red tint
                          border: Border.all(color: Colors.red[400]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Log out',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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
          currentIndex: 4,
          onTap: (index) {
            if (index == 0) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HospitalDashboardScreen(
                          hospitalId: widget.hospitalId)));
            } else if (index == 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ManageDoctorsScreen(hospitalId: widget.hospitalId)));
            } else if (index == 2) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BedManagementScreen(hospitalId: widget.hospitalId)));
            } else if (index == 3) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AnalyticsScreen(hospitalId: widget.hospitalId)));
            }
          }, // 'Profile' is active
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
                    child: Icon(Icons.person_outline)),
                label: 'Doctors'),
            BottomNavigationBarItem(
                icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.medical_services_outlined)),
                label: 'Beds'),
            BottomNavigationBarItem(
                icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.show_chart)),
                label: 'Analytics'),
            BottomNavigationBarItem(
                icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.circle_outlined)),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // Helper widget for rendering key-value rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Helper widget for the stat boxes (Doctors, Beds, Experience)
  Widget _buildStatCard(
      String value, String label, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: color.withAlpha((0.5 * 255).round())),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // Helper widget for list items in Settings
  Widget _buildSettingsTile(IconData icon, String title, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.grey[800]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[600], size: 24),
        ],
      ),
    );
  }
}
