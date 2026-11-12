import 'package:flutter/material.dart';
import 'package:my_project/Admin/AdProfile.dart';
import 'package:my_project/Admin/BedsS.dart';
import 'package:my_project/Admin/Doctors.dart';
import 'package:my_project/Admin/Analytis.dart';
import 'package:my_project/Admin/Dashboard.dart';
class HospitalProfileScreen extends StatelessWidget {

  final String hospitalId;

  const HospitalProfileScreen({
    Key? key,
    required this.hospitalId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF252525);
    const Color primaryColor = Color(0xFFC7781E);
    const Color cardBgColor = Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hospital profile',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[800], height: 1),
            
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
                        child: const Text(
                          'AH',
                          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Apollo Hospital',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Center(
                      child: Text(
                        'Multi-specialty · Chennai',
                        style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'MED-HOSP-2026-0012',
                          style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Details Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        border: Border.all(color: Colors.grey[800]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Admin name', 'Dr. Suresh Mehta'),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('Year started', '1993'),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('Address', '21 Greams Lane, Chennai'),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('Departments', '18 departments'),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('Total beds', '320 beds'),
                          Divider(color: Colors.grey[800], height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Rating', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                                Row(
                                  children: const [
                                    Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                                    SizedBox(width: 4),
                                    Text('4.8', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
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
                        _buildStatCard('45', 'Doctors', Colors.blue[400]!, cardBgColor),
                        const SizedBox(width: 12),
                        _buildStatCard('320', 'Beds', Colors.green[400]!, cardBgColor),
                        const SizedBox(width: 12),
                        _buildStatCard('31yrs', 'Experience', primaryColor, cardBgColor),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Settings Section
                    const Text(
                      'Settings',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsTile(Icons.adjust, 'Change password', cardBgColor),
                    const SizedBox(height: 12),
                    _buildSettingsTile(Icons.api_outlined, 'Notification settings', cardBgColor),
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
          currentIndex: 4, 
          onTap: (index) {

  // HOME
  if (index == 0) {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) =>
            HospitalDashboardScreen(

          hospitalId: '',

        ),
      ),
    );
  }

  // DOCTORS
  else if (index == 1) {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) =>
            ManageDoctorsScreen(
  hospitalId: hospitalId,
),

      ),
    );
  }

  // BEDS
  else if (index == 2) {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) =>
            const BedManagementScreen( hospitalId: '',),

      ),
    );
  }

  // ANALYTICS
  else if (index == 3) {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) =>
            const AnalyticsScreen( hospitalId: '',),

      ),
    );
  }

  // PROFILE
  else if (index == 4) {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) =>
           const HospitalProfileScreen(
  hospitalId: '',

  

),
      ),
    );
  }
},// 'Profile' is active
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[600], size: 24),
        ],
      ),
    );
  }
}