import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogVitalsScreen extends StatefulWidget {
  const LogVitalsScreen({super.key});

  @override
  State<LogVitalsScreen> createState() => _LogVitalsScreenState();
}

class _LogVitalsScreenState extends State<LogVitalsScreen> {
  static const Color primary     = Color(0xFF0F6E56);
  static const Color primaryBg   = Color(0xFF2C2A2A);
  static const Color cardBg      = Color(0xFF1A1A1A);
  static const Color borderColor = Color(0xFF3A3A3A);

  // ── Controllers ───────────────────────────
  final TextEditingController _systolicController  = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _sugarController     = TextEditingController();
  final TextEditingController _weightController    = TextEditingController();
  final TextEditingController _spo2Controller      = TextEditingController();
  final TextEditingController _pulseController     = TextEditingController();

  String _sugarType = 'Post meal';
  bool _saved = false;

  final List<String> _sugarTypes = ['Fasting', 'Post meal', 'Random'];

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _sugarController.dispose();
    _weightController.dispose();
    _spo2Controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _saveVitals() async {
    final prefs = await SharedPreferences.getInstance();
    
    final sys = _systolicController.text.trim();
    final dia = _diastolicController.text.trim();
    if (sys.isNotEmpty && dia.isNotEmpty) {
      await prefs.setString("vital_bp", "$sys/$dia");
      int sysInt = int.tryParse(sys) ?? 120;
      int diaInt = int.tryParse(dia) ?? 80;
      if (sysInt > 130 || diaInt > 80) {
        await prefs.setString("vital_bp_status", "High");
        await prefs.setBool("vital_bp_high", true);
      } else {
        await prefs.setString("vital_bp_status", "Normal");
        await prefs.setBool("vital_bp_high", false);
      }
    }
    
    final sugar = _sugarController.text.trim();
    if (sugar.isNotEmpty) {
      await prefs.setString("vital_sugar", sugar);
      int sugarInt = int.tryParse(sugar) ?? 100;
      if (sugarInt > 140) {
        await prefs.setString("vital_sugar_status", "High");
        await prefs.setBool("vital_sugar_high", true);
      } else {
        await prefs.setString("vital_sugar_status", "Normal");
        await prefs.setBool("vital_sugar_high", false);
      }
    }
    
    final weight = _weightController.text.trim();
    if (weight.isNotEmpty) {
      await prefs.setString("vital_weight", weight);
      await prefs.setString("vital_weight_status", "Normal");
      await prefs.setBool("vital_weight_high", false);
    }
    
    final spo2 = _spo2Controller.text.trim();
    if (spo2.isNotEmpty) {
      await prefs.setString("vital_spo2", "$spo2%");
      int spo2Int = int.tryParse(spo2) ?? 98;
      if (spo2Int < 95) {
        await prefs.setString("vital_spo2_status", "Low");
        await prefs.setBool("vital_spo2_high", true);
      } else {
        await prefs.setString("vital_spo2_status", "Normal");
        await prefs.setBool("vital_spo2_high", false);
      }
    }

    final pulse = _pulseController.text.trim();
    if (pulse.isNotEmpty) {
      await prefs.setString("vital_pulse", pulse);
    }

    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.of(context).maybePop(true);
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDateRow(),
                    const SizedBox(height: 16),
                    _buildBpCard(),
                    const SizedBox(height: 12),
                    _buildSugarCard(),
                    const SizedBox(height: 12),
                    _buildWeightSpO2Row(),
                    const SizedBox(height: 12),
                    _buildPulseCard(),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                    const SizedBox(height: 30),
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: primaryBg,
        border: Border(
            bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white, shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1),
              ),
              child: const Icon(Icons.chevron_left_rounded,
                  color: primary, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Log vitals',
              style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          const Text('Mar 22, 2026',
            style: TextStyle(fontSize: 12, color: Colors.white54)),
        ],
      ),
    );
  }

  // ── Date row ──────────────────────────────
  Widget _buildDateRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded,
              color: Colors.white38, size: 16),
          const SizedBox(width: 8),
          const Text('Today — March 22, 2026',
            style: TextStyle(fontSize: 12, color: Colors.white54)),
          const Spacer(),
          const Icon(Icons.access_time_rounded,
              color: Colors.white38, size: 16),
          const SizedBox(width: 5),
          Text(
            '${TimeOfDay.now().hourOfPeriod}:${TimeOfDay.now().minute.toString().padLeft(2, '0')} ${TimeOfDay.now().period.name.toUpperCase()}',
            style: const TextStyle(fontSize: 12, color: Colors.white54)),
        ],
      ),
    );
  }

  // ── BP card ───────────────────────────────
  Widget _buildBpCard() {
    return _vitalCard(
      icon: Icons.speed_rounded,
      iconColor: const Color(0xFF185FA5),
      iconBg: const Color(0xFF1A2A3A),
      title: 'Blood pressure',
      unit: 'mmHg',
      child: Row(
        children: [
          Expanded(
            child: _inputField(
              controller: _systolicController,
              hint: '120',
              label: 'Systolic',
              color: const Color(0xFF185FA5),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('/',
              style: TextStyle(fontSize: 24,
                color: Colors.white38, fontWeight: FontWeight.w300)),
          ),
          Expanded(
            child: _inputField(
              controller: _diastolicController,
              hint: '80',
              label: 'Diastolic',
              color: const Color(0xFF185FA5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sugar card ────────────────────────────
  Widget _buildSugarCard() {
    return _vitalCard(
      icon: Icons.water_drop_rounded,
      iconColor: const Color(0xFFBA7517),
      iconBg: const Color(0xFF2A2215),
      title: 'Blood sugar',
      unit: 'mg/dL',
      child: Column(
        children: [
          _inputField(
            controller: _sugarController,
            hint: '100',
            label: 'Sugar level',
            color: const Color(0xFFBA7517),
          ),
          const SizedBox(height: 10),
          Row(
            children: _sugarTypes.map((type) {
              final sel = _sugarType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _sugarType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                      right: type != _sugarTypes.last ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFBA7517)
                          : const Color(0xFF2C2A2A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: sel
                            ? const Color(0xFFBA7517)
                            : borderColor,
                        width: 0.5,
                      ),
                    ),
                    child: Text(type,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: sel ? Colors.white : Colors.white38,
                        fontWeight: sel
                            ? FontWeight.w600
                            : FontWeight.normal,
                      )),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Weight + SpO2 row ─────────────────────
  Widget _buildWeightSpO2Row() {
    return Row(
      children: [
        Expanded(
          child: _vitalCard(
            icon: Icons.monitor_weight_rounded,
            iconColor: const Color(0xFF1D9E75),
            iconBg: const Color(0xFF1A2A22),
            title: 'Weight',
            unit: 'kg',
            child: _inputField(
              controller: _weightController,
              hint: '68.5',
              label: 'kg',
              color: const Color(0xFF1D9E75),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _vitalCard(
            icon: Icons.air_rounded,
            iconColor: const Color(0xFF7F77DD),
            iconBg: const Color(0xFF1E1A2E),
            title: 'SpO2',
            unit: '%',
            child: _inputField(
              controller: _spo2Controller,
              hint: '98',
              label: '%',
              color: const Color(0xFF7F77DD),
            ),
          ),
        ),
      ],
    );
  }

  // ── Pulse card ────────────────────────────
  Widget _buildPulseCard() {
    return _vitalCard(
      icon: Icons.favorite_rounded,
      iconColor: const Color(0xFFE24B4A),
      iconBg: const Color(0xFF2A1A1A),
      title: 'Pulse rate',
      unit: 'bpm',
      child: _inputField(
        controller: _pulseController,
        hint: '72',
        label: 'beats per min',
        color: const Color(0xFFE24B4A),
      ),
    );
  }

  // ── Vital card wrapper ────────────────────
  Widget _vitalCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String unit,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 15),
              ),
              const SizedBox(width: 8),
              Text(title,
                style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600, color: Colors.white)),
              const Spacer(),
              Text(unit,
                style: const TextStyle(fontSize: 11,
                  color: Colors.white38)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ── Input field ───────────────────────────
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required String label,
    required Color color,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
      ],
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700,
          color: Colors.white24),
        labelText: label,
        labelStyle: TextStyle(fontSize: 11, color: color),
        filled: true,
        fillColor: const Color(0xFF2C2A2A),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderColor, width: 0.5),
        ),
      ),
    );
  }

  // ── Save button ───────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _saved ? null : _saveVitals,
        style: ElevatedButton.styleFrom(
          backgroundColor: _saved
              ? const Color(0xFF1A2A22)
              : primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: _saved
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle_rounded,
                      color: Color(0xFF1D9E75), size: 20),
                  SizedBox(width: 8),
                  Text('Vitals saved!',
                    style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D9E75))),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.save_rounded,
                      color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Save vitals',
                    style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
                ],
              ),
      ),
    );
  }
}