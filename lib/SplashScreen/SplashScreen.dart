import 'package:flutter/material.dart';
import 'package:my_project/Roleselection/RoleSelectionScreen.dart';
import 'package:my_project/LoginScreen.dart'; // ← REPLACE with your actual RoleSelectionScreen import
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
 
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
 
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
 
  // ── Brand colors ──────────────────────────
  static const Color primary      = Color(0xFF0F6E56);
  static const Color primaryLight = Color(0xFF1D9E75);
  static const Color ring1Color   = Color(0xFF9FE1CB);
  static const Color ring2Color   = Color(0xFF5DCAA5);
  static const Color pillBg       = Color(0xFFE1F5EE);
  static const Color pillBorder   = Color(0xFF9FE1CB);
  static const Color pillText     = Color(0xFF085041);
  static const Color textSecondary = Colors.white;
 
  // ── Animation controllers ─────────────────
  late AnimationController _ring1Controller;
  late AnimationController _ring2Controller;
  late AnimationController _loadingController;
  late AnimationController _fadeController;
 
  late Animation<double> _ring1Scale;
  late Animation<double> _ring1Opacity;
  late Animation<double> _ring2Scale;
  late Animation<double> _ring2Opacity;
  late Animation<double> _loadingValue;
  late Animation<double> _fadeIn;
 
  @override
  void initState() {
    super.initState();
 
    // Fade-in for whole content
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
 
    // Outer pulse ring
    _ring1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _ring1Scale = Tween<double>(begin: 0.85, end: 1.3).animate(
      CurvedAnimation(parent: _ring1Controller, curve: Curves.easeOut),
    );
    _ring1Opacity = Tween<double>(begin: 0.9, end: 0.0).animate(
      CurvedAnimation(parent: _ring1Controller, curve: Curves.easeOut),
    );
 
    // Inner pulse ring (delayed)
    _ring2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _ring2Scale = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _ring2Controller, curve: Curves.easeOut),
    );
    _ring2Opacity = Tween<double>(begin: 0.7, end: 0.0).animate(
      CurvedAnimation(parent: _ring2Controller, curve: Curves.easeOut),
    );
    // Delay ring2 by 400ms
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _ring2Controller.repeat();
    });
 
    // Loading bar — loops back and forth
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _loadingValue = Tween<double>(begin: 0.10, end: 0.85).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );
 
    // Navigate to RoleSelectionScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
        );
      }
    });
  }
 
  @override
  void dispose() {
    _ring1Controller.dispose();
    _ring2Controller.dispose();
    _loadingController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white, // ← your existing background color
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // ── Status bar spacer ─────────────
                const SizedBox(height: 12),
 
                // ── Wi-Fi indicator (top right) ───
                const Align(
                  alignment: Alignment.centerRight,
                  child: _WifiIcon(),
                ),
 
                // ── Logo + name + tagline (center) ─
                const Spacer(),
                _buildLogoSection(),
                const SizedBox(height: 20),
                const Text(
                  'MediConnect',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your health, connected',
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
 
                // ── Loading bar ───────────────────
                _buildLoadingBar(),
                const SizedBox(height: 8),
                const Text(
                  'Checking connection...',
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
                const SizedBox(height: 32),
 
                // ── Partner logos ─────────────────
                const Text(
                  'HOSPITAL PARTNERS',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                _buildPartnerRow(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
 
  // ── Logo with animated pulse rings ────────
  Widget _buildLogoSection() {
    const double logoSize = 72.0;
    const double ring1Size = 120.0;
    const double ring2Size = 96.0;
 
    return SizedBox(
      width: ring1Size,
      height: ring1Size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring
          AnimatedBuilder(
            animation: _ring1Controller,
            builder: (_, __) => Transform.scale(
              scale: _ring1Scale.value,
              child: Opacity(
                opacity: _ring1Opacity.value.clamp(0.0, 1.0),
                child: Container(
                  width: ring1Size,
                  height: ring1Size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ring1Color, width: 2),
                  ),
                ),
              ),
            ),
          ),
 
          // Inner pulse ring
          AnimatedBuilder(
            animation: _ring2Controller,
            builder: (_, __) => Transform.scale(
              scale: _ring2Scale.value,
              child: Opacity(
                opacity: _ring2Opacity.value.clamp(0.0, 1.0),
                child: Container(
                  width: ring2Size,
                  height: ring2Size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ring2Color, width: 2),
                  ),
                ),
              ),
            ),
          ),
 
          // Logo circle
          Container(
            width: logoSize,
            height: logoSize,
            decoration: const BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
            ),
            child: const Center(child: _MedicalCrossIcon()),
          ),
 
          // ── REPLACE the line below with your actual logo image ──
          // Container(
          //   width: logoSize,
          //   height: logoSize,
          //   decoration: const BoxDecoration(shape: BoxShape.circle),
          //   child: ClipOval(
          //     child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
          //   ),
          // ),
        ],
      ),
    );
  }
 
  // ── Animated loading bar ──────────────────
  Widget _buildLoadingBar() {
    return Container(
      width: 160,
      height: 3,
      decoration: BoxDecoration(
        color: const Color(0xFFE1F5EE),
        borderRadius: BorderRadius.circular(2),
      ),
      child: AnimatedBuilder(
        animation: _loadingValue,
        builder: (_, __) => FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: _loadingValue.value,
          child: Container(
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
 
  // ── Partner hospital pills ────────────────
  Widget _buildPartnerRow() {
    const partners = ['Apollo', 'AIIMS', 'Fortis'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: partners
          .map(
            (name) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: pillBg,
                border: Border.all(color: pillBorder, width: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 11,
                  color: pillText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
 
// ─────────────────────────────────────────────
//  Medical cross icon (white +)
// ─────────────────────────────────────────────
class _MedicalCrossIcon extends StatelessWidget {
  const _MedicalCrossIcon();
 
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Horizontal bar
        Container(
          width: 28,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Vertical bar
        Container(
          width: 8,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
 
// ─────────────────────────────────────────────
//  Wi-Fi indicator widget
// ─────────────────────────────────────────────
class _WifiIcon extends StatelessWidget {
  const _WifiIcon();
 
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _bar(5, 1.0),
        const SizedBox(width: 2),
        _bar(9, 1.0),
        const SizedBox(width: 2),
        _bar(13, 0.35),
      ],
    );
  }
 
  Widget _bar(double height, double opacity) => Opacity(
        opacity: opacity,
        child: Container(
          width: 3,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF1D9E75),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      );
}
 
// ─────────────────────────────────────────────
//  Placeholder — replace with your actual
//  RoleSelectionScreen import
// ─────────────────────────────────────────────
