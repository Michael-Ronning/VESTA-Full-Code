import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  static Future<void> emailPdf(
    BuildContext context,
    VestaAssessmentResult result,
  ) async {
    final bytes = await _captureFullContent(context, result);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pdfContext) => [
          pw.Center(
            child: pw.Image(pw.MemoryImage(bytes)),
          ),
        ],
      ),
    );

    final outputDir = await getTemporaryDirectory();

    final file = File(
      '${outputDir.path}/vesta_results_${result.patientName.replaceAll(' ', '_')}.pdf',
    );

    await file.writeAsBytes(await pdf.save());

    final email = Email(
      body:
          'Hello ${result.patientName},\n\nAttached is your VESTA assessment results report.\n\nThank you.',
      subject: 'Your VESTA Assessment Results',
      recipients: [
        result.patientEmail, // make sure this field exists in your model
      ],
      attachmentPaths: [
        file.path,
      ],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }
}
