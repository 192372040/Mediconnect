import 'package:flutter/material.dart';
import 'package:my_project/Doctor/AI.dart';
import 'package:my_project/Doctor/Schdule.dart';
import 'package:my_project/Doctor/Patients.dart';
import 'package:my_project/Doctor/Doctordashscreen.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';

// ────────────────────────────────────────────────
// Prescription Detail Screen
// ────────────────────────────────────────────────
class PrescriptionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> prescription;
  const PrescriptionDetailScreen({Key? key, required this.prescription})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFF252525);
    const Color card = Color(0xFF1E1E1E);
    const Color green = Color(0xFF00C48C);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: green, size: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text('Prescription details',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[800], height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Patient card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17293A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[800]!),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.blue[600],
                          child: Builder(builder: (_) {
                            final rawN = (prescription['patient_name'] ?? '').toString().trim();
                            final rawE = (prescription['patient_email'] ?? '').toString().trim();
                            final name = rawN.isNotEmpty
                                ? rawN
                                : (rawE.contains('@') ? rawE.split('@')[0] : 'Patient');
                            return Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'P',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            );
                          }),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Builder(builder: (_) {
                                final rawN = (prescription['patient_name'] ?? '').toString().trim();
                                final rawE = (prescription['patient_email'] ?? '').toString().trim();
                                final name = rawN.isNotEmpty
                                    ? rawN
                                    : (rawE.contains('@') ? rawE.split('@')[0] : 'Patient');
                                return Text(
                                  name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                );
                              }),

                              const SizedBox(height: 4),
                              Text(
                                prescription['patient_email'] ?? '',
                                style: TextStyle(
                                    color: Colors.blue[300], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Diagnosis
                  _section(
                    'Diagnosis',
                    prescription['diagnosis'] ?? 'N/A',
                    green,
                    card,
                  ),
                  const SizedBox(height: 12),

                  // Medicines
                  _section(
                    'Medicines',
                    prescription['medicines'] ?? 'N/A',
                    const Color(0xFF64B5F6),
                    card,
                  ),
                  const SizedBox(height: 12),

                  // Doctor Notes
                  _section(
                    'Doctor notes',
                    prescription['doctor_notes'] ?? 'N/A',
                    Colors.orange,
                    card,
                  ),
                  const SizedBox(height: 12),

                  // Date
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[800]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.white38, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          'Created: ${prescription['created_at'] ?? ''}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
      String title, String content, Color accent, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Records Screen
// ────────────────────────────────────────────────
class MyRecordsScreen extends StatefulWidget {
  final String doctorId;
  const MyRecordsScreen({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<MyRecordsScreen> createState() => _MyRecordsScreenState();
}

class _MyRecordsScreenState extends State<MyRecordsScreen> {
  static const Color bgColor = Color(0xFF252525);
  static const Color primaryBlue = Color(0xFF1E64B0);
  static const Color cardBg = Color(0xFF1E1E1E);
  static const Color green = Color(0xFF00C48C);

  List<dynamic> _prescriptions = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  String? _doctorName;
  int _totalPatients = 0;
  double _rating = 0;
  String _activeFilter = 'All'; // 'All' | 'Prescriptions'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final summary = await ApiService.getDoctorSummary(widget.doctorId);
    _doctorName = summary?["full_name"] ?? "";
    _rating = double.tryParse(
            summary?["rating"]?.toString() ?? "0") ??
        0;

    // Fetch all doctor appointments for total patients
    final appts =
        await ApiService.getDoctorAppointments(_doctorName!);
    final uniquePatients = <String>{};
    for (final a in appts) {
      uniquePatients.add(a["patient_email"] ?? "");
    }
    _totalPatients = uniquePatients.length;

    // Fetch prescriptions written by this doctor
    final rxList =
        await ApiService.getDoctorPrescriptions(_doctorName!);

    setState(() {
      _prescriptions = rxList;
      _filtered = rxList;
      _loading = false;
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      if (filter == 'All' || filter == 'Prescriptions') {
        _filtered = _prescriptions;
      }
    });
  }

  // Month stats: count prescriptions created this calendar month
  int get _thisMonthRx {
    final now = DateTime.now();
    return _prescriptions.where((rx) {
      final raw = rx["created_at"]?.toString() ?? "";
      final d = DateTime.tryParse(raw);
      return d != null && d.month == now.month && d.year == now.year;
    }).length;
  }

  // Month patients: unique patients prescribed this month
  int get _thisMonthPatients {
    final now = DateTime.now();
    final set = <String>{};
    for (final rx in _prescriptions) {
      final raw = rx["created_at"]?.toString() ?? "";
      final d = DateTime.tryParse(raw);
      if (d != null && d.month == now.month && d.year == now.year) {
        set.add(rx["patient_email"]?.toString() ?? "");
      }
    }
    return set.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Divider(color: Colors.grey[800], height: 1),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryBlue))
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: primaryBlue,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildStats(),
                          const SizedBox(height: 20),
                          _buildFilters(),
                          const SizedBox(height: 20),
                          const Text('Prescriptions',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 14),
                          _buildPrescriptionList(),
                          const SizedBox(height: 24),
                          _buildSummaryCard(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 18),
              onPressed: () => Navigator.pop(context),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text('My records',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _statCard(_prescriptions.length.toString(), 'Prescriptions',
            Colors.blue[400]!),
        const SizedBox(width: 12),
        _statCard(_totalPatients.toString(), 'Patients', green),
      ],
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: ['All', 'Prescriptions'].map((f) {
        final active = _activeFilter == f;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => _applyFilter(f),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: active ? primaryBlue : Colors.transparent,
                border: Border.all(
                    color: active ? primaryBlue : Colors.grey[700]!),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(f,
                  style: TextStyle(
                      color: active ? Colors.white : Colors.grey[500],
                      fontSize: 13,
                      fontWeight: active
                          ? FontWeight.bold
                          : FontWeight.w500)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrescriptionList() {
    if (_filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: const Center(
          child: Text('No prescriptions found',
              style: TextStyle(color: Colors.white54)),
        ),
      );
    }
    return Column(
      children: _filtered.asMap().entries.map((entry) {
        final i = entry.key;
        final rx = entry.value as Map;
        final rawPName = (rx['patient_name'] ?? '').toString().trim();

        final rawPEmail = (rx['patient_email'] ?? '').toString().trim();
        final patientName = rawPName.isNotEmpty
            ? rawPName
            : (rawPEmail.contains('@') ? rawPEmail.split('@')[0] : 'Patient');
        final diagnosis = rx['diagnosis'] ?? 'N/A';

        final createdAt = rx['created_at']?.toString() ?? '';
        DateTime? date = DateTime.tryParse(createdAt);
        final dateStr = date != null
            ? '${date.day}/${date.month}/${date.year}'
            : createdAt;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrescriptionDetailScreen(
                  prescription: Map<String, dynamic>.from(rx)),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border.all(color: green.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.article_outlined,
                      color: green, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prescription #${i + 1}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(patientName,
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(diagnosis,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Rx',
                          style: TextStyle(
                              color: green,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 6),
                    Text(dateStr,
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 10)),
                    const SizedBox(height: 4),
                    const Icon(Icons.chevron_right,
                        color: Colors.white38, size: 16),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: primaryBlue.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This month summary',
              style: TextStyle(
                  color: Colors.blue[400],
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryStat(
                  _thisMonthPatients.toString(), 'Patients', Colors.blue[300]!),
              _divider(),
              _summaryStat(
                  _thisMonthRx.toString(), 'Rx written', Colors.blue[300]!),
              _divider(),
              Column(
                children: [
                  Text(
                    _rating > 0 ? _rating.toStringAsFixed(1) : 'N/A',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.star,
                          color: Color(0xFFC7781E), size: 12),
                      SizedBox(width: 4),
                      Text('Rating',
                          style: TextStyle(
                              color: Color(0xFFC7781E),
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 30, color: Colors.grey[800]);

  Widget _buildBottomNavBar(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent),
      child: BottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        DoctorDashboardScreen(doctorId: widget.doctorId)),
                (r) => false);
          } else if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        MyScheduleScreen(doctorId: widget.doctorId)));
          } else if (index == 2) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        MyPatientsScreen(doctorId: widget.doctorId)));
          } else if (index == 3) {
            return; // already on Records
          } else if (index == 4) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        DoctorAssistantScreen(doctorId: widget.doctorId)));
          }
        },
        backgroundColor: const Color(0xFF1E1E1E),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        currentIndex: 3,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home_outlined)),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.calendar_today_outlined)),
              label: 'Schedule'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person_outline)),
              label: 'Patients'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.description_outlined)),
              label: 'Records'),
          // ✅ FIXED: was 'Profile' with circle_outlined icon — now correctly 'AI'
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.smart_toy_outlined)),
              label: 'AI'),
        ],
      ),
    );
  }
}
