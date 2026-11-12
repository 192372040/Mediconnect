import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PrescriptionShareHelper {
  static Future<void> sharePrescription(
    Map<String, dynamic> report, {
    BuildContext? context,
  }) async {
    Rect? sharePositionOrigin;
    if (context != null && context.mounted) {
      try {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;
        }
      } catch (_) {}
    }

    try {
      final pdf = pw.Document();
      final docName = (report["subtitle"] ?? report["doctor_name"] ?? "Doctor").toString();
      final patName = (report["patient_name"] ?? "Patient").toString();
      final diag = (report["diagnosis"] ?? report["title"] ?? "General Consultation").toString();
      final meds = (report["medicines"] != null && report["medicines"].toString().trim().isNotEmpty)
          ? report["medicines"].toString()
          : "As prescribed by doctor";
      final notes = (report["doctor_notes"] ?? "").toString();
      final date = (report["date"] ?? "").toString();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pwContext) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "MEDICONNECT CLINIC",
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        "Digital Prescription",
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    date.isNotEmpty
                        ? date
                        : "Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Doctor: $docName",
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Hospital / Clinic: MediConnect Healthcare",
                        style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "Patient: $patName",
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Diagnosis",
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(diag, style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                "Rx - Prescribed Medicines",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green900,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  meds,
                  style: const pw.TextStyle(fontSize: 12, lineSpacing: 2),
                ),
              ),
              if (notes.isNotEmpty && notes != "N/A") ...[
                pw.SizedBox(height: 16),
                pw.Text(
                  "Doctor Notes & Instructions",
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.orange900,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.orange50,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Text(notes, style: const pw.TextStyle(fontSize: 11)),
                ),
              ],
              pw.Spacer(),
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "This is a verified digital prescription from MediConnect.",
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    "Signature: $docName",
                    style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      final bytes = await pdf.save();
      final tempDir = await getTemporaryDirectory();
      final fileName = "Prescription_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf', name: fileName)],
        text: 'Prescription from $docName for $patName',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      debugPrint("Error generating PDF for sharing: $e");
      final docName = (report["subtitle"] ?? report["doctor_name"] ?? "Doctor").toString();
      final patName = (report["patient_name"] ?? "Patient").toString();
      final diag = (report["diagnosis"] ?? report["title"] ?? "Prescription").toString();
      final meds = (report["medicines"] != null && report["medicines"].toString().trim().isNotEmpty)
          ? report["medicines"].toString()
          : "As prescribed by doctor";
      final notes = (report["doctor_notes"] ?? "").toString();
      await Share.share(
        '📋 Medical Prescription\n'
        'Doctor: $docName\n'
        'Patient: $patName\n'
        'Diagnosis: $diag\n\n'
        'Medicines:\n$meds\n\n'
        '${notes.isNotEmpty ? "Doctor Notes: $notes\n\n" : ""}'
        'MediConnect Healthcare',
        subject: 'Prescription from $docName',
        sharePositionOrigin: sharePositionOrigin,
      );
    }
  }
}
