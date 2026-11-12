import 'package:flutter/material.dart';
import 'package:my_project/Patientdashboard/PatientDashboardScreen.dart';

class Step3ProfileCreatedScreen extends StatefulWidget {
  final String name;
  final String phone;
  final int age;
  final String gender;
  final String bloodGroup;
  final String riskLevel;
  final List<String> conditions;
final Map user;
  const Step3ProfileCreatedScreen({
    super.key,
    required this.user,
    required this.name,
    required this.phone,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.riskLevel,
    this.conditions = const [],
  });

  @override
  State<Step3ProfileCreatedScreen> createState() =>
      _Step3ProfileCreatedScreenState();
}

class _Step3ProfileCreatedScreenState extends State<Step3ProfileCreatedScreen>
    with SingleTickerProviderStateMixin {
  // ── Colors ─────────────────────────────────────────────────
  static const Color primary = Color(0xFF0F6E56);
  static const Color primaryBg = Color(0xFF2C2A2A);
  static const Color borderColor = Color(0xFFE5E7EB);

  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    // Auto-start animation
    Future.delayed(
      const Duration(milliseconds: 200),
      () => _animController.forward(),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Risk badge styling ─────────────────────────────────────
  Color get _riskBgColor {
    switch (widget.riskLevel) {
      case 'Low':
        return const Color(0xFFDCFCE7);
      case 'Moderate':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFFEE2E2);
    }
  }

  Color get _riskTextColor {
    switch (widget.riskLevel) {
      case 'Low':
        return const Color(0xFF166534);
      case 'Moderate':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFFDC2626);
    }
  }

  // ── AI Recommendation ──────────────────────────────────────
  String get _aiRecommendation {
    if (widget.conditions.contains('Diabetes')) {
      return 'Schedule a diabetes follow-up with an endocrinologist within 30 days.';
    } else if (widget.conditions.contains('Heart disease')) {
      return 'Consult a cardiologist for a cardiac health assessment.';
    } else if (widget.conditions.contains('Hypertension')) {
      return 'Monitor your blood pressure daily and review medications with your doctor.';
    } else if (widget.conditions.contains('Asthma')) {
      return 'Ensure your inhaler prescription is up to date and avoid triggers.';
    } else if (widget.conditions.contains('Thyroid')) {
      return 'Schedule a thyroid function test and endocrinologist consultation.';
    } else if (widget.riskLevel == 'Low') {
      return 'Great health profile! Schedule a routine annual check-up.';
    }
    return 'Schedule a comprehensive health check-up within the next 30 days.';
  }

  // ══════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _buildTopBar(),
            ),
            const SizedBox(height: 14),

            // ── Progress Bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildProgressBar(),
            ),
            const SizedBox(height: 10),

            // ── Scrollable Content ────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // ── Success Icon ─────────────────
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.35),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 46,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Title ────────────────────────
                      const Text(
                        'Profile created!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome, ${widget.name.isEmpty ? 'User' : widget.name}. Your health journey starts now.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Profile Summary Card ──────────
                      _buildProfileSummaryCard(),
                      const SizedBox(height: 16),

                      // ── AI Recommendation Card ────────
                      _buildAiRecommendationCard(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom Button ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to dashboard screen
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(name: '/patient_dashboard'),
                        builder: (_) => PatientDashboardScreen(
                          user: widget.user,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Go to dashboard',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ══════════════════════════════════════════════════════════

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: primary,
              size: 22,
            ),
          ),
        ),
        const Spacer(),
        // Step dots — all active/done
        Row(
          children: List.generate(3, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: i == 2 ? 20 : 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Step 3 of 3',
            style: TextStyle(
              fontSize: 10,
              color: primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: const LinearProgressIndicator(
        value: 1.0,
        minHeight: 3,
        backgroundColor: Colors.white24,
        valueColor: AlwaysStoppedAnimation<Color>(primary),
      ),
    );
  }

  // ── Profile Summary Card ───────────────────────────────────
  Widget _buildProfileSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white24, width: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'YOUR PROFILE SUMMARY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white38,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          Container(height: 0.5, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 14),

          // Name row
          _summaryRow(
            label: 'Name',
            value: widget.name.isEmpty ? '—' : widget.name,
            isText: true,
          ),
          _summaryDivider(),

          // Mobile row
          _summaryRow(
            label: 'Mobile',
            value: widget.phone.isEmpty ? 'N/A' : widget.phone,

            isText: true,
          ),
          _summaryDivider(),

          // Age / Gender row
          _summaryRow(
            label: 'Age / Gender',
            value: '${widget.age} · ${widget.gender}',
            isBold: true,
          ),
          _summaryDivider(),

          // Blood group row
          _summaryRow(
            label: 'Blood group',
            customValue: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.bloodGroup.isEmpty ? '—' : widget.bloodGroup,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          _summaryDivider(),

          // AI risk score row
          _summaryRow(
            label: 'AI risk score',
            customValue: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _riskBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.riskLevel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _riskTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required String label,
    String? value,
    Widget? customValue,
    bool isBold = false,
    bool isText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.white60),
          ),
          if (customValue != null)
            customValue
          else
            Text(
              value ?? '—',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryDivider() {
    return Container(height: 0.5, color: Colors.white.withValues(alpha: 0.08));
  }

  // ── AI Recommendation Card ─────────────────────────────────
  Widget _buildAiRecommendationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white24, width: 0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '💡',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI recommendation',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _aiRecommendation,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
