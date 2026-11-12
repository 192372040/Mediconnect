import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart'; // ADDED: Biometric import
import 'package:my_project/Patientdashboard/services/api_service.dart';
import 'Patientdashboard/PatientRegistrationScreen/Page2.dart';
import 'Patientdashboard/PatientDashboardScreen.dart';
import 'Patientdashboard/PatientRegistrationScreen/Page1.dart'; 
import 'package:shared_preferences/shared_preferences.dart';// adjust path
class LoginScreen extends StatefulWidget {
  
  const LoginScreen({Key? key}) : super(key: key);
   
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _otpSent = false;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();

  // ADDED: Local Auth instance
  final LocalAuthentication auth = LocalAuthentication();
final TextEditingController _otpController = TextEditingController();
  // Colors matching your design
  static const Color primary = Color(0xFF167B58);
  static const Color primaryBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF1A1A1A);
  static const Color fingerprintBg = Color(0xFF1A2433);
  static const Color fingerprintText = Color(0xFF4A90E2);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
Future<void> _verifyLoginOtp() async {
  String otp = _otpController.text.trim();

  var res = await ApiService.verifyOtp(
    _emailController.text.trim(),
    otp,
  );

  print("LOGIN VERIFY RESPONSE: $res");

  if (res["message"] != null &&
      res["message"].toString().toLowerCase().contains("login")) {

    print("Login success ✅");

    _showSnack("Login successful ✅");

// ✅ SAVE USER EMAIL
final prefs = await SharedPreferences.getInstance();
await prefs.setString("user_email", res["user"]["email"] ?? "");
await prefs.setString("user_name", res["user"]["name"] ?? "");
await prefs.setString("patient_id", res["user"]["patient_id"] ?? "");
await prefs.setString("phone", res["user"]["phone"] ?? "");
await prefs.setString("blood_group", res["user"]["blood_group"] ?? "");
await prefs.setString("gender", res["user"]["gender"] ?? "");
await prefs.setInt("age", res["user"]["age"] ?? 0);
await Future.delayed(const Duration(seconds: 1));

Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    settings: const RouteSettings(name: '/patient_dashboard'),
    builder: (context) => PatientDashboardScreen(user: res["user"]),
  ),
);

  } else if (res["message"] != null &&
      res["message"].toString().toLowerCase().contains("not registered")) {

    print("User not registered → go to signup");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Step2PersonalDetailsScreen(
          email: _emailController.text.trim(),
        ),
      ),
    );

  } else {
    _showSnack("Invalid OTP ❌");
  }
}
  // ADDED: Biometric Authentication Function
  // ==========================================
  Future<void> _authenticateWithBiometrics() async {
    try {
      // Check if device supports biometrics
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        _showSnack('Biometrics are not supported on this device.');
        return;
      }

      // Trigger the fingerprint scanner
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to login to MediConnect',
        options: const AuthenticationOptions(
          biometricOnly: true, // Forces Fingerprint or FaceID
          stickyAuth: true, // Keeps scanner active if app goes to background
        ),
      );

     if (didAuthenticate) {
  _showSnack('Fingerprint matched! Logging in...');

  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString("user_email");

  if (email != null) {
  await Future.delayed(const Duration(seconds: 1));

  String? name = prefs.getString("user_name");
  String? patientId = prefs.getString("patient_id");
String? phone = prefs.getString("phone");
String? bloodGroup = prefs.getString("blood_group");
String? gender = prefs.getString("gender");
int? age = prefs.getInt("age");

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      settings: const RouteSettings(name: '/patient_dashboard'),
      builder: (context) => PatientDashboardScreen(
       user: {
  "name": name ?? "User",
  "email": email ?? "",
  "patient_id": patientId ?? "",
  "phone": phone ?? "",
  "blood_group": bloodGroup ?? "",
  "gender": gender ?? "",
  "age": age ?? 0,
},   ),
    ),
  );
}else {
    _showSnack("Please login with OTP first");
  }
}else {
        _showSnack('Authentication cancelled.');
      }
    } catch (e) {
      _showSnack('Error using biometrics: $e');
    }
  }

  // Helper for showing messages
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
    return Scaffold(
      backgroundColor: primaryBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // App Logo
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

              // App Name & Subtitle
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
                  'Your health companion',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Welcome Text
              const Text(
                'Welcome back! 👋',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login to continue your health journey',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 32),

              // Email Input
              const Text(
                'Email address',
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
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Enter your email address',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: inputBg,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primary, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primary, width: 2),
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
  style: const TextStyle(color: Colors.white, fontSize: 16),
  decoration: InputDecoration(
    hintText: 'Enter OTP',
    hintStyle: const TextStyle(color: Colors.white24),
    filled: true,
    fillColor: inputBg,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primary, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primary, width: 2),
    ),
  ),
),

const SizedBox(height: 24),
              const SizedBox(height: 24),

              // Send OTP Button
              SizedBox(
                height: 54,
                child: ElevatedButton(
                onPressed: _isLoading
    ? null
    : () async {
        setState(() => _isLoading = true);

        if (!_otpSent) {
          var res = await ApiService.sendOtp(_emailController.text.trim());

          _showSnack(res["message"] ?? "OTP Sent");

          setState(() {
            _otpSent = true;
            _isLoading = false;
          });
        } else {
          await _verifyLoginOtp();
          setState(() => _isLoading = false);
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================
              // Fingerprint Button (Now connected!)
              // ==========================================
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Trigger Fingerprint scan when clicked
                    _authenticateWithBiometrics();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fingerprintBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(
                    Icons.fingerprint,
                    color: fingerprintText,
                    size: 24,
                  ),
                  label: const Text(
                    'Login with Fingerprint',
                    style: TextStyle(
                      color: fingerprintText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // OR Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                        color: Colors.white.withOpacity(0.1), thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                        color: Colors.white.withOpacity(0.1), thickness: 1),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Register Link
              Center(
                child: GestureDetector(
                 onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Step1EmailOtpScreen(),
    ),
  );
},
                  child: RichText(
                    text: const TextSpan(
                      text: 'New to MediConnect? ',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Register here →',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
