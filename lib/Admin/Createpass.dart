import 'package:flutter/material.dart';
import '../Patientdashboard/services/api_service.dart';
import 'package:my_project/Admin/Regdata.dart';
class CreatePasswordPage extends StatefulWidget {
  final String hospitalId;

const CreatePasswordPage({

  Key? key,
  required this.hospitalId,

}) : super(key: key);

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Validation States
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  
  

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordController.dispose();

_confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

  int _calculateStrength() {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasNumber) score++;
    return score; // Max 3 criteria -> 3 bars green
  }

  bool _doesPasswordMatch() {
    return _passwordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF22201F);   // Dark charcoal
    const Color orangeColor = Color(0xFFB87518);       // Ochre/orange accent
    const Color darkInputColor = Color(0xFF1B1A19);    // Input background
    const Color labelColor = Color(0xFF888888);        // Muted gray
    const Color activeBorderColor = Color(0xFFC07D1C); // Active orange border
    const Color greenColor = Color(0xFF0F7C5D);         // Green accent
    const Color lightGreenColor = Color(0xFF1BE1A0);    // Bright green text

    final int strengthScore = _calculateStrength();
    final bool passwordsMatch = _doesPasswordMatch();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Back Button, Steps Progress, and Text
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
                  
                  // Progress Dots (Step Indicators for Step 3 of 4)
                  Row(
                    children: [
                      // Step 1: Green
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: greenColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Step 2: Green
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: greenColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Step 3: Active Orange Pill
                      Container(
                        width: 24,
                        height: 8,
                        decoration: BoxDecoration(
                          color: orangeColor,
                          borderRadius: BorderRadius.circular(4),
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
                    'Step 3 of 4',
                    style: TextStyle(
                      color: orangeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Progress Bar (75% filled)
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
                    widthFactor: 0.75, // 3 of 4 = 75%
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
              const SizedBox(height: 36),
              
              // Lock Icon Header
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1813),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: orangeColor,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: orangeColor,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title and Subtitle
              const Center(
                child: Text(
                  'Create password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Use your Hospital ID to login',
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              
              // Hospital ID Display Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1A14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: activeBorderColor.withOpacity(0.4),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Hospital ID (use this to login)',
                      style: TextStyle(
                        color: activeBorderColor.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.hospitalId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Create Password Field
              const Text(
                'Create password',
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
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
                        color: labelColor,
                        size: 20,
                      ),
                  onPressed: () {
  setState(() {
    _obscurePassword = !_obscurePassword;
  });
},
                       
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Dynamic Strength Indicator Bars (4 segments)
              Row(
                children: List.generate(4, (index) {
                  // Fill active bars based on score. If max strength (3 out of 3), color first 3 green.
                  final bool isActive = index < strengthScore;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0 : 4,
                        right: index == 3 ? 0 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? lightGreenColor : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              
              // Strength Text Status
              if (strengthScore > 0)
                Text(
                  strengthScore == 3 ? 'Strong password' : (strengthScore == 2 ? 'Medium password' : 'Weak password'),
                  style: TextStyle(
                    color: strengthScore == 3 ? lightGreenColor : (strengthScore == 2 ? orangeColor : Colors.red),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 24),
              
              // Confirm Password Field
              const Text(
                'Confirm password',
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
                    color: passwordsMatch ? lightGreenColor.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                    width: 1.2,
                  ),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: InputBorder.none,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (passwordsMatch)
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.check,
                              color: lightGreenColor,
                              size: 20,
                            ),
                          ),
                        IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
                            color: labelColor,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Password Requirements Container Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1A19),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildRequirementRow('At least 8 characters', _hasMinLength, lightGreenColor),
                    const SizedBox(height: 12),
                    _buildRequirementRow('One uppercase letter', _hasUppercase, lightGreenColor),
                    const SizedBox(height: 12),
                    _buildRequirementRow('One number', _hasNumber, lightGreenColor),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              
              // Submit & Register Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (strengthScore == 3 && passwordsMatch) 
                      ? _handleSubmitAndRegister 
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeColor,
                    disabledBackgroundColor: orangeColor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Submit & register',
                    style: TextStyle(
                      color: (strengthScore == 3 && passwordsMatch) ? Colors.white : Colors.white60,
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
    );
  }

  // Helper requirement item widget
  Widget _buildRequirementRow(String text, bool isMet, Color greenColor) {
    return Row(
      children: [
        Icon(
          Icons.check,
          color: isMet ? greenColor : Colors.white.withOpacity(0.15),
          size: 18,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: isMet ? greenColor : Colors.white.withOpacity(0.3),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _handleSubmitAndRegister() async {

  if (_passwordController.text !=
      _confirmPasswordController.text) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content:
            Text("Passwords do not match"),
      ),
    );

    return;
  }

  var res =
      await ApiService.saveAdminPassword(

    hospitalId:
        widget.hospitalId,

    password:
        _passwordController.text,
  );

  ScaffoldMessenger.of(context)
      .showSnackBar(

    SnackBar(
      content:
          Text(res["message"]),
    ),
  );
  Navigator.push(

    context,

    MaterialPageRoute(

      builder: (context) =>
          AdminRegistrationSuccessScreen (hospitalId:
      widget.hospitalId,
),

    ),
  );

}
}