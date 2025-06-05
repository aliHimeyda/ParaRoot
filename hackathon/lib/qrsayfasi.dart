import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Qrsayfasi extends StatefulWidget {
  const Qrsayfasi({super.key});

  @override
  _QrsayfasiPageState createState() => _QrsayfasiPageState();
}

class _QrsayfasiPageState extends State<Qrsayfasi> {
  bool _isScanned = false;

  void _handleScan(String rawData) {
    if (_isScanned) return;
    _isScanned = true;

    final parsed = _parseQrData(rawData);

    if (parsed != null) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text("Harcamayı ekle"),
              content: Text(
                "Tutar: ${parsed['amount']} TL\nTarih: ${parsed['date']}\nFirma: ${parsed['title']}",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Burada harcamayı veritabanına eklersin
                  },
                  child: Text("Ekle"),
                ),
              ],
            ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Geçerli veri bulunamadı")));
    }
  }

  Map<String, dynamic>? _parseQrData(String text) {
    try {
      final parts = text.split('|');
      final values = <String, String>{};
      for (final part in parts) {
        final kv = part.split(':');
        if (kv.length == 2) values[kv[0].trim()] = kv[1].trim();
      }

      final amount = double.tryParse(values['TUTAR'] ?? '');
      final title = values['UNVAN'] ?? 'Bilinmeyen';
      final dateStr = values['TARIH'] ?? '';
      final date =
          dateStr.isNotEmpty
              ? DateTime.tryParse(dateStr.split('.').reversed.join('-'))
              : DateTime.now();

      if (amount != null) {
        return {'amount': amount, 'title': title, 'date': date};
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR Kod Tarayıcı")),
      body: MobileScanner(
        onDetect: (BarcodeCapture capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;
            if (code != null) {
              _handleScan(code);
              break; // İlk bulduğunu al, durdurmak için
            }
          }
        },
      ),
    );
  }
}
