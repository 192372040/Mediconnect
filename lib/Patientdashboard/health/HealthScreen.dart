import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/Patientdashboard/health/LogVitalsScreen.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  static Color primary = Color(0xFF0F6E56);

  Color get primaryBg => Theme.of(context).brightness == Brightness.dark ? Color(0xFF2C2A2A) : Colors.white;
  Color get cardBg => Theme.of(context).brightness == Brightness.dark ? Color(0xFF1A1A1A) : Colors.grey.shade50;
  Color get borderColor => Theme.of(context).brightness == Brightness.dark ? Color(0xFF3A3A3A) : Colors.grey.shade200;
  Color get textColor => Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;
  Color get textLightColor => Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54;
  Color get textDimColor => Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black87;
  Color get textMutedColor => Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.black54;
  Color get white24Color => Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black12;




  List<Map<String, dynamic>> _vitals = [];

  @override
  void initState() {
    super.initState();
    _loadVitals();
  }

  Future<void> _loadVitals() async {
    final prefs = await SharedPreferences.getInstance();
    final bp = prefs.getString("vital_bp") ?? "120/80";
    final bpStatus = prefs.getString("vital_bp_status") ?? "Normal";
    final bpHigh = prefs.getBool("vital_bp_high") ?? false;

    final sugar = prefs.getString("vital_sugar") ?? "142";
    final sugarStatus = prefs.getString("vital_sugar_status") ?? "High";
    final sugarHigh = prefs.getBool("vital_sugar_high") ?? true;

    final weight = prefs.getString("vital_weight") ?? "68.5";
    final weightStatus = prefs.getString("vital_weight_status") ?? "Normal";
    final weightHigh = prefs.getBool("vital_weight_high") ?? false;

    final spo2 = prefs.getString("vital_spo2") ?? "98%";
    final spo2Status = prefs.getString("vital_spo2_status") ?? "Normal";
    final spo2High = prefs.getBool("vital_spo2_high") ?? false;

    setState(() {
      _vitals = [
        {
          'label': 'Blood pressure',
          'value': bp,
          'unit': 'mmHg',
          'status': bpStatus,
          'isHigh': bpHigh,
          'icon': Icons.speed_rounded,
          'iconColor': Color(0xFF185FA5),
          'iconBg': Color(0xFF1A2A3A),
        },
        {
          'label': 'Blood sugar',
          'value': sugar,
          'unit': 'mg/dL',
          'status': sugarStatus,
          'isHigh': sugarHigh,
          'icon': Icons.water_drop_rounded,
          'iconColor': Color(0xFFBA7517),
          'iconBg': Color(0xFF2A2215),
        },
        {
          'label': 'Weight',
          'value': weight,
          'unit': 'kg',
          'status': weightStatus,
          'isHigh': weightHigh,
          'icon': Icons.monitor_weight_rounded,
          'iconColor': Color(0xFF1D9E75),
          'iconBg': Color(0xFF1A2A22),
        },
        {
          'label': 'SpO2',
          'value': spo2,
          'unit': 'oxygen',
          'status': spo2Status,
          'isHigh': spo2High,
          'icon': Icons.air_rounded,
          'iconColor': Color(0xFF7F77DD),
          'iconBg': Color(0xFF1E1A2E),
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAiInsightCard(),
                    SizedBox(height: 16),
                    _buildSectionTitle('Today\'s vitals'),
                    SizedBox(height: 10),
                    _buildVitalsGrid(),
                    SizedBox(height: 12),
                    _buildLogVitalsBtn(context),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: primaryBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Icon(Icons.chevron_left_rounded,
                  color: primary, size: 22),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text('Health',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
          ),
          GestureDetector(
            onTap: () async {
              final updated = await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => LogVitalsScreen()));
              if (updated == true) {
                _loadVitals();
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF1A2A22),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primary, width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: primary, size: 14),
                  SizedBox(width: 4),
                  Text('Log vitals',
                      style: TextStyle(
                          fontSize: 11,
                          color: primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section title ─────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: textColor));
  }

  // ── AI insight card ───────────────────────
  Widget _buildAiInsightCard() {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color(0xFF1E1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Color(0xFF7F77DD).withValues(alpha: 0.4), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Color(0xFF7F77DD).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome_rounded,
                    color: Color(0xFF7F77DD), size: 14),
              ),
              SizedBox(width: 8),
              Text('AI health insights',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7F77DD))),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFF7F77DD).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Updated today',
                    style: TextStyle(fontSize: 8, color: Color(0xFF7F77DD))),
              ),
            ],
          ),
          SizedBox(height: 10),
          _insightRow(Color(0xFFE24B4A),
              'Blood sugar high (142 mg/dL). Avoid sugary foods today.'),
          _insightRow(Color(0xFF1D9E75),
              'BP normal (120/80). Keep maintaining current diet.'),
          _insightRow(Color(0xFFBA7517),
              'HbA1c 7.2% from last lab report. Schedule follow-up.'),
          _insightRow(Color(0xFF7F77DD),
              'Flu vaccine due in 24 days. Book at Apollo Hospital.'),
          SizedBox(height: 6),
          GestureDetector(
            onTap: () => _showAiHealthReport(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('View full AI report →',
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7F77DD),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightRow(Color dotColor, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 11, color: textLightColor, height: 1.4)),
          ),
        ],
      ),
    );
  }

  // ── Vitals grid ───────────────────────────
  Widget _buildVitalsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.3,
      children: _vitals.map((v) {
        final isHigh = v['isHigh'] as bool;
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isHigh
                    ? Color(0xFFBA7517).withValues(alpha: 0.5)
                    : borderColor,
                width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: v['iconBg'] as Color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(v['icon'] as IconData,
                        color: v['iconColor'] as Color, size: 13),
                  ),
                  Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isHigh
                          ? Color(0xFF2A2215)
                          : Color(0xFF1A2A22),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(v['status'] as String,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: isHigh
                              ? Color(0xFFBA7517)
                              : Color(0xFF1D9E75),
                        )),
                  ),
                ],
              ),
              Spacer(),
              Text(v['value'] as String,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor)),
              Text(v['unit'] as String,
                  style: TextStyle(fontSize: 9, color: textMutedColor)),
              SizedBox(height: 2),
              Text(v['label'] as String,
                  style: TextStyle(fontSize: 10, color: textDimColor)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Log vitals button ─────────────────────
  Widget _buildLogVitalsBtn(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.push(context,
            MaterialPageRoute(builder: (_) => LogVitalsScreen()));
        if (updated == true) {
          _loadVitals();
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: textColor, size: 16),
            SizedBox(width: 6),
            Text('Log today\'s vitals',
                style: TextStyle(
                    fontSize: 13,
                    color: textColor,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ── Medicine card ─────────────────────────
  Widget _buildMedicineCard(Map<String, dynamic> med) {
    final isDone = med['done'] as bool;
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(0xFF1A2A22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.medication_rounded,
                color: Color(0xFF1D9E75), size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med['name'] as String,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor)),
                SizedBox(height: 2),
                Text('${med['time']} · ${med['instruction']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDone ? Colors.white38 : Color(0xFF1D9E75),
                    )),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => med['done'] = !isDone),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isDone ? primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? primary : Color(0xFF1D9E75),
                  width: 1.5,
                ),
              ),
              child: isDone
                  ? Icon(Icons.check_rounded,
                      color: textColor, size: 14)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showAiHealthReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: white24Color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('AI health report',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor)),
                  Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Color(0xFF7F77DD).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('Today',
                        style:
                            TextStyle(fontSize: 9, color: Color(0xFF7F77DD))),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Overall score
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1E1A2E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Color(0xFF7F77DD).withValues(alpha: 0.3),
                      width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Color(0xFF7F77DD).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Color(0xFF7F77DD), width: 2),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('78',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF7F77DD))),
                            Text('/100',
                                style: TextStyle(
                                    fontSize: 8, color: Color(0xFF7F77DD))),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Overall health score',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textColor)),
                          SizedBox(height: 4),
                          Text('Moderate — needs attention',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFF7F77DD))),
                          SizedBox(height: 2),
                          Text('Based on vitals + lab + doctor notes',
                              style: TextStyle(
                                  fontSize: 10, color: textMutedColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),

              // Critical alert
              Text('Critical alerts',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF2A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Color(0xFFE24B4A), width: 0.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_rounded,
                        color: Color(0xFFE24B4A), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Blood sugar elevated',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE24B4A))),
                          SizedBox(height: 4),
                          Text(
                              'Post-meal sugar 142 mg/dL is above normal. Reduce carbohydrate intake and increase physical activity.',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white60,
                                  height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),

              // Good indicators
              Text('Good indicators',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF1A2A22),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Color(0xFF1D9E75), width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Color(0xFF1D9E75), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          'BP normal · SpO2 excellent · Weight stable · Medicine adherence 80%',
                          style: TextStyle(
                              fontSize: 11,
                              color: textLightColor,
                              height: 1.5)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),

              // Recommendations
              Text('AI recommendations',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              SizedBox(height: 8),
              _recommendationCard(Color(0xFFE24B4A),
                  'Walk 30 mins daily to help control blood sugar levels'),
              _recommendationCard(Color(0xFFBA7517),
                  'Schedule HbA1c test — last done 45 days ago'),
              _recommendationCard(Color(0xFF7F77DD),
                  'Flu vaccine due in 24 days — book at Apollo Hospital'),
              _recommendationCard(Color(0xFF1D9E75),
                  'Take Glipizide at 2 PM — pending today'),
              SizedBox(height: 14),

              // Source info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF2C2A2A),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Color(0xFF3A3A3A), width: 0.5),
                ),
                child: Text(
                    'Based on: Manual vitals · Lab report (Mar 18) · Dr. Rajesh notes (Mar 20) · Prescription data',
                    style: TextStyle(
                        fontSize: 10, color: textMutedColor, height: 1.5)),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recommendationCard(Color dotColor, String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF2C2A2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFF3A3A3A), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 11, color: textLightColor, height: 1.4)),
          ),
        ],
      ),
    );
  }
} // ← _HealthScreenState ends here
