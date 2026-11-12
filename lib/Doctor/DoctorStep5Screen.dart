import 'package:flutter/material.dart';
import 'package:my_project/Doctorpass.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';
class Step5SuccessScreen
    extends StatefulWidget {

  final String doctorId;

  const Step5SuccessScreen({
    Key? key,
    required this.doctorId,
  }) : super(key: key);

  @override
  State<Step5SuccessScreen>
      createState() =>
          _Step5SuccessScreenState();
}
class _Step5SuccessScreenState
    extends State<Step5SuccessScreen> {

  Map<String, dynamic>? doctorData;

  @override
  void initState() {
    super.initState();

    loadDoctorData();
  }

  Future loadDoctorData() async {

    var res =
        await ApiService
            .getDoctorSummary(
      widget.doctorId,
    );

    print(res);

    setState(() {
      doctorData = res;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282828), // Dark background matching the image
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    _buildSuccessHeader(),
                    const SizedBox(height: 32),
                    _buildProfileSummaryCard(context),
                    const SizedBox(height: 24),
                    _buildReviewNotice(),
                    const SizedBox(height: 32),
                    _buildDashboardButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Centering because no back button
        children: [
          const Spacer(),
          // Step Indicators (4 Green Dots, 1 Blue Pill)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(4, (index) => Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Container(
                  width: 6, 
                  height: 6, 
                  decoration: const BoxDecoration(
                    color: Color(0xFF00A36C), 
                    shape: BoxShape.circle
                  )
                ),
              )),
              Container(
                width: 24,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF195E9A),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Step Text
          const Text(
            'Step 5 of 5',
            style: TextStyle(
              color: Color(0xFF00A36C), // Green text for final step
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 3,
      width: double.infinity,
      color: const Color(0xFF00A36C), // Fully green progress bar
    );
  }

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF0E6945), // Dark green pill background
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Registration\nsuccessful!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Welcome to MediConnect Medical\nPortal',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF8E8E8E),
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR PROFILE SUMMARY',
            style: TextStyle(
              color: Color(0xFF5A5A5A),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          
          // Doctor ID Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2634),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF195E9A)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [
                    Text(
                      'Doctor ID',
                      style: TextStyle(
                        color: Color(0xFF4A89C8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                   Text(
  doctorData?["doctor_id"] ?? "",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.copy_outlined, color: Color(0xFF4A89C8)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied!'), behavior: SnackBarBehavior.floating),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Summary Details List
      _buildSummaryRow(
  'Name',
  doctorData?["full_name"] ?? "",
),

_buildSummaryRow(
  'Specialization',
  doctorData?["specialization"] ?? "",
),

_buildSummaryRow(
  'License',
  doctorData?["license_number"] ?? "",
),

_buildSummaryRow(
  'Hospital',
  doctorData?["hospital_name"] ?? "",
),

_buildSummaryRow(
  'Department',
  doctorData?["department"] ?? "",
),

_buildSummaryRow(
  'Working days',
  doctorData?["working_days"] ?? "",
),

_buildSummaryRow(
  'Timing',
  "${doctorData?["start_time"] ?? ""} - ${doctorData?["end_time"] ?? ""}",
),

_buildSummaryRow(
  'Fee',
  "₹${doctorData?["consultation_fee"] ?? ""}",
  valueColor: const Color(0xFF00A36C),
),

_buildSummaryRow(
  'Mode',
  doctorData?["consultation_mode"] ?? "",
),
        ],
      ),
    );
  }

  // Helper method to keep code clean and avoid repetition
  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8E8E8E),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1F11), // Very dark orange/brown background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB35A00)), // Orange border
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFE68A00), // Orange icon
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your profile is under review. You will receive an email once verified by MediConnect.',
              style: TextStyle(
                color: Color(0xFFE68A00), // Orange text
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Handle navigation to the main Doctor Dashboard
        Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) =>
        SetupPasswordScreen(doctorId: widget.doctorId),
  ),
);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF195E9A),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: const Text(
        'Create Password',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
