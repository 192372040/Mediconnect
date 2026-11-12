import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'PatientRegistrationScreen/Page2.dart';
import '../Roleselection/RoleSelectionScreen.dart';
class UserProfileScreen extends StatefulWidget {
  final Map user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  static const Color primary = Color(0xFF0F6E56);
  static const Color primaryBg = Color(0xFF2C2A2A);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color borderColor = Color(0xFF3A3A3A);
String getRiskLevel() {
  String history =
      widget.user["medical_history"]?.toString() ?? "";

  if (history.isEmpty) {
    return "Low";
  }

  int count = history.split(",").length;

  if (count >= 3) {
    return "High";
  } else if (count == 2) {
    return "Moderate";
  } else {
    return "Low";
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: primaryBg,
                border:
                    Border(bottom: BorderSide(color: borderColor, width: 0.5)),
              ),
              child: Row(
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
                      child: const Icon(Icons.chevron_left_rounded,
                          color: primary, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('My profile',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                  // Edit button
                 GestureDetector(
  onTap: () async {
  final updatedUser = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Step2PersonalDetailsScreen(
        email: widget.user["email"],
        user: widget.user,
      ),
    ),
  );

  if (updatedUser != null) {
    setState(() {
      widget.user.addAll(updatedUser);
    });
  }
},
  child: Container(
    padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF1A2A22),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
          color: const Color(0xFF1D9E75), width: 0.5),
    ),
    child: const Text(
      'Edit',
      style: TextStyle(
        fontSize: 12,
        color: Color(0xFF1D9E75),
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ── Avatar ──────────────────
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                          color: primary, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          widget.user["name"] != null &&
                                  widget.user["name"].isNotEmpty
                              ? widget.user["name"][0].toUpperCase()
                              : "U",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      widget.user["name"] ?? "User",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      widget.user["email"] ?? "",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white54,
                      ),
                    ),

                    const SizedBox(height: 12),
                    // ── Patient ID ──────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2A22),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primary, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.badge_rounded,
                              color: primary, size: 16),
                          const SizedBox(width: 8),
                          Text(widget.user["patient_id"] ?? "N/A",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _copyPatientId(),
                            child: const Icon(Icons.copy_rounded,
                                color: primary, size: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Share this ID with your doctor',
                        style: TextStyle(fontSize: 10, color: Colors.white38)),
                    const SizedBox(height: 24),

                    // ── Info card ────────────────
                    _infoCard([
                      {
  'icon': Icons.person_rounded,
  'label': 'Full name',
  'value': widget.user["name"] ?? "N/A"
},
{
  'icon': Icons.cake_rounded,
  'label': 'Age',
  'value': widget.user["age"] != null
      ? '${widget.user["age"]} years'
      : 'N/A'
},
{
  'icon': Icons.male_rounded,
  'label': 'Gender',
  'value': widget.user["gender"] ?? "N/A"
},
{
  'icon': Icons.water_drop_rounded,
  'label': 'Blood group',
  'value': widget.user["blood_group"] ?? "N/A"
},
                    ]),
                    const SizedBox(height: 16),

                    // ── Health card ──────────────
                    _sectionTitle('Health information'),
                    const SizedBox(height: 10),
                    _infoCard([
                      {
  'icon': Icons.monitor_heart_rounded,
  'label': 'Health score',
  'value': getRiskLevel() == "High"
      ? '45 / 100'
      : getRiskLevel() == "Moderate"
          ? '72 / 100'
          : '95 / 100'
},
{
  'icon': Icons.warning_amber_rounded,
  'label': 'Risk level',
  'value': getRiskLevel()
},
{
  'icon': Icons.sick_rounded,
  'label': 'Medical history',
  'value': widget.user["medical_history"] != null &&
          widget.user["medical_history"].toString().isNotEmpty
      ? widget.user["medical_history"]
      : 'No medical history'
},
                    ]),
                    const SizedBox(height: 16),

                    

                    // ── Logout ───────────────────
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                          (route) => false,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A1A1A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFFE24B4A), width: 0.5),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.logout_rounded,
                                  color: Color(0xFFE24B4A), size: 18),
                              SizedBox(width: 8),
                              Text('Log out',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFE24B4A),
                                      fontWeight: FontWeight.w600)),
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
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }

  Widget _infoCard(List<Map<String, dynamic>> items) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(item['icon'] as IconData, color: primary, size: 18),
                    const SizedBox(width: 12),
                    Text(item['label'] as String,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white54)),
                    const Spacer(),
                    Text(item['value'] as String,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ],
                ),
              ),
              if (i != items.length - 1)
                Container(
                    height: 0.5,
                    color: borderColor,
                    margin: const EdgeInsets.symmetric(horizontal: 16)),
            ],
          );
        }),
      ),
    );
  }

  

  void _copyPatientId() {
    Clipboard.setData(ClipboardData(text: widget.user["patient_id"] ?? "N/A"));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Patient ID copied to clipboard!'),
          ],
        ),
        backgroundColor: const Color(0xFF0F6E56),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
