import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/bilgisatiri.dart';
import 'package:hackathon/firebaseServices.dart';
import 'package:hackathon/hareketmodel.dart';
import 'package:hackathon/loader.dart';
import 'package:hackathon/main.dart';
import 'package:hackathon/pdfislemleri.dart';
import 'package:hackathon/router.dart';
import 'package:hackathon/themeprovider.dart';
import 'package:hackathon/veriprovider.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class Hareketlersayfasi extends StatefulWidget {
  const Hareketlersayfasi({super.key});

  @override
  State<Hareketlersayfasi> createState() => _HareketlersayfasiState();
}

class _HareketlersayfasiState extends State<Hareketlersayfasi> {
  late List<Map<String, dynamic>?> usermoneydata = [];
  final now = DateTime.now();
  late DateTime baslangictarih = DateTime(now.year, now.month, 1);
  late DateTime bitistarih = DateTime(now.year, now.month + 1, 1);
  late int selectedIndex = 0;
  late Future<void> getveries;

  @override
  void initState() {
    super.initState();
    getveries = getVeries();
  }

  Future<void> getVeries() async {
    await Provider.of<Veriprovider>(
      context,
      listen: false,
    ).getusermoneytoplami();
    await Provider.of<Veriprovider>(
      context,
      listen: false,
    ).getuserborctoplami();
    await Provider.of<Veriprovider>(context, listen: false).getusermoneydata();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(140),
            child: AppBar(
              surfaceTintColor: Theme.of(context).secondaryHeaderColor,
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              elevation: 0,
              flexibleSpace: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Gelir',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${context.watch<Veriprovider>().gelirtoplami.toString()} TL',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Theme.of(context).primaryColor,
                        ),
                        Column(
                          children: [
                            Text(
                              'Gider',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${context.watch<Veriprovider>().borctoplami.toString()} TL',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.2,
                            ), // Yarı saydam siyah
                            offset: Offset(4, 4), // X: sağa, Y: aşağı
                            blurRadius: 5, // Yumuşaklık
                            spreadRadius: 2, // Genişleme
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 8),
                        child: buildFilterTabs(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: FutureBuilder<void>(
            future: getveries,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Provider.of<Loader>(
                  context,
                  listen: false,
                ).loader(context);
              }
              if (!context.watch<Veriprovider>().veri.isNotEmpty ||
                  context.watch<Veriprovider>().veri == [] ||
                  context.watch<Veriprovider>().veri.isEmpty) {
                return icerikbossa(context);
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: context.watch<Veriprovider>().veri.length + 1,
                itemBuilder: (context, index) {
                  if (index == context.watch<Veriprovider>().veri.length) {
                    return Container(
                      height: 155,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            width: 0.4,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    );
                  } else {
                    final HareketModel hareket = HareketModel(
                      id: context.watch<Veriprovider>().veri[index]!['ID'],
                      tarih: context
                          .watch<Veriprovider>()
                          .veri[index]!['tarih']
                          .toDate(),
                      gidermi: context
                          .watch<Veriprovider>()
                          .veri[index]!['gidermi'],
                      baslik: context
                          .watch<Veriprovider>()
                          .veri[index]!['baslik'],
                      gelirTarihi: context
                          .watch<Veriprovider>()
                          .veri[index]!['tarih']
                          .toDate()
                          .toString(),
                      gelirTuru: context
                          .watch<Veriprovider>()
                          .veri[index]!['gelirturu'],
                      deger: context
                          .watch<Veriprovider>()
                          .veri[index]!['deger'],
                      aciklama: context
                          .watch<Veriprovider>()
                          .veri[index]!['aciklama'],
                      imageAssetPath: context
                          .watch<Veriprovider>()
                          .veri[index]!['imageUrl'],
                    );
                    late bool aynitarihmi = false;
                    if ((index - 1) >= 0) {
                      if (DateFormat('d').format(
                            context
                                .watch<Veriprovider>()
                                .veri[index]!['tarih']
                                .toDate(),
                          ) ==
                          DateFormat('d').format(
                            context
                                .watch<Veriprovider>()
                                .veri[index - 1]!['tarih']
                                .toDate(),
                          )) {
                        aynitarihmi = true;
                      }
                    }
                    return Bilgisatiri(
                      hareket: hareket,
                      aynitarihmi: aynitarihmi,
                      silmek: () async {
                        getIt<Loader>().loading = true;
                        getIt<Loader>().change();
                        await kayitsil(hareket);
                        await Provider.of<Veriprovider>(
                          context,
                          listen: false,
                        ).deletedata(
                          Provider.of<Veriprovider>(
                            context,
                            listen: false,
                          ).veri[index],
                        );
                        getIt<Loader>().loading = false;
                        getIt<Loader>().change();
                      },
                    );
                  }
                },
              );
            },
          ),
        ),
        context.watch<Loader>().loading
            ? Provider.of<Loader>(context, listen: false).loader(context)
            : SizedBox(),
      ],
    );
  }

  Center icerikbossa(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            width: 100,
            height: 100,
            child: Image.asset(
              'assets/loading.png',
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Kayıtlı gelir/gider bilgisi bulunamadı.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Text(
            "Şu anda kayıtlı bir gelir veya gider bulunmuyor.\nGelir/gider durumunu takip etmek için bilgi ekleyin.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 220,
            child: ElevatedButton(
              onPressed: () async {
                context.push(Paths.gelirgidereklesayfasi);
              },
              style: Theme.of(context).elevatedButtonTheme.style,
              child: Text(
                "Gelir / Gider Ekle",
                style: Theme.of(
                  context,
                ).elevatedButtonTheme.style?.textStyle?.resolve({}),
              ),
            ),
          ),
          const SizedBox(height: 155),
        ],
      ),
    );
  }

  // Stateful widget içinde tanımlanmalı

  Widget buildFilterTabs() {
    final List<String> labels = ['Bu Ay', 'Geçen Ay', 'Son 3 Ay'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Hareketler", style: Theme.of(context).textTheme.titleLarge),
        // Sol filtre butonu
        Row(
          children: [
            PopupMenuButton<int>(
              onSelected: (index) async {
                final now = DateTime.now();

                if (index == 0) {
                  Provider.of<Veriprovider>(context, listen: false)
                    ..baslangictarih = DateTime(now.year, now.month, 1)
                    ..bitistarih = DateTime(now.year, now.month + 1, 1);
                } else if (index == 1) {
                  Provider.of<Veriprovider>(context, listen: false)
                    ..baslangictarih = DateTime(now.year, now.month - 1, 1)
                    ..bitistarih = DateTime(now.year, now.month, 1);
                } else if (index == 2) {
                  Provider.of<Veriprovider>(context, listen: false)
                    ..baslangictarih = DateTime(now.year, now.month - 2, 1)
                    ..bitistarih = DateTime(now.year, now.month + 1, 1);
                }

                await Provider.of<Veriprovider>(
                  context,
                  listen: false,
                ).gettumveries();
                setState(() {
                  selectedIndex = index;
                });
              },

              itemBuilder: (context) => List.generate(
                labels.length,
                (index) =>
                    PopupMenuItem(value: index, child: Text(labels[index])),
              ),
              child: Row(
                children: [
                  Text(
                    labels[selectedIndex],
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).primaryColor,
                    size: 30,
                  ),
                ],
              ),
            ),

            // Sağda üç nokta menüsü
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).primaryColor,
              ),
              onSelected: (value) async {
                if (value == 'sil') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Uyarı'),
                      content: Text(
                        '${DateFormat('dd/MM/yyyy').format(baslangictarih)} - ${DateFormat('dd/MM/yyyy').format(bitistarih)} arası kayıtlar silinecek. Onaylıyor musunuz?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await Provider.of<Veriprovider>(
                              context,
                              listen: false,
                            ).deletealldata();
                            Navigator.pop(context);
                            setState(() {});
                          },
                          child: const Text('Devam'),
                        ),
                      ],
                    ),
                  );
                } else if (value == 'paylas') {
                  await pdfolustur();
                } else if (value == 'analiz') {
                  context.push(Paths.analizsayfasi);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'sil',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_forever,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text('Tüm kayıtları sil'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'paylas',
                  child: Row(
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text('Verileri yazdır'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'analiz',
                  child: Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text('Analiz oluştur'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> pdfolustur() async {
    final pdfBytes = await Pdfislemleri.generateFaturaPdf(usermoneydata);

    // Önizleme (printing)
    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }
}
