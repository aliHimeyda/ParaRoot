import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/hareketmodel.dart';
import 'package:hackathon/router.dart';
import 'package:hackathon/themeprovider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Bilgisatiri extends StatelessWidget {
  final VoidCallback silmek;
  final HareketModel hareket;
  final bool aynitarihmi;
  const Bilgisatiri({
    super.key,
    required this.silmek,
    required this.hareket,
    required this.aynitarihmi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.watch<AppTheme>().isdarkmode
            ? Theme.of(context).scaffoldBackgroundColor
            : Theme.of(context).secondaryHeaderColor,
        border: aynitarihmi
            ? Border.symmetric(
                vertical: BorderSide(
                  width: 0.4,
                  color: Theme.of(context).primaryColor,
                ),
              )
            : Border.all(width: 0.4, color: Theme.of(context).primaryColor),
      ),
      child: Column(
        children: [
          _islemSatiri(hareket: hareket, context: context),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _islemSatiri({
    required HareketModel hareket,
    required BuildContext context,
  }) {
    String tutar = hareket.gidermi
        ? '-${hareket.deger}TL'
        : '+${hareket.deger}TL';
    String gun = DateFormat('d').format(hareket.tarih);
    String ay = DateFormat('MMM', 'tr_TR').format(hareket.tarih).toUpperCase();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tarih
        SizedBox(
          width: 50,
          child: !aynitarihmi
              ? Column(
                  children: [
                    Text(gun, style: Theme.of(context).textTheme.titleLarge),
                    Text(ay, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                )
              : const SizedBox(),
        ),
        const SizedBox(width: 8),

        // İçerik
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hareket.baslik,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                hareket.gelirTuru,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        // Tutar ve ikon
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              tutar,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: hareket.gidermi ? Colors.red : Colors.lightGreen,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              spacing: 4,
              children: [
                GestureDetector(
                  onTap: () {
                    context.push(Paths.hareketdetaysayfasi, extra: hareket);
                  },
                  child: Icon(
                    Icons.notes,
                    size: 20,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                GestureDetector(
                  onTap: silmek,
                  child: Icon(Icons.delete, size: 20, color: AppColors.kirmizi),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
