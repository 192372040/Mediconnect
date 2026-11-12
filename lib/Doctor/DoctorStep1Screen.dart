import 'package:flutter/material.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/Doctor/DoctorStep2Screen.dart';
import 'package:my_project/Roleselection/RoleSelectionScreen.dart';
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _otpSent = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _otpController = TextEditingController();

  static const Color primary = Color(0xFF2563EB);

  static const Color primaryBg = Color(0xFF242424);

  static const Color inputBg = Color(0xFF1A1A1A);

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    }
  }

  Future<void> _verifyLoginOtp() async {
    String otp = _otpController.text.trim();

    if (otp.isEmpty) {
      _showSnack("Enter the OTP first");
      return;
    }

    var res = await ApiService.verifyOtp(
      _emailController.text.trim(),
      otp,
    );

    print("LOGIN VERIFY RESPONSE: $res");

    if (res["error"] != null) {
      _showSnack(res["error"]);
      return;
    }

    if (res["error"] == null) {
      _showSnack("Verified ✅");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        "user_email",
        _emailController.text,
      );

      await Future.delayed(
        const Duration(seconds: 1),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Step2PersonalDetailsScreen(
            email: _emailController.text,
            doctorId: _emailController.text, // Replace with actual doctor ID if available
          ),        
        ),
      );
    } else {
      _showSnack("Invalid OTP ❌");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: primaryBg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _handleBack,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'MediConnect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Doctor Medical Portal',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Welcome Doctor 👋',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login to access doctor dashboard',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Medical Email',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter medical email',
                  hintStyle: const TextStyle(
                    color: Colors.white24,
                  ),
                  filled: true,
                  fillColor: inputBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: primary,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter OTP',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter OTP',
                  hintStyle: const TextStyle(
                    color: Colors.white24,
                  ),
                  filled: true,
                  fillColor: inputBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: primary,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });

                          if (!_otpSent) {
                            final email = _emailController.text.trim();
                            if (email.isEmpty) {
                              _showSnack("Enter medical email");
                              setState(() {
                                _isLoading = false;
                              });
                              return;
                            }

                            var res = await ApiService.sendOtp(email);

                            if (res["error"] != null) {
                              _showSnack(res["error"]);
                              setState(() {
                                _isLoading = false;
                              });
                              return;
                            }

                            _showSnack(
                              res["message"] ?? "OTP Sent",
                            );

                            setState(() {
                              _otpSent = true;
                              _isLoading = false;
                            });
                          } else {
                            await _verifyLoginOtp();

                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _otpSent ? 'Verify & Continue' : 'Send OTP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}
}
