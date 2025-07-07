import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hackathon/loader.dart';
import 'package:hackathon/main.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Pdfislemleri {
  static Future<Uint8List> generateFaturaPdf(
    List<Map<String, dynamic>?> veriListesi, {
    String faturaNo = "123-456-7890",
  }) async {
    String ayYil = DateFormat('dd/MM/yyyy').format(DateTime.now()).toString();
    final pdf = pw.Document();
    final baseColor = PdfColor.fromHex('#005C78');
    final accentColor = PdfColor.fromHex('#E88D67');

    const rowsPerPage = 30;
    int toplamGelir = 0;
    int toplamGider = 0;

    for (int i = 0; i < veriListesi.length; i += rowsPerPage) {
      final sublist = veriListesi.sublist(
        i,
        (i + rowsPerPage > veriListesi.length)
            ? veriListesi.length
            : i + rowsPerPage,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(32),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Başlık ve bilgi kısmı
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "FATURA",
                            style: pw.TextStyle(
                              fontSize: 28,
                              fontWeight: pw.FontWeight.bold,
                              color: baseColor,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text("fatura no: $faturaNo"),
                          pw.Text("Kaynak: ParaRoot uygulamasi"),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            "Olusturulma Tarihi :",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(ayYil),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 30),

                  // Tablo başlığı
                  pw.Container(
                    color: baseColor,
                    padding: const pw.EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 6,
                    ),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            "NO.",
                            style: pw.TextStyle(color: PdfColors.white),
                          ),
                        ),
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            "ACIKLAMA",
                            style: pw.TextStyle(color: PdfColors.white),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            "TUR",
                            style: pw.TextStyle(color: PdfColors.white),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            "PRICE",
                            style: pw.TextStyle(color: PdfColors.white),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            "GUN",
                            style: pw.TextStyle(color: PdfColors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Veri satırları
                  ...sublist.asMap().entries.map((entry) {
                    final index = i + entry.key + 1;
                    final item = entry.value;
                    final tur = item!['gidermi']?.toString() == "false"
                        ? '+'
                        : '-';
                    final int price = (item['deger'] ?? 0) as int;

                    if (tur == '+') toplamGelir += price;
                    if (tur == '-') toplamGider += price;

                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Row(
                        children: [
                          pw.Expanded(child: pw.Text(index.toString())),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              item['gelirturu'] ?? 'belirtilmemis',
                            ),
                          ),
                          pw.Expanded(child: pw.Text(tur)),
                          pw.Expanded(child: pw.Text("\$${price.toString()}")),
                          pw.Expanded(
                            child: pw.Text(
                              DateFormat('d').format(
                                item['tarih'] is Timestamp
                                    ? (item['tarih'] as Timestamp).toDate()
                                    : item['tarih'],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  pw.Spacer(),

                  if (i + rowsPerPage >=
                      veriListesi.length) // sadece son sayfada toplamlar
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Divider(color: baseColor, thickness: 1),
                        pw.Text(
                          "GELIR   : \$${toplamGelir.toStringAsFixed(2)}",
                        ),
                        pw.Text(
                          "GIDER   : \$${toplamGider.toStringAsFixed(2)}",
                        ),
                        pw.Text(
                          "TOPLAM  : \$${(toplamGelir - toplamGider).toStringAsFixed(2)}",
                        ),
                        pw.SizedBox(height: 20),
                        pw.Center(
                          child: pw.Text(
                            "TESEKKURLER!",
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: baseColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      );
    }
    return pdf.save();
  }
}
