import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_project/patientdashboard/reports/reportdetails.dart';
import 'package:my_project/patientdashboard/reports/visithistry.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';

class MyReportsScreen extends StatefulWidget {
  final Map user;

  const MyReportsScreen({
    super.key,
    required this.user,
  });

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  static const Color primary = Color(0xFF0F6E56);
  static const Color primaryBg = Color(0xFF2C2A2A);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color borderColor = Color(0xFF3A3A3A);

  String _selectedTab = 'All';
  List<dynamic> prescriptions = [];
  final List<Map<String, dynamic>> _uploadedReports = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    loadPrescriptions();
  }

  Future loadPrescriptions() async {
    prescriptions = await ApiService.getPatientPrescriptions(
      widget.user["email"],
    );
    setState(() {});
  }

  // Tabs — removed 'Scans'
  final List<String> _tabs = ['All', 'Prescriptions', 'Lab reports'];

  // Static sample lab reports (no Scans)
  final List<Map<String, dynamic>> _labReports = [
    {
      'title': 'Blood test report',
      'subtitle': 'Apollo Diagnostics',
      'date': 'Mar 18, 2026',
      'type': 'PDF',
      'size': '256 KB',
      'badge': 'Lab',
      'category': 'Lab reports',
      'iconColor': const Color(0xFF1D9E75),
      'iconBg': const Color(0xFF1A2A22),
      'badgeColor': const Color(0xFF1D9E75),
      'badgeBg': const Color(0xFF1A2A22),
    },
    {
      'title': 'Urine test report',
      'subtitle': 'SRL Diagnostics',
      'date': 'Mar 10, 2026',
      'type': 'PDF',
      'size': '180 KB',
      'badge': 'Lab',
      'category': 'Lab reports',
      'iconColor': const Color(0xFF1D9E75),
      'iconBg': const Color(0xFF1A2A22),
      'badgeColor': const Color(0xFF1D9E75),
      'badgeBg': const Color(0xFF1A2A22),
    },
  ];

  List<Map<String, dynamic>> get _prescriptionItems {
    if (prescriptions.isNotEmpty) {
      return prescriptions.map<Map<String, dynamic>>((p) {
        return {
          'title': p['diagnosis'] ?? 'Prescription',
          'subtitle': p['doctor_name'] ?? '',
          'date': 'Today',
          'type': 'RX',
          'size': '',
          'badge': 'Rx',
          'category': 'Prescriptions',
          'iconColor': const Color(0xFF185FA5),
          'iconBg': const Color(0xFF1A2A3A),
          'badgeColor': const Color(0xFF378ADD),
          'badgeBg': const Color(0xFF1A2A3A),
          'diagnosis': p['diagnosis'],
          'medicines': p['medicines'],
          'doctor_notes': p['doctor_notes'],
          'patient_name': p['patient_name'],
          'id': p['id'],
        };
      }).toList();
    }
    // Fallback static prescriptions
    return [
      {
        'title': 'Prescription #1024',
        'subtitle': 'Dr. Rajesh Kumar',
        'date': 'Mar 20, 2026',
        'type': 'PDF',
        'size': '124 KB',
        'badge': 'Rx',
        'category': 'Prescriptions',
        'iconColor': const Color(0xFF185FA5),
        'iconBg': const Color(0xFF1A2A3A),
        'badgeColor': const Color(0xFF378ADD),
        'badgeBg': const Color(0xFF1A2A3A),
      },
      {
        'title': 'Prescription #1018',
        'subtitle': 'Dr. Sneha Patel',
        'date': 'Mar 10, 2026',
        'type': 'PDF',
        'size': '98 KB',
        'badge': 'Rx',
        'category': 'Prescriptions',
        'iconColor': const Color(0xFF185FA5),
        'iconBg': const Color(0xFF1A2A3A),
        'badgeColor': const Color(0xFF378ADD),
        'badgeBg': const Color(0xFF1A2A3A),
      },
    ];
  }

  List<Map<String, dynamic>> get _allItems =>
      [..._prescriptionItems, ..._labReports, ..._uploadedReports];

  List<Map<String, dynamic>> get _filteredReports {
    switch (_selectedTab) {
      case 'Prescriptions':
        return _prescriptionItems;
      case 'Lab reports':
        return [..._labReports, ..._uploadedReports.where((r) => r['category'] == 'Lab reports')];
      case 'All':
      default:
        return _allItems;
    }
  }

  // Summary counts
  int get _totalCount => _allItems.length;
  int get _prescriptionCount => _prescriptionItems.length;
  int get _labReportCount => _labReports.length + _uploadedReports.where((r) => r['category'] == 'Lab reports').length;

  Future<void> _pickAndUploadFile() async {
    try {
      setState(() => _isUploading = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileName = file.name;
        final fileSize = file.size;

        // Format file size
        String sizeLabel;
        if (fileSize < 1024) {
          sizeLabel = '$fileSize B';
        } else if (fileSize < 1024 * 1024) {
          sizeLabel = '${(fileSize / 1024).toStringAsFixed(0)} KB';
        } else {
          sizeLabel = '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
        }

        // Determine file type label
        final ext = fileName.split('.').last.toUpperCase();

        // Add to uploaded reports list
        final newReport = {
          'title': fileName,
          'subtitle': 'Uploaded by you',
          'date': 'Today',
          'type': ext,
          'size': sizeLabel,
          'badge': 'Lab',
          'category': 'Lab reports',
          'iconColor': const Color(0xFF1D9E75),
          'iconBg': const Color(0xFF1A2A22),
          'badgeColor': const Color(0xFF1D9E75),
          'badgeBg': const Color(0xFF1A2A22),
        };

        setState(() {
          _uploadedReports.add(newReport);
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$fileName uploaded successfully!'),
              backgroundColor: primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        setState(() => _isUploading = false);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSummaryCard(),
            _buildTabs(),
            _buildSearchBar(),
            Expanded(
              child: _filteredReports.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: _filteredReports.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) =>
                          _buildReportCard(_filteredReports[i], context),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildUploadFab(),
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
            child: Text('My reports',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const VisitHistoryScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2A22),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1D9E75), width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.history_rounded,
                      color: Color(0xFF1D9E75), size: 14),
                  SizedBox(width: 4),
                  Text('History',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1D9E75),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          _sumItem(_totalCount.toString(), 'Total'),
          _divider(),
          _sumItem(_prescriptionCount.toString(), 'Prescriptions'),
          _divider(),
          _sumItem(_labReportCount.toString(), 'Lab reports'),
        ],
      ),
    );
  }

  Widget _sumItem(String num, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(num,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 9, color: Colors.white70),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 0.5, height: 30, color: Colors.white24);

  Widget _buildTabs() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final sel = _selectedTab == _tabs[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = _tabs[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: sel ? primary : cardBg,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: sel ? primary : borderColor, width: 0.5),
              ),
              child: Text(_tabs[i],
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: const [
          Icon(Icons.search_rounded, color: primary, size: 18),
          SizedBox(width: 8),
          Text('Search reports...',
              style: TextStyle(fontSize: 13, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: cardBg,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: const Icon(Icons.folder_off_rounded,
                color: Colors.white38, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No reports found',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 6),
          const Text('Upload a report using the button below',
              style: TextStyle(fontSize: 13, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ReportDetailScreen(report: report)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: report['iconBg'] as Color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    report['badge'] == 'Rx'
                        ? Icons.description_rounded
                        : Icons.biotech_rounded,
                    color: report['iconColor'] as Color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report['title'] as String,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(report['subtitle'] as String,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white54)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: report['badgeBg'] as Color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(report['badge'] as String,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: report['badgeColor'] as Color)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Color(0xFF3A3A3A), height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 11, color: Colors.white38),
                const SizedBox(width: 4),
                Text(report['date'] as String,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.white54)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2A22),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(report['type'] as String,
                      style: const TextStyle(
                          fontSize: 9, color: Color(0xFF1D9E75))),
                ),
                const Spacer(),
                if ((report['size'] as String).isNotEmpty) ...[
                  Text(report['size'] as String,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white38)),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2A22),
                    borderRadius: BorderRadius.circular(7),
                    border:
                        Border.all(color: const Color(0xFF1D9E75), width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.download_rounded,
                          color: Color(0xFF1D9E75), size: 12),
                      SizedBox(width: 4),
                      Text('Download',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF1D9E75),
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadFab() {
    return GestureDetector(
      onTap: _isUploading ? null : _pickAndUploadFile,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _isUploading ? primary.withValues(alpha: 0.6) : primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isUploading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            else
              const Icon(Icons.upload_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              _isUploading ? 'Uploading...' : 'Upload report',
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
