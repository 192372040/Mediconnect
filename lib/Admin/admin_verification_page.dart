import 'package:flutter/material.dart';
import 'package:my_project/Admin/Hospitaldetails.dart';
import '../Patientdashboard/services/api_service.dart';
class AdminVerificationPage extends StatefulWidget {
  const AdminVerificationPage({Key? key}) : super(key: key);

  @override
  State<AdminVerificationPage> createState() => _AdminVerificationPageState();
}

class _AdminVerificationPageState extends State<AdminVerificationPage> {
  // Theme Colors
  static const Color primary = Color(0xFFB87518);
  static const Color primaryBg = Color(0xFF242424);

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // State
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _aadhaarController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // Basic email validation
  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  // Send OTP Logic
  Future<void> _sendOtp() async {
  if (!_isValidEmail(_emailController.text)) {
    _showSnack('Invalid email');
    return;
  }

  setState(() => _isLoading = true);

  var res = await ApiService.sendAdminOtp(
  _emailController.text,
);

  setState(() {
    _isLoading = false;
    _otpSent = true;
  });

  _showSnack(res["message"]);
}

  // Verify OTP Logic
    // Verify OTP Logic
 Future<void> _verifyOtp() async {
  print("BUTTON CLICKED");
  String otp = _otpControllers.map((c) => c.text).join();

  var res = await ApiService.verifyOtp(
    _emailController.text,
    otp,
  );
print("RESPONSE: $res");

  if (res["error"] == null) { 
  _showSnack("Verified ✅");

  Navigator.push(
    context,
    MaterialPageRoute(
  builder: (context) =>
      HospitalDetailsPage(email: _emailController.text),
),
  );
} else {
  _showSnack("Invalid OTP ❌");
}
 }


  // Snackbar helper
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation and Progress
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _buildHeader(),
            ),
            const SizedBox(height: 16),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                children: [
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  Container(
                    height: 3,
                    width: MediaQuery.of(context).size.width * 0.33,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Title Section
                    const Text(
                      'Admin verification',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Enter hospital admin email",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email Input
                    const Text(
                      'Admin email address',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.black87),
                      onChanged: (value) {
                        // Revert back to "Send OTP" if the user modifies the email field
                        if (_otpSent) {
                          setState(() {
                            _otpSent = false;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter email address',
                        hintStyle: const TextStyle(color: Colors.black26),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // OTP Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enter OTP sent to admin email',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              6,
                              (index) => _otpCell(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Aadhaar Section
                  

                    
                  ],
                ),
              ),
            ),

            // Main Action Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                 onPressed: () {
  if (_isLoading) return;

  if (!_otpSent) {
    _sendOtp();
  } else {
    _verifyOtp();
  }
},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _otpSent ? 'Verify & continue' : 'Send OTP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom OTP Cell Widget to handle automatic focus switching
  Widget _otpCell(int index) {
    return Container(
      width: 42,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            // Move forward
            _otpFocusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            // Move backward when deleting
            _otpFocusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  // Helper widget for the header
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.black, size: 18),
            onPressed: () {},
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 24,
                height: 6,
                decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 6),
            Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: Colors.white54, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: Colors.white54, shape: BoxShape.circle)),
          ],
        ),
        const Text(
          'Step 1 of 4',
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
