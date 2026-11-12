import 'package:flutter/material.dart';
import 'Prescription.dart';
import 'PrescriptionShareHelper.dart';

class ReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> report;
  const ReportDetailScreen({super.key, required this.report});

  static const Color primary     = Color(0xFF0F6E56);
  static const Color primaryBg   = Color(0xFF2C2A2A);
  static const Color cardBg      = Color(0xFF1A1A1A);
  static const Color borderColor = Color(0xFF3A3A3A);

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
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildPreviewCard(context),
                    const SizedBox(height: 14),
                    _buildInfoCard(),
                    const SizedBox(height: 14),
                    _buildAiInsight(),
                    const SizedBox(height: 14),
                    _buildActionButtons(context),
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
          const Expanded(
            child: Text('Report detail',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          GestureDetector(
            onTap: () async {
              await PrescriptionShareHelper.sharePrescription(report, context: context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2A22),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1D9E75), width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.share_rounded, color: Color(0xFF1D9E75), size: 14),
                  SizedBox(width: 4),
                  Text('Share',
                    style: TextStyle(fontSize: 11, color: Color(0xFF1D9E75), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context){
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PrescriptionViewScreen(
  report: report,
),
        ),
      
      );
    },
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: report['iconBg'] as Color,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  report['badge'] == 'Rx'
                      ? Icons.description_rounded
                      : report['badge'] == 'Lab'
                          ? Icons.biotech_rounded
                          : Icons.image_rounded,
                  color: report['iconColor'] as Color,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text('Tap to preview',
                  style: TextStyle(
                    fontSize: 12,
                    color: (report['iconColor'] as Color).withValues(alpha: 0.7),
                  )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report['title'] as String,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text(report['subtitle'] as String,
                  style: const TextStyle(fontSize: 12, color: Colors.white54)),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          _infoRow('Report type',
            report['badge'] == 'Rx'
                ? 'Prescription'
                : report['badge'] == 'Lab'
                    ? 'Lab report'
                    : 'Scan'),
          _divider(),
          _infoRow('Source',    report['subtitle'] as String),
          _divider(),
          _infoRow('Date',      report['date']     as String),
          _divider(),
          _infoRow('File type', report['type']     as String),
          _divider(),
          _infoRow('File size', report['size']     as String),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white54)),
          const Spacer(),
          Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    height: 0.5, color: borderColor,
    margin: const EdgeInsets.symmetric(horizontal: 16));

  Widget _buildAiInsight() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF7F77DD).withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF7F77DD).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Color(0xFF7F77DD), size: 16),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI insight',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: Color(0xFF7F77DD))),
                SizedBox(height: 4),
                Text(
                  'Haemoglobin slightly low. Consider iron-rich diet with spinach, beans and red meat. All other parameters are within normal range. Follow up in 30 days.',
                  style: TextStyle(fontSize: 12, color: Colors.white60, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2A22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1D9E75), width: 0.5),
              ),
              child: Column(
                children: const [
                  Icon(Icons.download_rounded,
                      color: Color(0xFF1D9E75), size: 20),
                  SizedBox(height: 4),
                  Text('Download',
                    style: TextStyle(fontSize: 11, color: Color(0xFF1D9E75),
                      fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              await PrescriptionShareHelper.sharePrescription(report, context: context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2A3A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF185FA5), width: 0.5),
              ),
              child: Column(
                children: const [
                  Icon(Icons.share_rounded,
                      color: Color(0xFF185FA5), size: 20),
                  SizedBox(height: 4),
                  Text('Share',
                    style: TextStyle(fontSize: 11, color: Color(0xFF185FA5),
                      fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => _showDeleteDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE24B4A), width: 0.5),
              ),
              child: Column(
                children: const [
                  Icon(Icons.delete_rounded,
                      color: Color(0xFFE24B4A), size: 20),
                  SizedBox(height: 4),
                  Text('Delete',
                    style: TextStyle(fontSize: 11, color: Color(0xFFE24B4A),
                      fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete report',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this report? This action cannot be undone.',
          style: TextStyle(fontSize: 13, color: Colors.white54, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
              style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE24B4A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete',
              style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}