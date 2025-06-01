import 'package:intl/intl.dart';

class HareketModel {
  final DateTime tarih;
  final bool gidermi;
  final String baslik;
  final String gelirTuru;
  final String gelirTarihi;
  final int deger;
  final String aciklama;
  final String imageAssetPath;

  HareketModel({
    required this.tarih,
    required this.gidermi,
    required this.baslik,
    required this.gelirTuru,
    required this.gelirTarihi,
    required this.deger,
    required this.aciklama,
    required this.imageAssetPath,
  });
}
