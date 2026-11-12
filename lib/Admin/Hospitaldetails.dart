import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Patientdashboard/services/api_service.dart';
import 'package:my_project/Admin/Createpass.dart';
class HospitalDetailsPage extends StatefulWidget {
  final String email;

const HospitalDetailsPage({

  Key? key,
  required this.email,

}) : super(key: key);

  @override
  State<HospitalDetailsPage> createState() => _HospitalDetailsPageState();
}

class _HospitalDetailsPageState extends State<HospitalDetailsPage> {
  final TextEditingController _hospitalNameController = TextEditingController();
  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  
  // Hospital Type Selection State
  String _selectedType = 'Multi-specialty';
  
  // Hospital ID (fetched/verified from DB)
 final TextEditingController _hospitalIdController =
    TextEditingController();

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _adminNameController.dispose();
    _addressController.dispose();
    _yearController.dispose();
    _hospitalIdController.dispose();
    super.dispose();
  }

  // Copy ID to Clipboard
  void _copyToClipboard() {
   Clipboard.setData(
  ClipboardData(
    text: _hospitalIdController.text,
  ),
);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hospital ID copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Custom Color Palette from the design image
    const Color backgroundColor = Color(0xFF22201F);   // Dark charcoal
    const Color orangeColor = Color(0xFFB87518);       // Ochre/orange accent
    const Color darkInputColor = Color(0xFF1B1A19);    // Input fields background
    const Color labelColor = Color(0xFF888888);        // Muted gray for labels
    const Color activeBorderColor = Color(0xFFC07D1C); // Active orange border

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(3),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar with Back Button, Step Indicator and Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: orangeColor,
                          size: 28,
                        ),
                      ),
                    ),
                    
                    // Progress Dots (Step Indicators for Step 2 of 4)
                    Row(
                      children: [
                        // Step 1: Completed (Green)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0F7C5D),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Step 2: Active (Orange Pill)
                        Container(
                          width: 24,
                          height: 8,
                          decoration: BoxDecoration(
                            color: orangeColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Step 3: Inactive
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF444444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Step 4: Inactive
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF444444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    
                    // Step Text
                    const Text(
                      'Step 2 of 4',
                      style: TextStyle(
                        color: orangeColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Progress Bar (50% filled)
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.50, // 2 of 4 = 50%
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: orangeColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Title & Subtitle
                const Text(
                  'Hospital details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tell us about your hospital',
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                
                // Hospital Name
                const Text(
                  'Hospital name',
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: darkInputColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: activeBorderColor,
                      width: 1.2,
                    ),
                  ),
                  child: TextField(
                    controller: _hospitalNameController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter hospital name',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Admin Name
                const Text(
                  'Admin name',
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: darkInputColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.2,
                    ),
                  ),
                  child: TextField(
                    controller: _adminNameController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter admin name',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Hospital Address
                const Text(
                  'Hospital address',
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: darkInputColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.2,
                    ),
                  ),
                  child: TextField(
                    controller: _addressController,
                    maxLines: 3,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter hospital address',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Hospital Type Selection
                const Text(
                  'Hospital type',
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTypeButton('Multi-specialty', activeBorderColor),
                    const SizedBox(width: 8),
                    _buildTypeButton('General', activeBorderColor),
                    const SizedBox(width: 8),
                    _buildTypeButton('Clinic', activeBorderColor),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Year Established
                const Text(
                  'Year established',
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: darkInputColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.2,
                    ),
                  ),
                  child: TextField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter year established',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Hospital ID Container (Verified in Database)
               const Text(
  'Hospital ID',
  style: TextStyle(
    color: labelColor,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  ),
),

const SizedBox(height: 8),

Container(
  height: 56,
  decoration: BoxDecoration(
    color: darkInputColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
      width: 1.2,
    ),
  ),
  child: TextField(
    controller: _hospitalIdController,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    decoration: const InputDecoration(
      hintText: "Enter hospital ID",
      hintStyle: TextStyle(
        color: Colors.grey,
      ),
      contentPadding:
          EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: InputBorder.none,
    ),
  ),
),

const SizedBox(height: 32),
                
                // Verify & Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      _handleSaveAndContinue();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Verify & continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Hospital Type Selector Helper Widget
  Widget _buildTypeButton(String label, Color activeColor) {
    final bool isSelected = _selectedType == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = label;
          });
        },
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E1A14) : const Color(0xFF1B1A19),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeColor : Colors.white.withOpacity(0.05),
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : const Color(0xFF666666),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

 void _handleSaveAndContinue() async {

  var verifyRes =
      await ApiService.verifyHospitalId(

    _hospitalIdController.text,
  );

  if (verifyRes["error"] != null) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(
          verifyRes["error"],
        ),
      ),
    );

    return;
  }

  var saveRes =
      await ApiService.saveAdminHospital(

  adminEmail:
    widget.email,

    hospitalName:
        _hospitalNameController.text,

    adminName:
        _adminNameController.text,

    hospitalAddress:
        _addressController.text,

    hospitalType:
        _selectedType,

    establishedYear:
        _yearController.text,

    hospitalId:
        _hospitalIdController.text,
  );

  ScaffoldMessenger.of(context)
      .showSnackBar(

    SnackBar(
      content: Text(
        saveRes["message"],
      ),
    ),
  );

  Navigator.push(

    context,

    MaterialPageRoute(

      builder: (context) =>
          CreatePasswordPage(

  hospitalId:
      _hospitalIdController.text,

),
    ),
  );
}
}