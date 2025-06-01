import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hackathon/hareketmodel.dart';

class HareketDetaySayfasi extends StatelessWidget {
  final HareketModel detaynesnesi;
  const HareketDetaySayfasi({super.key, required this.detaynesnesi});

  @override
  Widget build(BuildContext context) {
    final List<HareketModel> hareketler = [
      HareketModel(
        tarih: DateTime(12, 3, 2025),
        gidermi: false,
        baslik: detaynesnesi.baslik,
        gelirTuru: detaynesnesi.gelirTuru,
        gelirTarihi: detaynesnesi.gelirTarihi,
        deger: detaynesnesi.deger,
        aciklama: detaynesnesi.aciklama,
        imageAssetPath: detaynesnesi.imageAssetPath,
      ),
      // İstersen buraya başka hareketler de ekleyebilirsin
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text('Hareket Detayı'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: hareketler.length,
        itemBuilder: (context, index) {
          return HareketDetayCard(model: hareketler[index]);
        },
      ),
    );
  }
}

class HareketDetayCard extends StatelessWidget {
  final HareketModel model;

  const HareketDetayCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gelir Türü
        _customField(context, "Gelir Türü", model.gelirTuru),
        const SizedBox(height: 12),

        // Gelir Tarihi
        _customField(context, "Gelir Tarihi", model.gelirTarihi),
        const SizedBox(height: 12),

        // Gelir Değeri
        _customField(context, "Gelir Değeri (TL)", model.deger.toString()),
        const SizedBox(height: 16),

        // Görsel (Maaş Bordrosu)
        model.imageAssetPath != ''
            ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(model.imageAssetPath, fit: BoxFit.cover),
            )
            : SizedBox(),
        const SizedBox(height: 20),

        // Açıklama
        model.aciklama != ''
            ? Column(
              children: [
                _customField(
                  context,
                  "Aciklama",
                  'ldksjfklsdjfkljsdlkfjskldjflksjdklfjdskljfkldsjfkljdsklfjklsdjfklsjdlfjsdklfjklsdfkljs',
                ),
                const SizedBox(height: 12),
              ],
            )
            : SizedBox(),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _customField(context, String label, String value) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width - 50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Wrap(
          children: [
            Text(
              "$label: ",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
