import 'package:flutter/material.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  static const Color primary     = Color(0xFF0F6E56);
  static const Color primaryBg   = Color(0xFF2C2A2A);
  static const Color cardBg      = Color(0xFF1A1A1A);
  static const Color borderColor = Color(0xFF3A3A3A);

  final List<Map<String, dynamic>> _upcoming = [
    {
      'name': 'Flu vaccine',
      'dueDate': 'Apr 15, 2026',
      'daysLeft': 24,
      'hospital': 'Apollo Hospital',
      'urgent': true,
    },
    {
      'name': 'Hepatitis B booster',
      'dueDate': 'Jun 1, 2026',
      'daysLeft': 71,
      'hospital': 'Any hospital',
      'urgent': false,
    },
  ];

  final List<Map<String, dynamic>> _completed = [
    {
      'name': 'COVID-19 booster',
      'givenDate': 'Jan 10, 2026',
      'hospital': 'Apollo Hospital',
      'nextDue': 'Jan 2027',
    },
    {
      'name': 'Tetanus (TD)',
      'givenDate': 'Mar 5, 2025',
      'hospital': 'Fortis Malar',
      'nextDue': 'Mar 2035',
    },
    {
      'name': 'Typhoid vaccine',
      'givenDate': 'Dec 20, 2024',
      'hospital': 'MIOT International',
      'nextDue': 'Dec 2027',
    },
    {
      'name': 'Hepatitis A',
      'givenDate': 'Jun 15, 2024',
      'hospital': 'Apollo Hospital',
      'nextDue': 'Jun 2034',
    },
    {
      'name': 'Pneumococcal',
      'givenDate': 'Feb 1, 2024',
      'hospital': 'Kauvery Hospital',
      'nextDue': 'Feb 2029',
    },
    {
      'name': 'MMR vaccine',
      'givenDate': 'Jan 5, 2020',
      'hospital': 'Apollo Hospital',
      'nextDue': 'Lifetime',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSummaryCard(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Upcoming vaccinations'),
                    const SizedBox(height: 10),
                    ..._upcoming.map((v) => _buildUpcomingCard(v)),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Completed vaccinations'),
                    const SizedBox(height: 10),
                    ..._completed.map((v) => _buildCompletedCard(v)),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddFab(),
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
            child: Text('Vaccination tracker',
              style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Summary card ──────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _sumItem(
            (_upcoming.length + _completed.length).toString(),
            'Total'),
          _vDivider(),
          _sumItem(_completed.length.toString(), 'Completed'),
          _vDivider(),
          _sumItem(_upcoming.length.toString(), 'Upcoming'),
          _vDivider(),
          _sumItem('1', 'Due soon'),
        ],
      ),
    );
  }

  Widget _sumItem(String num, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(num,
            style: const TextStyle(fontSize: 18,
              fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 2),
          Text(label,
            style: const TextStyle(fontSize: 9,
              color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 0.5, height: 30, color: Colors.white24);

  // ── Section title ─────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(title,
      style: const TextStyle(fontSize: 14,
        fontWeight: FontWeight.w600, color: Colors.white));
  }

  // ── Upcoming card ─────────────────────────
  Widget _buildUpcomingCard(Map<String, dynamic> vacc) {
    final isUrgent = vacc['urgent'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUrgent
              ? const Color(0xFFBA7517)
              : borderColor,
          width: isUrgent ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: isUrgent
                      ? const Color(0xFF2A2215)
                      : const Color(0xFF1E1A2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.vaccines_rounded,
                  color: isUrgent
                      ? const Color(0xFFBA7517)
                      : const Color(0xFF7F77DD),
                  size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vacc['name'] as String,
                      style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                    const SizedBox(height: 3),
                    Text('Due: ${vacc['dueDate']}',
                      style: const TextStyle(fontSize: 11,
                        color: Colors.white54)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? const Color(0xFF2A2215)
                      : const Color(0xFF1E1A2E),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isUrgent
                        ? const Color(0xFFBA7517)
                        : const Color(0xFF7F77DD),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  isUrgent
                      ? '${vacc['daysLeft']} days'
                      : '${vacc['daysLeft']} days',
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: isUrgent
                        ? const Color(0xFFBA7517)
                        : const Color(0xFF7F77DD),
                  )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.local_hospital_rounded,
                  size: 12, color: Colors.white38),
              const SizedBox(width: 4),
              Text(vacc['hospital'] as String,
                style: const TextStyle(fontSize: 11,
                  color: Colors.white54)),
              const Spacer(),
              GestureDetector(
                onTap: () => _markAsDone(vacc),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2A22),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primary, width: 0.5),
                  ),
                  child: const Text('Mark as done',
                    style: TextStyle(fontSize: 11, color: primary,
                      fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Completed card ────────────────────────
  Widget _buildCompletedCard(Map<String, dynamic> vacc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2A22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: Color(0xFF1D9E75), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vacc['name'] as String,
                  style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 2),
                Text('Given: ${vacc['givenDate']} · ${vacc['hospital']}',
                  style: const TextStyle(fontSize: 10,
                    color: Colors.white54)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Next due',
                style: TextStyle(fontSize: 9, color: Colors.white38)),
              const SizedBox(height: 2),
              Text(vacc['nextDue'] as String,
                style: const TextStyle(fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D9E75))),
            ],
          ),
        ],
      ),
    );
  }

  // ── Add FAB ───────────────────────────────
  Widget _buildAddFab() {
    return GestureDetector(
      onTap: () => _showAddVaccineSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Add vaccine',
              style: TextStyle(fontSize: 13,
                color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ── Mark as done ──────────────────────────
  void _markAsDone(Map<String, dynamic> vacc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Mark as done',
          style: TextStyle(fontSize: 16,
            fontWeight: FontWeight.w600, color: Colors.white)),
        content: Text(
          'Mark ${vacc['name']} as completed?',
          style: const TextStyle(fontSize: 13,
            color: Colors.white54, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
              style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _upcoming.remove(vacc);
                _completed.insert(0, {
                  'name': vacc['name'],
                  'givenDate': 'Mar 22, 2026',
                  'hospital': vacc['hospital'],
                  'nextDue': 'Next year',
                });
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${vacc['name']} marked as done!'),
                  backgroundColor: primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Mark done',
              style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Add vaccine sheet ─────────────────────
  void _showAddVaccineSheet() {
    final TextEditingController nameController =
        TextEditingController();
    final TextEditingController dateController =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          20, 16, 20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Add vaccine',
              style: TextStyle(fontSize: 15,
                fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 16),
            const Text('Vaccine name',
              style: TextStyle(fontSize: 12,
                color: Colors.white54)),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Flu vaccine',
                hintStyle: const TextStyle(
                    color: Colors.white38, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF2C2A2A),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: primary, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: borderColor, width: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Due date',
              style: TextStyle(fontSize: 12,
                color: Colors.white54)),
            const SizedBox(height: 6),
            TextField(
              controller: dateController,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Apr 15, 2026',
                hintStyle: const TextStyle(
                    color: Colors.white38, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF2C2A2A),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: primary, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: borderColor, width: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      dateController.text.isNotEmpty) {
                    setState(() {
                      _upcoming.add({
                        'name': nameController.text,
                        'dueDate': dateController.text,
                        'daysLeft': 30,
                        'hospital': 'Any hospital',
                        'urgent': false,
                      });
                    });
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Add vaccine',
                  style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}