import 'package:flutter/material.dart';
import 'package:my_project/Doctor/DoctorStep4Screen.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';

class Step3ProfessionalDetailsScreen
    extends StatefulWidget {

  final String doctorId;

  const Step3ProfessionalDetailsScreen({
    Key? key,
    required this.doctorId,
  }) : super(key: key);

  @override
  State<Step3ProfessionalDetailsScreen> createState() => _Step3ProfessionalDetailsScreenState();
}

class _Step3ProfessionalDetailsScreenState extends State<Step3ProfessionalDetailsScreen> {
  // Pre-filled with data from your images
  late TextEditingController _doctorIdController;
  late TextEditingController _qualificationController;

  late TextEditingController _specializationController;
  late TextEditingController _experienceController;
  late TextEditingController _licenseController;
  late TextEditingController _feeController;
  bool _isLoading = false;

  @override
void initState() {
  super.initState();

  _doctorIdController =
      TextEditingController(
    text: widget.doctorId,
  );

  _qualificationController =
      TextEditingController(
  );

  _specializationController =
      TextEditingController(
    
  );

  _experienceController =
      TextEditingController();

  _licenseController =
      TextEditingController(
    
  );

  _feeController =
      TextEditingController(
    
  );
}
   

  @override
  void dispose() {
    _doctorIdController.dispose();
    _qualificationController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _licenseController.dispose();
    _feeController.dispose();
    super.dispose();
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
                    const Text(
                      'Professional details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your medical credentials',
                      style: TextStyle(
                        color: Color(0xFF8E8E8E),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    _buildLabel('Doctor ID (auto generated)'),
                    _buildDoctorIdField(),
                    const SizedBox(height: 24),
                    
                    _buildLabel('Qualification'),
                    _buildQualificationField(),
                    const SizedBox(height: 24),
                    
                    _buildLabel('Specialization'),
                    _buildSpecializationField(),
                    const SizedBox(height: 24),
                    
                    _buildLabel('Experience (years)'),
                    _buildExperienceField(),
                    const SizedBox(height: 24),
                    
                    _buildLabel('License number'),
                    _buildLicenseField(),
                    const SizedBox(height: 24),
                    
                    _buildLabel('Consultation fee (₹)'),
                    _buildFeeField(),
                    const SizedBox(height: 48),
                    
                    _buildContinueButton(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF195E9A), size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Step Indicators (2 Green, 1 Blue Pill, 2 Grey)
          Row(
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF00A36C), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF00A36C), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(
                width: 24,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF195E9A),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF4A4A4A), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF4A4A4A), shape: BoxShape.circle)),
            ],
          ),
          // Step Text
          const Text(
            'Step 3 of 5',
            style: TextStyle(
              color: Color(0xFF195E9A),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Stack(
      children: [
        Container(
          height: 2,
          width: double.infinity,
          color: const Color(0xFF3A3A3A),
        ),
        Container(
          height: 2,
          width: MediaQuery.of(context).size.width * 0.6, // Represents 3/5 progress
          color: const Color(0xFF195E9A),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF8E8E8E),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDoctorIdField() {
    return TextField(
      controller: _doctorIdController,
      readOnly: true,
      style: const TextStyle(
        color: Color(0xFF4A89C8), // Blue text for auto-generated ID
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1C1C1C),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        suffixIcon: IconButton(
          icon: const Icon(Icons.copy_outlined, color: Color(0xFF4A89C8), size: 20),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Doctor ID copied!'), behavior: SnackBarBehavior.floating),
            );
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF195E9A)), // Blue border matching image
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF195E9A), width: 2),
        ),
      ),
    );
  }

  Widget _buildQualificationField() {
    return TextField(
      controller: _qualificationController,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: 'e.g. MBBS, MD',
        hintStyle: const TextStyle(color: Color(0xFF5A5A5A)),
        filled: true,
        fillColor: const Color(0xFF1C1C1C),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)), // Grey border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF195E9A), width: 2),
        ),
      ),
    );
  }

  Widget _buildSpecializationField() {
    return TextField(
      controller: _specializationController,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: 'e.g. Cardiologist',
        hintStyle: const TextStyle(color: Color(0xFF5A5A5A)),
        filled: true,
        fillColor: const Color(0xFF1C1C1C),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF195E9A)), // Blue border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF195E9A), width: 2),
        ),
      ),
    );
  }

  Widget _buildExperienceField() {
    return TextField(
      controller: _experienceController,
      keyboardType: TextInputType.number,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      decoration: const InputDecoration(
        hintText: 'Enter experience',
        hintStyle: TextStyle(color: Color(0xFF5A5A5A)),
        // Notice: No fill color, just a clean underline to match the design exactly
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF3A3A3A)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF195E9A), width: 2),
        ),
      ),
    );
  }

  Widget _buildLicenseField() {
    return TextField(
      controller: _licenseController,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: 'e.g. MCI-12345',
        hintStyle: const TextStyle(color: Color(0xFF5A5A5A)),
        filled: true,
        fillColor: const Color(0xFF1C1C1C),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF195E9A), width: 2),
        ),
      ),
    );
  }

  Widget _buildFeeField() {
    return TextField(
      controller: _feeController,
      keyboardType: TextInputType.number,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 16.0, right: 8.0),
          child: Icon(Icons.currency_rupee, color: Color(0xFF00A36C), size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: const Color(0xFF1C1C1C),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF195E9A), width: 2),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () async {
              final qualification = _qualificationController.text.trim();
              final specialization = _specializationController.text.trim();
              final experience = _experienceController.text.trim();
              final licenseNumber = _licenseController.text.trim();
              final fee = _feeController.text.trim();

              if (qualification.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your qualification (e.g. MBBS)'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              if (specialization.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your specialization'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              if (experience.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your years of experience'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              if (licenseNumber.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your medical license number'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              if (fee.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your consultation fee'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              setState(() => _isLoading = true);

              try {
                var res = await ApiService.saveProfessionalDetails(
                  doctorId: widget.doctorId,
                  qualification: qualification,
                  specialization: specialization,
                  experience: experience,
                  licenseNumber: licenseNumber,
                  consultationFee: fee,
                );

                if (!mounted) return;

                if (res != null && res["message"] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Step4HospitalDetailsScreen(
                        doctorId: widget.doctorId,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        res?["error"] ?? "Failed to save details. Please try again.",
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: $e"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF195E9A),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
