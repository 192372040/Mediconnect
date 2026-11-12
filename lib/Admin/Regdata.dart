
import 'package:flutter/material.dart';
import '../Patientdashboard/services/api_service.dart';
import 'package:my_project/Admin/Dashboard.dart';
class AdminRegistrationSuccessScreen extends StatefulWidget {
  final String hospitalId;

const AdminRegistrationSuccessScreen({

  Key? key,
  required this.hospitalId,

}) : super(key: key);

@override
State<AdminRegistrationSuccessScreen>
createState() =>
_AdminRegistrationSuccessScreenState();
}

class _AdminRegistrationSuccessScreenState
extends State<AdminRegistrationSuccessScreen> {

Map<String, dynamic>? hospitalData;
int currentIndex = 0;
bool isLoading = true;

@override
void initState() {

  super.initState();

  fetchHospitalSummary();
}

void fetchHospitalSummary() async {

  var res =
      await ApiService
          .getAdminHospitalSummary(

    widget.hospitalId,
  );
print(res);
  setState(() {

    hospitalData =
        res["hospital"];

    isLoading = false;
  });
}

@override
Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF252525);
    const Color primaryColor = Color(0xFFC7781E); // Orange
    const Color cardBgColor = Color(0xFF1E1E1E);
    const Color successGreen = Color(0xFF187A4D);
    const Color dotColor = Color(0xFF00A86B); // Teal-ish green for progress
if (isLoading) {

  return const Scaffold(

    body: Center(
      child:
          CircularProgressIndicator(),
    ),
  );
}
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Progress Bar Area
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(dotColor),
                        const SizedBox(width: 6),
                        _buildDot(dotColor),
                        const SizedBox(width: 6),
                        _buildDot(dotColor),
                        const SizedBox(width: 6),
                        _buildDot(dotColor),
                        const SizedBox(width: 6),
                        Container(
                          width: 24,
                          height: 6,
                          decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Step 4 of 4',
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
            Divider(color: dotColor, height: 1, thickness: 1.5),
            
            // Scrollable Body Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Success Checkmark
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: successGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title and Subtitle
                    const Text(
                      'Registration\nsuccessful!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Welcome to MediConnect Hospital Portal',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 32),
                    
                    // Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        border: Border.all(color: Colors.grey[800]!),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'YOUR HOSPITAL SUMMARY',
                            style: TextStyle(
                              color: Colors.grey, 
                              fontSize: 12, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: 1.2
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Highlighted Hospital ID Box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: primaryColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Hospital ID', 
                                      style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)
                                    ),
                                    const SizedBox(height: 4),
                                     Text(
                                      widget.hospitalId,
                                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.copy_outlined, color: primaryColor, size: 24),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Details List
                          _buildDetailRow(

  'Hospital name',

  hospitalData?['hospital_name']
      ?? '',

),
                          _buildDetailRow(

  'Admin name',

  hospitalData?['admin_name']
      ?? '',

),
                          _buildDetailRow(

  'Hospital type',

  hospitalData?['hospital_type']
      ?? '',

),
                          _buildDetailRow(

  'Year started',

  hospitalData?['established_year']
      ?? '',

),
                          _buildDetailRow(

  'Address',

  hospitalData?['hospital_address']
      ?? '',

),
                          _buildDetailRow(
  'Departments',
  hospitalData?['departments']
      ?? '18 departments',
),
                          _buildDetailRow(
  'Total beds',
  hospitalData?['total_beds']
      ?? '320 beds',
),
                          _buildDetailRow(

  'Email',

  hospitalData?['admin_email']
      ?? '',

),
                          _buildDetailRow('Login with', 'Hospital ID + Password', valueColor: primaryColor, isLast: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Alert Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        border: Border.all(color: primaryColor.withOpacity(0.8)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: primaryColor, size: 24),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Your hospital is under review. You will receive an email once verified by MediConnect.',
                              style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Bottom Button
                    ElevatedButton(
                     onPressed: () {

  Navigator.push(

    context,

    MaterialPageRoute(

      builder: (context) =>
          HospitalDashboardScreen(
        hospitalId: widget.hospitalId,
      ),

    ),
  );
},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Go to Admin Dashboard',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }

  // Helper widget for the progress dots
  Widget _buildDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // Helper widget for rendering key-value rows with dividers
  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: Colors.grey[800], height: 1),
      ],
    );
  }
}
