import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/Admin/Admin_verification_Page.dart';
import '../Patientdashboard/services/api_service.dart';

import 'Dashboard.dart';
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
State<AdminLoginScreen> createState() =>
    _AdminLoginScreenState();
}

class _AdminLoginScreenState
    extends State<AdminLoginScreen> {

final TextEditingController
_hospitalIdController =
    TextEditingController();

final TextEditingController
_passwordController =
    TextEditingController();

Future<void> _authenticateWithBiometrics() async {
  final LocalAuthentication auth = LocalAuthentication();
  try {
    final bool canAuth = await auth.canCheckBiometrics;
    if (!canAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometrics not available on this device.')),
      );
      return;
    }
    final bool authenticated = await auth.authenticate(
      localizedReason: 'Scan your fingerprint to login as admin',
      options: const AuthenticationOptions(biometricOnly: true),
    );
    if (!authenticated) return;
    
    // Load saved hospital ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('hospital_id') ?? '';
    if (savedId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No saved Hospital ID. Please login with password first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HospitalDashboardScreen(hospitalId: savedId),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Biometric error: $e')),
    );
  }
}

Future<void> _showForgotIdDialog() async {
  final TextEditingController emailController = TextEditingController();
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text(
          'Forgot Hospital ID',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your registered admin email address to receive your Hospital ID.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF333333),
                hintText: 'Email Address',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.trim().isEmpty) return;
              Navigator.pop(context);
              final res = await ApiService.forgotAdminId(email: emailController.text.trim());
              if (!mounted) return;
              if (res.containsKey('message')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['message'])),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['error'] ?? 'An error occurred')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC7781E),
            ),
            child: const Text('Send ID', style: TextStyle(color: Colors.white)),
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

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Lock Icon Header
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title and Subtitle
              const Text(
                'Admin Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'MediConnect Hospital Portal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),
              
              // Hospital ID Field
              const Text(
                'Hospital ID',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller:
    _hospitalIdController,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'MED-HOSP-2026-XXXX',
                  hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Password Field
              const Text(
                'Password',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller:
    _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Forgot Links
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    GestureDetector(
                      onTap: () {
                        _showForgotIdDialog();
                      },
                      child: const Text(
                        'Forgot Hospital ID?',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Login Button
             ElevatedButton(

  onPressed: () async {

    var res =
        await ApiService.adminLogin(

      hospitalId:
          _hospitalIdController.text,

      password:
          _passwordController.text,
    );

    if (res["message"] ==
        "Login successful") {

      // Save hospitalId for fingerprint future logins
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('hospital_id', _hospitalIdController.text);

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (context) =>
              HospitalDashboardScreen(
                
  hospitalId:
      _hospitalIdController.text,

),

        ),
      );

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(

            res["error"] ??
            "Invalid Hospital ID or Password",

          ),
        ),
      );
    }
  },

  style: ElevatedButton.styleFrom(

    backgroundColor: primaryColor,

    padding: const EdgeInsets.symmetric(
      vertical: 16,
    ),

    shape: RoundedRectangleBorder(

      borderRadius:
          BorderRadius.circular(12),

    ),

    elevation: 0,
  ),

  child: const Text(

    'Login to portal',

    style: TextStyle(

      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,

    ),
  ),
),
              const SizedBox(height: 16),
              
              // Login with Fingerprint Button
              ElevatedButton.icon(
                onPressed: () {
                  _authenticateWithBiometrics();
                },
                icon: const Icon(Icons.fingerprint, color: primaryColor, size: 28),
                label: const Text(
                  'Login with\nFingerprint',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF332617), // Dark tinted background
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 32),
              
              // OR Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[800], thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[800], thickness: 1)),
                ],
              ),
              const SizedBox(height: 32),
              
              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New hospital? ',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  GestureDetector(
                    onTap: () {

  Navigator.push(

    context,

    MaterialPageRoute(

      builder: (context) =>
          const AdminVerificationPage(),

    ),
  );
},
                    child: Row(
                      children: const [
                        Text(
                          'Register here',
                          style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, color: primaryColor, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}