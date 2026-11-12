import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/Doctor/DoctorStep1Screen.dart';
import 'package:my_project/Doctor/Doctordashscreen.dart';
import 'package:my_project/Doctor/ForgotDoctorIdScreen.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';
import 'package:my_project/Roleselection/RoleSelectionScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const DoctorLoginScreen(),
    );
  }
}

class DoctorLoginScreen extends StatefulWidget {

  final String? doctorId;

  const DoctorLoginScreen({
    super.key,
    this.doctorId,
  });
  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _licenseController =
    TextEditingController();
  final TextEditingController _passwordController =
    TextEditingController();
  static const Color fingerprintBg =
    Color(0xFF1A2540);

static const Color fingerprintText =
    Color(0xFF3B82F6);
  final bool _obscurePassword = true;
@override
void initState() {
  super.initState();

  _licenseController.text =
      widget.doctorId ?? "";
}
  @override
  void dispose() {
    _licenseController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
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
      localizedReason: 'Scan your fingerprint to login as doctor',
      options: const AuthenticationOptions(biometricOnly: true),
    );
    if (!authenticated) return;
    // Load saved doctor ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('doctor_id') ?? '';
    if (savedId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No saved Doctor ID. Please login with password first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorDashboardScreen(doctorId: savedId),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Biometric error: $e')),
    );
  }
}
  void _navigateBackToRoleSelection() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateBackToRoleSelection();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF2C2A2A),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: _navigateBackToRoleSelection,
                      ),
                    ),
                  // App Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Doctor Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 6),

              // Subtitle
              const Text(
                'MediConnect Medical Portal',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 36),

              // License Number Label
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Doctor Id',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // License Number Field
             TextField(

  controller: _licenseController,

  enableInteractiveSelection: true,

  readOnly: false,

  toolbarOptions: ToolbarOptions(
    copy: true,
    paste: true,
    selectAll: true,
  ),
  
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                
                  filled: true,
                  fillColor: Colors.white,
                 
                  border: OutlineInputBorder(
  borderRadius: BorderRadius.circular(8),
  borderSide: const BorderSide(
    color: Color(0xFF2563EB),
    width: 1.5,
  ),
),
                enabledBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(8),
  borderSide: const BorderSide(
    color: Color(0xFF2563EB),
    width: 1.5,
  ),
),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF2563EB),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Password Label
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Password',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  letterSpacing: 4,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                 border: OutlineInputBorder(
  borderRadius: BorderRadius.circular(8),
  borderSide: const BorderSide(
    color: Color(0xFF2563EB),
    width: 1.5,
  ),
),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF2563EB),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF2563EB),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),

              const SizedBox(height: 10),



Align(
  alignment: Alignment.centerRight,

  child: GestureDetector(

    onTap: () {

      Navigator.push(
        context,

        MaterialPageRoute(
          builder: (context) =>
              const ForgotDoctorIdScreen(),
        ),
      );
    },

    child: const Text(

      'Forgot Doctor ID?',

      style: TextStyle(
        color: Color(0xFF3B82F6),
        fontSize: 13,
        decoration:
            TextDecoration.underline,
      ),
    ),
  ),
),
              const SizedBox(height: 28),

              // Login to Portal Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
  final doctorId = _licenseController.text.trim();
  final password = _passwordController.text.trim();
  if (doctorId.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter Doctor ID and password.')),
    );
    return;
  }
  var res = await ApiService.doctorLogin(
    doctorId: doctorId,
    password: password,
  );
  if (res["message"] != null) {
    // Save doctorId for fingerprint future logins
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('doctor_id', doctorId);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorDashboardScreen(doctorId: doctorId),
      ),
    );
  } else {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["error"] ?? 'Login failed')),
    );
  }
},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Login to portal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              
             

              // Login with OTP Button
              SizedBox(
  width: double.infinity,
  height: 52,
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
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: const Color(0xFF3A3D45),
                      thickness: 1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: const Color(0xFF3A3D45),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
               const SizedBox(height: 32),
Center(
  child: GestureDetector(

    onTap: () {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const EmailVerificationScreen(),
        ),
      );

    },

    child: RichText(
      text: const TextSpan(
        text: 'New to MediConnect? ',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 14,
        ),
        children: [
          TextSpan(
            text: 'Register here →',
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  ),
),
 

              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
}
}