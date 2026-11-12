import 'package:flutter/material.dart';
import 'package:my_project/Patientdashboard/AppointmentBookingScreen.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';
class HospitalDetailScreen extends StatefulWidget {
  final String hospitalName;
  final String hospitalId;
  const HospitalDetailScreen({super.key, required this.hospitalName, required this.hospitalId});

  @override
  State<HospitalDetailScreen> createState() => _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends State<HospitalDetailScreen> {
  static const Color primary     = Color(0xFF0F6E56);
  static const Color primaryBg   = Color(0xFF2C2A2A);
  static const Color cardBg      = Color(0xFF1A1A1A);
  static const Color borderColor = Color(0xFF3A3A3A);

  String _selectedDept = 'All';

  final List<String> _departments = [
    'All', 'General', 'Cardiology', 'Ortho', 'Neuro', 'Paeds'
  ];

  List<dynamic> doctors = [];
bool isLoading = true;

List<dynamic> get _filteredDoctors {
  if (_selectedDept == 'All') return doctors;

  return doctors.where((d) {
  final specialization = d['specialization']
    .toString()
    .toLowerCase();

if (_selectedDept == 'Cardiology') {
  return specialization.contains('cardio');
}

if (_selectedDept == 'Ortho') {
  return specialization.contains('ortho');
}

if (_selectedDept == 'Neuro') {
  return specialization.contains('neuro');
}

if (_selectedDept == 'General') {
  return specialization.contains('general');
}

return true;
  }).toList();
}
  @override
void initState() {
  super.initState();
  fetchDoctors();
}

Future<void> fetchDoctors() async {
  final data = await ApiService.getDoctors(widget.hospitalId);
 print(data); 
  setState(() {
    doctors = data;
    isLoading = false;
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
            _buildHospitalInfo(),
            _buildDeptFilter(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredDoctors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) =>
                    _buildDoctorCard(_filteredDoctors[i], context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: primaryBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
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
              child: const Icon(Icons.chevron_left_rounded, color: primary, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(widget.hospitalName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              overflow: TextOverflow.ellipsis),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2A22),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1D9E75), width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.directions_rounded, color: Color(0xFF1D9E75), size: 14),
                SizedBox(width: 4),
                Text('Directions', style: TextStyle(fontSize: 11, color: Color(0xFF1D9E75), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _hospitalRating {
    if (doctors.isEmpty) return '4.8 Rating';
    double total = 0;
    int count = 0;
    for (var d in doctors) {
      final r = double.tryParse(d['rating']?.toString() ?? '');
      if (r != null && r > 0) {
        total += r;
        count++;
      }
    }
    if (count > 0) {
      return '${(total / count).toStringAsFixed(1)} Rating';
    }
    return '4.8 Rating';
  }

  Widget _buildHospitalInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.hospitalName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('21 Greams Lane, Thousand Lights, Chennai',
            style: TextStyle(fontSize: 11, color: Colors.white70)),
          const SizedBox(height: 10),
          Row(
            children: [
              _statChip(Icons.access_time_rounded, 'Open 24/7'),
              const SizedBox(width: 8),
              _statChip(Icons.star_rounded, _hospitalRating),
              const SizedBox(width: 8),
              _statChip(Icons.location_on_rounded, '1.2 km'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 11),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDeptFilter() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: primaryBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _departments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final sel = _selectedDept == _departments[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedDept = _departments[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: sel ? primary : cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? primary : borderColor, width: 0.5),
              ),
              child: Text(_departments[i],
                style: TextStyle(
                  fontSize: 12,
                  color: sel ? Colors.white : Colors.white54,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                )),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          // ── Doctor info ─────────────────
          Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2A22),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(doctor['name']
    .toString()
    .substring(0, 2)
    .toUpperCase(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                      color: const Color(0xFF1D9E75))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor['name'] as String,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('${doctor['specialization']} · ${doctor['experience']} exp',
                      style: const TextStyle(fontSize: 11, color: Colors.white54)),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFEF9F27), size: 13),
                      const SizedBox(width: 3),
                      Text(doctor['rating'] as String,
                        style: const TextStyle(fontSize: 11, color: Colors.white54)),
                    ]),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(doctor['fee'] as String,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1D9E75))),
                  const Text('per visit', style: TextStyle(fontSize: 9, color: Colors.white38)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFF3A3A3A), height: 1),
          const SizedBox(height: 12),

          // ── Available slots ─────────────
          Row(children: const [
            Icon(Icons.access_time_rounded, color: Colors.white38, size: 13),
            SizedBox(width: 5),
            Text('Available slots', style: TextStyle(fontSize: 11, color: Colors.white54)),
          ]),
          const SizedBox(height: 8),

          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              // Available slots — green
              ...(List<String>.from(doctor['available_slots']
    .toString()
    .split(','))).map((slot) => GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AppointmentBookingScreen(
                      doctorName:     doctor['name']           as String,
                      specialization: doctor['specialization'] as String,
                      fee:            doctor['fee']            as String,
                      selectedSlot:   slot,
                      hospitalName:   widget.hospitalName,
                     
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2A22),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: const Color(0xFF1D9E75), width: 0.5),
                  ),
                  child: Text(slot,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF1D9E75), fontWeight: FontWeight.w500)),
                ),
              )),

              
            ],
          ),
        ],
      ),
    );
  }
}