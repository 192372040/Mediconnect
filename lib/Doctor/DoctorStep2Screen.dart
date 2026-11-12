
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/Doctor/DoctorStep3Screen.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';
class Step2PersonalDetailsScreen extends StatefulWidget {
  final String? email; // Accepts email from Step 1
  final String doctorId;
  const Step2PersonalDetailsScreen({
  Key? key,
  this.email,
  required this.doctorId,
}) : super(key: key);

  @override
  State<Step2PersonalDetailsScreen> createState() => _Step2PersonalDetailsScreenState();
}

class _Step2PersonalDetailsScreenState extends State<Step2PersonalDetailsScreen> {
  // Pre-filled with data from your image
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  
  int _age = 38;
  String _selectedGender = 'Male';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
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
                      'Basic details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tell us about yourself',
                      style: TextStyle(
                        color: Color(0xFF8E8E8E),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    _buildLabel('Full name'),
                    _buildNameField(),
                    const SizedBox(height: 24),
                    
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _buildAgeCounter()),
                        const SizedBox(width: 16),
                        Expanded(flex: 5, child: _buildGenderSelection()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    _buildLabel('Mobile number'),
                    _buildMobileField(),
                    const SizedBox(height: 24),
                    
                    _buildLabel('Date of birth'),
                    _buildDobField(),
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
          // Step Indicators
          Row(
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF00A36C), shape: BoxShape.circle)), // Green dot for Step 1
              const SizedBox(width: 6),
              Container(
                width: 24,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF195E9A), // Blue pill for Step 2
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
            'Step 2 of 5',
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
          width: MediaQuery.of(context).size.width * 0.4, // Represents 2/5 progress
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

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'Enter full name',
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
          borderSide: const BorderSide(color: Color(0xFF195E9A)), // Blue border matching image
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF195E9A), width: 2),
        ),
      ),
    );
  }

  Widget _buildAgeCounter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Age'),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3A3A3A)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_age > 0) setState(() => _age--);
                  },
                  child: Container(
                    color: Colors.transparent, // Expands tap area
                    alignment: Alignment.center,
                    child: const Text(
                      '-',
                      style: TextStyle(color: Color(0xFF195E9A), fontSize: 24, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              Container(
                width: 40,
                color: const Color(0xFF111111), // Darker center segment
                alignment: Alignment.center,
                child: Text(
                  '$_age',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _age++);
                  },
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: const Text(
                      '+',
                      style: TextStyle(color: Color(0xFF195E9A), fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Gender'),
        Row(
          children: [
            Expanded(child: _buildGenderOption('Male')),
            const SizedBox(width: 8),
            Expanded(child: _buildGenderOption('Female')),
            const SizedBox(width: 8),
            Expanded(child: _buildGenderOption('Other')),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String title) {
    bool isSelected = _selectedGender == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = title),
      child: Container(
        height: 56, // Matches the age counter height perfectly
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF195E9A) : const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF195E9A) : const Color(0xFF3A3A3A),
          ),
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF8E8E8E),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileField() {
    return Row(
      children: [
        Container(
          height: 56,
          width: 70,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3A3A3A)),
          ),
          child: const Text(
            '+91',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Enter mobile number',
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
                borderSide: const BorderSide(color: Color(0xFF195E9A)), // Blue border matching image
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF195E9A), width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDobField() {
    return TextField(
      controller: _dobController,
      readOnly: true, // Prevents typing, opens picker instead
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime(1988, 3, 15), // Default from image
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          // Manual basic formatting to match image without external packages
          List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
          setState(() {
            _dobController.text = "${pickedDate.day} ${months[pickedDate.month - 1]} ${pickedDate.year}";
          });
        }
      },
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'Select Date of Birth',
        hintStyle: const TextStyle(color: Color(0xFF5A5A5A)),
        filled: true,
        fillColor: const Color(0xFF1C1C1C),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        suffixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF8E8E8E), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)), // Grey border matching image
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
              final fullName = _nameController.text.trim();
              final phone = _phoneController.text.trim();
              final dob = _dobController.text.trim();

              if (fullName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your full name'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              if (phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your mobile number'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              if (dob.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select your date of birth'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              String email = (widget.email != null && widget.email!.isNotEmpty)
                  ? widget.email!
                  : '';
              if (email.isEmpty) {
                final prefs = await SharedPreferences.getInstance();
                if (!mounted) return;
                email = prefs.getString("user_email") ?? "";
              }

              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email not found. Please restart from Step 1.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              setState(() => _isLoading = true);

              try {
                var res = await ApiService.saveDoctorDetails(
                  email: email,
                  fullName: fullName,
                  age: _age,
                  gender: _selectedGender,
                  phone: phone,
                  dob: dob,
                );

                if (!mounted) return;

                if (res != null && res["message"] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Step3ProfessionalDetailsScreen(
                        doctorId: res["doctor_id"] ?? widget.doctorId,
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