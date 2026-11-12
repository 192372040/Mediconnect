import 'package:flutter/material.dart';

class VisitHistoryScreen extends StatelessWidget {
  const VisitHistoryScreen({super.key});

  static const Color primary     = Color(0xFF0F6E56);
  static const Color primaryBg   = Color(0xFF2C2A2A);
  static const Color cardBg      = Color(0xFF1A1A1A);
  static const Color borderColor = Color(0xFF3A3A3A);

  final List<Map<String, dynamic>> _visits = const [
    {
      'doctor': 'Dr. Rajesh Kumar',
      'specialization': 'Endocrinologist',
      'hospital': 'Apollo Hospital',
      'date': 'Mar 20, 2026',
      'notes': 'Routine diabetes checkup. HbA1c improved significantly.',
      'color': Color(0xFF0F6E56),
      'tags': ['Prescription', 'Lab order'],
      'tagColors': [Color(0xFF378ADD), Color(0xFF1D9E75)],
      'tagBgs': [Color(0xFF1A2A3A), Color(0xFF1A2A22)],
    },
    {
      'doctor': 'Dr. Sneha Patel',
      'specialization': 'General Physician',
      'hospital': 'Fortis Malar',
      'date': 'Mar 10, 2026',
      'notes': 'Fever and cold treatment. Prescribed antibiotics for 5 days.',
      'color': Color(0xFF185FA5),
      'tags': ['Prescription'],
      'tagColors': [Color(0xFF378ADD)],
      'tagBgs': [Color(0xFF1A2A3A)],
    },
    {
      'doctor': 'Dr. Arjun Menon',
      'specialization': 'Cardiologist',
      'hospital': 'Apollo Hospital',
      'date': 'Feb 28, 2026',
      'notes': 'ECG normal. BP slightly elevated. Monitor weekly.',
      'color': Color(0xFFBA7517),
      'tags': ['Prescription', 'Scan'],
      'tagColors': [Color(0xFF378ADD), Color(0xFF7F77DD)],
      'tagBgs': [Color(0xFF1A2A3A), Color(0xFF1E1A2E)],
    },
    {
      'doctor': 'Dr. Priya Nair',
      'specialization': 'Neurologist',
      'hospital': 'MIOT International',
      'date': 'Feb 15, 2026',
      'notes': 'Migraine assessment. Prescribed pain relief medication.',
      'color': Color(0xFF7F77DD),
      'tags': ['Prescription'],
      'tagColors': [Color(0xFF378ADD)],
      'tagBgs': [Color(0xFF1A2A3A)],
    },
    {
      'doctor': 'Dr. Rajesh Kumar',
      'specialization': 'Endocrinologist',
      'hospital': 'Apollo Hospital',
      'date': 'Jan 20, 2026',
      'notes': 'Diabetes quarterly review. Medication dosage adjusted.',
      'color': Color(0xFF0F6E56),
      'tags': ['Prescription', 'Lab order'],
      'tagColors': [Color(0xFF378ADD), Color(0xFF1D9E75)],
      'tagBgs': [Color(0xFF1A2A3A), Color(0xFF1A2A22)],
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
            _buildSummaryRow(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                itemCount: _visits.length,
                itemBuilder: (_, i) => _buildVisitItem(_visits[i], i),
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
              child: const Icon(Icons.chevron_left_rounded,
                  color: primary, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Visit history',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                color: Colors.white)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.filter_list_rounded,
                    color: Colors.white54, size: 14),
                SizedBox(width: 4),
                Text('Filter',
                  style: TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary row ───────────────────────────
  Widget _buildSummaryRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _sumChip(Icons.local_hospital_rounded, '5', 'Total visits'),
          _vDivider(),
          _sumChip(Icons.person_rounded, '3', 'Doctors'),
          _vDivider(),
          _sumChip(Icons.business_rounded, '3', 'Hospitals'),
        ],
      ),
    );
  }

  Widget _sumChip(IconData icon, String num, String label) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(num,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: Colors.white)),
              Text(label,
                style: const TextStyle(fontSize: 9, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 0.5, height: 28, color: Colors.white24);

  // ── Visit timeline item ───────────────────
  Widget _buildVisitItem(Map<String, dynamic> visit, int index) {
    final isLast = index == _visits.length - 1;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: visit['color'] as Color,
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryBg, width: 2),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: Colors.white, size: 16),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: borderColor,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Content card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor + date
                  Row(
                    children: [
                      Expanded(
                        child: Text(visit['doctor'] as String,
                          style: const TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2A22),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(visit['date'] as String,
                          style: const TextStyle(fontSize: 9,
                            color: Color(0xFF1D9E75))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Specialization + hospital
                  Text(
                    '${visit['specialization']} · ${visit['hospital']}',
                    style: const TextStyle(fontSize: 11, color: Colors.white54)),
                  const SizedBox(height: 8),

                  // Notes
                  Text(visit['notes'] as String,
                    style: const TextStyle(fontSize: 12,
                      color: Colors.white70, height: 1.4)),
                  const SizedBox(height: 8),

                  // Tags
                  Wrap(
                    spacing: 6,
                    children: List.generate(
                      (visit['tags'] as List).length,
                      (i) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (visit['tagBgs'] as List)[i] as Color,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          (visit['tags'] as List)[i] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: (visit['tagColors'] as List)[i] as Color,
                            fontWeight: FontWeight.w500,
                          )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}