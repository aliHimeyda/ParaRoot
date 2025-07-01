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
              surfaceTintColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
                    buildFilterTabs(),
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
                itemCount: context.watch<Veriprovider>().veri.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Hareketler",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  } else if (index ==
                      context.watch<Veriprovider>().veri.length + 1) {
                    return SizedBox(height: 150);
                  } else {
                    final HareketModel hareket = HareketModel(
                      id: context.watch<Veriprovider>().veri[index - 1]!['ID'],
                      tarih:
                          context
                              .watch<Veriprovider>()
                              .veri[index - 1]!['tarih']
                              .toDate(),
                      gidermi:
                          context.watch<Veriprovider>().veri[index -
                              1]!['gidermi'],
                      baslik:
                          context.watch<Veriprovider>().veri[index -
                              1]!['baslik'],
                      gelirTarihi:
                          context
                              .watch<Veriprovider>()
                              .veri[index - 1]!['tarih']
                              .toDate()
                              .toString(),
                      gelirTuru:
                          context.watch<Veriprovider>().veri[index -
                              1]!['gelirturu'],
                      deger:
                          context.watch<Veriprovider>().veri[index -
                              1]!['deger'],
                      aciklama:
                          context.watch<Veriprovider>().veri[index -
                              1]!['aciklama'],
                      imageAssetPath:
                          context.watch<Veriprovider>().veri[index -
                              1]!['imageUrl'],
                    );
                    late bool aynitarihmi = false;
                    if ((index - 2) >= 0) {
                      if (DateFormat('d').format(
                            context
                                .watch<Veriprovider>()
                                .veri[index - 1]!['tarih']
                                .toDate(),
                          ) ==
                          DateFormat('d').format(
                            context
                                .watch<Veriprovider>()
                                .veri[index - 2]!['tarih']
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
                          ).veri[index - 1],
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
            width: 150,
            height: 150,
            child: Image.asset(
              'assets/Swap.png',
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

    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ...List.generate(labels.length, (index) {
            final bool isSelected = selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () async {
                  final now = DateTime.now();

                  if (index == 0) {
                    // Bu ay

                    Provider.of<Veriprovider>(
                      context,
                      listen: false,
                    ).baslangictarih = DateTime(now.year, now.month, 1);

                    Provider.of<Veriprovider>(
                      context,
                      listen: false,
                    ).bitistarih = DateTime(now.year, now.month + 1, 1);
                  } else if (index == 1) {
                    // Geçen ay

                    Provider.of<Veriprovider>(
                      context,
                      listen: false,
                    ).baslangictarih = DateTime(now.year, now.month - 1, 1);

                    Provider.of<Veriprovider>(
                      context,
                      listen: false,
                    ).bitistarih = DateTime(now.year, now.month, 1);
                  } else {
                    // Son 3 ay

                    Provider.of<Veriprovider>(
                      context,
                      listen: false,
                    ).baslangictarih = DateTime(now.year, now.month - 2, 1);

                    Provider.of<Veriprovider>(
                      context,
                      listen: false,
                    ).bitistarih = DateTime(now.year, now.month + 1, 1);
                  }
                  await Provider.of<Veriprovider>(
                    context,
                    listen: false,
                  ).gettumveries();
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft:
                          index == 0 ? const Radius.circular(12) : Radius.zero,
                      bottomLeft:
                          index == 0 ? const Radius.circular(12) : Radius.zero,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      color:
                          isSelected
                              ? !Provider.of<AppTheme>(
                                    context,
                                    listen: false,
                                  ).isdarkmode
                                  ? Colors.white
                                  : Colors.black
                              : Theme.of(context).textTheme.bodyLarge!.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),

          ...List.generate(labels.length - 1, (index) {
            return Positioned(
              left: (index + 1) * (MediaQuery.of(context).size.width - 40) / 4,
              top: 8,
              bottom: 8,
              child: Container(width: 1, color: Theme.of(context).primaryColor),
            );
          }),

          Container(
            width: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                popupMenuTheme: PopupMenuThemeData(
                  color:
                      Theme.of(
                        context,
                      ).scaffoldBackgroundColor, // Menü arka planı
                ),
              ),
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).primaryColor,
                ),
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        value: 'sil',
                        child: Row(
                          spacing: 5,
                          children: [
                            Icon(
                              Icons.delete_forever,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text(
                              'Tüm kayıtları sil',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        value: 'paylas',
                        child: Row(
                          spacing: 5,
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text(
                              'Verileri Yazdir',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        value: 'analiz',
                        child: Row(
                          spacing: 5,
                          children: [
                            Icon(
                              Icons.analytics,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text(
                              'Analiz olustur',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                onSelected: (value) async {
                  if (value == 'sil') {
                    showDialog(
                      context: context,
                      builder:
                          (context) => Dialog(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Center(
                                    child: Text(
                                      '${DateFormat('dd/mm/yyyy').format(baslangictarih)}-${DateFormat('dd/mm/yyyy').format(bitistarih)} arasi kayitlar silinecektir ,\nonayliyor musunuz?',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Iptal',

                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                        ),
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
                                        child: Text(
                                          'Devam',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                    );
                  } else if (value == 'paylas') {
                    await pdfolustur();
                  } else if (value == 'analiz') {
                    context.push(Paths.analizsayfasi);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pdfolustur() async {
    final pdfBytes = await Pdfislemleri.generateFaturaPdf(usermoneydata);

    // Önizleme (printing)
    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }
}
