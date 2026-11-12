import 'package:flutter/material.dart';
import 'package:my_project/Patientdashboard/PatientRegistrationScreen/Page1.dart';
import 'package:my_project/LoginScreen.dart';
import 'package:my_project/Doctorlogin.dart';
import 'package:my_project/Admin/login.dart';
//  MediConnect — Role Selection Screen (S2)
//  Background: white, accent: #0F6E56 teal
//  Usage: navigated to from SplashScreen
// ─────────────────────────────────────────────

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {

  // ── Brand colors ──────────────────────────
  static const Color primary       = Color(0xFF0F6E56);
  static const Color primaryLight  = Color(0xFF1D9E75);
  static const Color primaryBg     = Color(0xFFE1F5EE);
  static const Color primaryBorder = Color(0xFF9FE1CB);
  static const Color primaryDark   = Color(0xFF085041);

  static const Color doctorColor   = Color(0xFF185FA5);
  static const Color doctorBg      = Color(0xFFE6F1FB);
  static const Color doctorBorder  = Color(0xFFB5D4F4);

  static const Color adminColor    = Color(0xFFBA7517);
  static const Color adminBg       = Color(0xFFFAEEDA);
  static const Color adminBorder   = Color(0xFFFAC775);

  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Colors.white;
  static const Color borderColor   = Color(0xFFE5E7EB);

  // ── Selected role ─────────────────────────
  String _selectedRole = 'patient';

  // ── Fade-in animation ─────────────────────
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ── Role definitions ──────────────────────
  List<Map<String, dynamic>> get _roles => [
    {
      'id': 'patient',
      'title': 'Patient',
      'subtitle': 'Book appointments, check symptoms',
      'iconBg': primaryBg,
      'iconColor': primary,
      'activeBorder': primary,
      'activeBg': primaryBg,
      'icon': _PatientIcon(color: primary),
    },
    {
      'id': 'doctor',
      'title': 'Doctor',
      'subtitle': 'Manage patients, consultations',
      'iconBg': doctorBg,
      'iconColor': doctorColor,
      'activeBorder': doctorColor,
      'activeBg': doctorBg,
      'icon': _DoctorIcon(color: doctorColor),
    },
    {
      'id': 'admin',
      'title': 'Hospital admin',
      'subtitle': 'Manage staff, beds, analytics',
      'iconBg': adminBg,
      'iconColor': adminColor,
      'activeBorder': adminColor,
      'activeBg': adminBg,
      'icon': _AdminIcon(color: adminColor),
    },
  ];

  void _onContinue() {
    // Navigate based on selected role
    switch (_selectedRole) {
      case 'patient':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const Step1EmailOtpScreen()),
        );
        break;
      case 'doctor':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DoctorLoginScreen()),
        );
        break;
      case 'admin':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideIn,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ── Top bar: back + step dots ─
                  _buildTopBar(),
                  const SizedBox(height: 20),


                  // ── Header ───────────────────
                  const Text(
                    'Welcome to MediConnect',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose your role to get started',
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Role cards ────────────────
                  ..._roles.map((role) => _RoleCard(
                        role: role,
                        isSelected: _selectedRole == role['id'],
                        onTap: () => setState(() => _selectedRole = role['id']),
                      )),

                  const Spacer(),

                  // ── Role description chip ─────
                  _buildRoleHint(),
                  const SizedBox(height: 16),

                  // ── Continue button ───────────
                  // ── Continue button ───────────
                  _buildContinueButton(),
                  const SizedBox(height: 16),

                  // ── Login link ────────────────
                  GestureDetector(
                    onTap: () {
                      if (_selectedRole == 'patient') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      } else if (_selectedRole == 'doctor') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorLoginScreen()));
                      } else if (_selectedRole == 'admin') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
                      }
                    },
                    child: Center(
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already registered? ',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.white54)),
                            TextSpan(
                              text: 'Login here →',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF0F6E56),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Top navigation bar ────────────────────
  Widget _buildTopBar() {
    return Row(
      children: [
        // Back button
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: primary,
              size: 22,
            ),
          ),
        ),

        const Spacer(),

        // Step dots
        Row(
          children: ['patient', 'doctor', 'admin'].map((role) {
            final isActive = role == _selectedRole;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 20 : 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive ? primary : const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }).toList(),
        ),

        const Spacer(),

        
      ],
    );
  }

  // ── Thin progress bar ─────────────────────
  
  // ── Selected role hint ────────────────────
  Widget _buildRoleHint() {
    final Map<String, String> hints = {
      'patient': 'As a patient you can book appointments, use the AI symptom checker, manage prescriptions and more.',
      'doctor': 'As a doctor you can manage your patient queue, write prescriptions, and use AI clinical decision support.',
      'admin': 'As a hospital admin you can manage doctors, beds, appointments and view analytics dashboards.',
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(_selectedRole),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: primaryBg,
          border: Border.all(color: primaryBorder, width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          hints[_selectedRole] ?? '',
          style: const TextStyle(
            fontSize: 12,
            color: primaryDark,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  // ── Continue button ───────────────────────
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue as ${_selectedRole[0].toUpperCase()}${_selectedRole.substring(1)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Role Card Widget
// ─────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  final Map<String, dynamic> role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeBorder = role['activeBorder'] as Color;
    final Color activeBg     = role['activeBg'] as Color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white,
          border: Border.all(
            color: isSelected ? activeBorder : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon box
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: role['iconBg'] as Color,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(child: role['icon'] as Widget),
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role['title'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    role['subtitle'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // Radio button
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeBorder : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
                color: isSelected ? activeBg : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeBorder,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Custom Icon Widgets
// ─────────────────────────────────────────────

class _PatientIcon extends StatelessWidget {
  final Color color;
  const _PatientIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(26, 26),
      painter: _PatientPainter(color: color),
    );
  }
}

class _PatientPainter extends CustomPainter {
  final Color color;
  const _PatientPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    // Head circle
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.32), size.width * 0.22, paint);
    // Body arc
    final bodyPath = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width / 2, size.height * 0.55,
        size.width, size.height,
      )
      ..close();
    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DoctorIcon extends StatelessWidget {
  final Color color;
  const _DoctorIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(26, 26),
          painter: _PatientPainter(color: color),
        ),
        // Stethoscope cross indicator
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 10),
          ),
        ),
      ],
    );
  }
}

class _AdminIcon extends StatelessWidget {
  final Color color;
  const _AdminIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.business_rounded, color: color, size: 26);
  }
}

// ─────────────────────────────────────────────
//  Placeholder screens — replace with actual
// ─────────────────────────────────────────────



