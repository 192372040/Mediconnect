
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'PrescriptionShareHelper.dart';

class PrescriptionViewScreen extends StatelessWidget {

  final Map<String, dynamic> report;

  const PrescriptionViewScreen({
    super.key,
    required this.report,
  });
 Future<void> downloadPrescription() async {

  print("DOWNLOAD STARTED");

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [

          pw.Text("Prescription"),

          pw.SizedBox(height: 20),

          pw.Text("Doctor: ${report["subtitle"] ?? ""}"),
          pw.Text("Patient: ${report["patient_name"] ?? ""}"),

          pw.SizedBox(height: 20),

          pw.Text("Diagnosis"),
          pw.Text(report["diagnosis"] ?? ""),

          pw.SizedBox(height: 20),

          pw.Text("Medicines"),
          pw.Text(report["medicines"] ?? ""),

          pw.SizedBox(height: 20),

          pw.Text("Doctor Notes"),
          pw.Text(report["doctor_notes"] ?? ""),
        ],
      ),
    ),
  );

    final bytes = await pdf.save();
    try {
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (await downloadsDir.exists()) {
        final file = File(
          '${downloadsDir.path}/Prescription_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        await file.writeAsBytes(bytes);
        return;
      }
    } catch (_) {}

    final appDir = await getApplicationDocumentsDirectory();
    final file = File(
      '${appDir.path}/Prescription_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF252525);
    const Color successGreen = Color(0xFF00C48C);
    const Color cardBgColor = Color(0xFF1E1E1E);
    const Color primaryBlue = Color(0xFF1962A9);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0D5E42), size: 18),
                     onPressed: () {
  Navigator.pop(context);
},
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Prescription',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await PrescriptionShareHelper.sharePrescription(report, context: context);
                    },
                    child: Container(

    decoration: BoxDecoration(
      border: Border.all(
        color: primaryBlue.withValues(alpha: 0.6),
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 6,
    ),
    child: Row(
      children: const [
        Icon(
          Icons.share,
          color: Colors.lightBlueAccent,
          size: 14,
        ),
        SizedBox(width: 4),
        Text(
          'Share',
          style: TextStyle(
            color: Colors.lightBlueAccent,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
)
                ],
              ),
            ),
            Divider(color: Colors.grey[800], height: 1),
            
            // Scrollable Content
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Hospital & Doctor Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18261F), // Dark green tint
                        border: Border.all(color: const Color(0xFF1B4E38)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
  report["hospital_name"] ?? "Hospital",
  style: const TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
                          const SizedBox(height: 4),
                         Text(
  report["hospital_address"] ?? "",
  style: TextStyle(
    color: Colors.grey[500],
    fontSize: 12,
  ),
),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Divider(color: Colors.grey[800], height: 1),
                          ),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.blue[700],
                               child: Text(
  (report["subtitle"] ?? "D")
      .toString()
      .substring(0, 1)
      .toUpperCase(),
  style: const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  ),
)
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
  report["subtitle"] ?? "",
  style: const TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  ),
),
                                    const SizedBox(height: 2),
                             Text(
  report["doctor_specialization"] ?? "",
  style: TextStyle(
    color: Colors.grey[400],
    fontSize: 12,
  ),
),
                                    Text(
  'License No: ${report["license_number"] ?? ""}',
  style: TextStyle(
    color: Colors.grey[400],
    fontSize: 12,
  ),
)
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
  'Prescription ID',
  report["id"]?.toString() ?? "",
  valueColor: successGreen,
),
                          const SizedBox(height: 8),
                          _buildInfoRow(
  'Date',
  report["date"] ?? "",
),
                          const SizedBox(height: 8),
                         _buildInfoRow(
  'Patient',
  report["patient_name"] ?? "",
),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Diagnosis Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Diagnosis', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                         Text(
  report["diagnosis"] ?? "",
  style: const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Medicines Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Medicines', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Text(
  report["medicines"] ?? "",
  style: const TextStyle(
    color: Colors.white,
    fontSize: 14,
  ),
),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Doctor Notes Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Doctor notes', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                         Text(
  report["doctor_notes"] ?? "",
  style: TextStyle(
    color: Colors.grey[500],
    fontSize: 14,
    height: 1.4,
  ),
)
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Follow Up Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF172921), // Dark green tint background
                        border: Border.all(color: const Color(0xFF1B4E38)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: successGreen, size: 22),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Follow up scheduled', style: TextStyle(color: successGreen, fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('May 7, 2026 · 30 days from today', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Digital Signature
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                         Text(
  report["subtitle"] ?? "",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 26,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Times New Roman', // Generic serif for signature look
                            ),
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey[800], height: 1),
                          const SizedBox(height: 12),
                          Text('Digitally signed · Apr 7, 2026 · 10:45 AM', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Download Button
                   GestureDetector(
  onTap: () async {

    print("DOWNLOAD BUTTON CLICKED");

    await downloadPrescription();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Prescription downloaded"),
      ),
    );

  },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.download, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Download prescription PDF',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
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

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMedicineItem(String name, String freq, String dur, String inst) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C48C).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Active', style: TextStyle(color: Color(0xFF00C48C), fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildMedDetailColumn('Frequency', freq)),
              Container(width: 1, height: 32, color: Colors.grey[800], margin: const EdgeInsets.symmetric(horizontal: 12)),
              Expanded(child: _buildMedDetailColumn('Duration', dur)),
              Container(width: 1, height: 32, color: Colors.grey[800], margin: const EdgeInsets.symmetric(horizontal: 12)),
              Expanded(flex: 2, child: _buildMedDetailColumn('Instructions', inst)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMedDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.2)),
      ],
    );
  }
}
