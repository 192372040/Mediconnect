
import 'package:flutter/material.dart';
import 'package:my_project/Doctorlogin.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';
class SetupPasswordScreen extends StatefulWidget {

  final String doctorId;

  const SetupPasswordScreen({
    Key? key,
    required this.doctorId,
  }) : super(key: key);

  @override
  State<SetupPasswordScreen> createState() => _SetupPasswordScreenState();
}

class _SetupPasswordScreenState extends State<SetupPasswordScreen> {
  final TextEditingController _doctorIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Theme colors matching your login screen
  final Color primaryBlue = const Color(0xFF2E65F3);
  final Color backgroundColor = const Color(0xFF252525);
  
  @override
  void dispose() {
    _doctorIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
@override
void initState() {
  super.initState();

  _doctorIdController.text =
      widget.doctorId;
}
  Future<void> _handleSubmit() async {
    // Hide keyboard when button is pressed
    FocusScope.of(context).unfocus();

    if (_doctorIdController.text.isEmpty) {
      _showError('Please enter your Doctor ID');
    } else if (_passwordController.text.isEmpty) {
      _showError('Please enter a password');
    } else if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
    } else {
      // TODO: Add your API call here to save the Doctor ID and new Password
      var res =
    await ApiService.savePassword(

  doctorId: widget.doctorId,

  password:
      _passwordController.text,
);

print(res);
 ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content:
        Text('Password set successfully!'),

    backgroundColor: Colors.green,
  ),
);

Future.delayed(
  const Duration(seconds: 1),

  () {

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (context) =>
            DoctorLoginScreen(),
      ),

      (route) => false,
    );
  },
);
      // Example: Go back to login after successful password setup
      // Navigator.pop(context); 
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget _buildTextField({
    required String label, 
    required TextEditingController controller, 
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryBlue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Standard Logo Box matching the login screen
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 48),
              
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Set up Password',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Please enter your Doctor ID and create a new password to secure your account.',
                  style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 32),
              
              // The 3 required fields
              _buildTextField(
                label: 'Doctor Id',
                controller: _doctorIdController,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Create Password',
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                obscureText: true,
              ),
              
              const SizedBox(height: 40),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Submit', 
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
