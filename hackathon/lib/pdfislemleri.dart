import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:hackathon/analizsayfasi.dart';

class Pdfislemleri {


static void createPdfFromData(DateTime tarih,String name, int age) async {
  final pdf = pw.Document();

 pdf.addPage(
  pw.MultiPage(
    build: (pw.Context context) => [
      buildRow(context, 'label', 'value'),
    ],
  ),
);

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

static void savePdfToFile(pw.Document pdf) async {
  final output = await getTemporaryDirectory();
  final file = File("${output.path}/ornek_dosya.pdf");
  await file.writeAsBytes(await pdf.save());
  debugPrint("PDF kaydedildi: ${file.path}");
}

static pw.Widget buildRow(
  context,
    String label,
    String value, {
    bool bold = false,
    PdfColor? color,
    PdfColor? valueColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style:
                bold
                    ? pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: AppColors.mavi,
                    )
                    : null,
          ),
          pw.Text(value, style: pw.TextStyle(color: valueColor ?? color)),
        ],
      ),
    );
  }
}

class AppColors {
  static PdfColor mavi = PdfColor.fromInt(0xFF005C78); // Mavi
  static PdfColor kirmizi = PdfColor.fromInt(0xFFD6453D); // Kırmızı
  static PdfColor yesil = PdfColor.fromInt(0xFFF3F7EC); // Açık yeşilimsi beyaz
  static PdfColor koyuMavi = PdfColor.fromInt(0xFF002B5C); // Koyu mavi
  static PdfColor acikGri = PdfColor.fromInt(0xFFD1D1D1); // Açık gri
  static PdfColor koyuGri = PdfColor.fromInt(0xFF505050); // Koyu gri
  static PdfColor sari = PdfColor.fromInt(0xFFE88D67); // Sarı/turuncumsu
  static PdfColor koyuBeyaz = PdfColor.fromInt(0xFFF2ECEC); // Açık beyaz
  static PdfColor siyah = PdfColor.fromInt(0xFF121212); // Siyah
  static PdfColor bordo = PdfColor.fromInt(0xFF7A1E1E); // Bordo
  static PdfColor krem = PdfColor.fromInt(0xFFF4E1C0); // Krem
}