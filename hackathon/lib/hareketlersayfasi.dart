import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/bilgisatiri.dart';
import 'package:hackathon/colors.dart';
import 'package:hackathon/firebaseServices.dart';
import 'package:hackathon/hareketmodel.dart';
import 'package:hackathon/loader.dart';
import 'package:hackathon/router.dart';
import 'package:hackathon/themeprovider.dart';
import 'package:provider/provider.dart';

class Hareketlersayfasi extends StatefulWidget {
  const Hareketlersayfasi({super.key});

  @override
  State<Hareketlersayfasi> createState() => _HareketlersayfasiState();
}

class _HareketlersayfasiState extends State<Hareketlersayfasi> {
  final now = DateTime.now();
  late DateTime baslangictarih = DateTime(now.year, now.month, 1);
  late DateTime bitistarih = DateTime(now.year, now.month + 1, 1);
  late int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        FutureBuilder<int>(
                          future: getUsermoneytoplami(
                            baslangictarih,
                            bitistarih,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            if (!snapshot.hasData || snapshot.data == null) {
                              return Text("hata");
                            }
                            return Text(
                              '${snapshot.data!.toString()} TL',
                              style: Theme.of(context).textTheme.bodyLarge,
                            );
                          },
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
                        FutureBuilder<int>(
                          future: getUserborctoplami(
                            baslangictarih,
                            bitistarih,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            if (!snapshot.hasData || snapshot.data == null) {
                              return Text("hata");
                            }
                            return Text(
                              '${snapshot.data!.toString()} TL',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            );
                          },
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
      body: FutureBuilder<List<Map<String, dynamic>?>>(
        future: getUsermoneyData(baslangictarih, bitistarih),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Provider.of<Loader>(context, listen: false).loader(context);
          }
          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return icerikbossa(context);
          }

          final userinhareketdatasi = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: userinhareketdatasi.length + 2,
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
              } else if (index == userinhareketdatasi.length + 1) {
                return SizedBox(height: 150);
              } else {
                final HareketModel hareket = HareketModel(
                  tarih: userinhareketdatasi[index - 1]!['tarih'].toDate(),
                  gidermi: userinhareketdatasi[index - 1]!['gidermi'],
                  baslik: userinhareketdatasi[index - 1]!['baslik'],
                  gelirTarihi:
                      userinhareketdatasi[index - 1]!['tarih']
                          .toDate()
                          .toString(),
                  gelirTuru: userinhareketdatasi[index - 1]!['gelirturu'],
                  deger: userinhareketdatasi[index - 1]!['deger'],
                  aciklama: userinhareketdatasi[index - 1]!['aciklama'],
                  imageAssetPath: userinhareketdatasi[index - 1]!['imageUrl'],
                );
                late bool aynitarihmi = true;
                if ((index - 2) >= 0) {
                  if (userinhareketdatasi[index - 1]!['tarih'].toDate() ==
                      userinhareketdatasi[index - 2]!['tarih'].toDate()) {
                    aynitarihmi = false;
                  }
                }
                return Bilgisatiri(hareket: hareket, aynitarihmi: aynitarihmi);
              }
            },
          );
        },
      ),
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
                onTap: () {
                  setState(() {
                    final now = DateTime.now();

                    if (index == 0) {
                      // Bu ay
                      baslangictarih = DateTime(now.year, now.month, 1);
                      bitistarih = DateTime(now.year, now.month + 1, 1);
                    } else if (index == 1) {
                      // Geçen ay
                      baslangictarih = DateTime(now.year, now.month - 1, 1);
                      bitistarih = DateTime(now.year, now.month, 1);
                    } else {
                      // Son 3 ay
                      baslangictarih = DateTime(now.year, now.month - 2, 1);
                      bitistarih = DateTime(now.year, now.month + 1, 1);
                    }
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
            child: IconButton(
              icon: const Icon(Icons.more_horiz),
              color: Theme.of(context).primaryColor,
              onPressed: () {
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
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.qr_code,
                                  color: Theme.of(context).primaryColor,
                                ),
                                title: Text(
                                  'QR Kodu Okut',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  context.push(Paths.qrsayfasi);
                                },
                              ),
                              Divider(color: Theme.of(context).primaryColor),
                              ListTile(
                                leading: Icon(
                                  Icons.delete_forever,
                                  color: Theme.of(context).primaryColor,
                                ),
                                title: Text(
                                  'Tüm kayıtları sil',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  // ...
                                },
                              ),
                              Divider(color: Theme.of(context).primaryColor),
                              ListTile(
                                leading: Icon(
                                  Icons.share,
                                  color: Theme.of(context).primaryColor,
                                ),
                                title: Text(
                                  'Verileri paylaş',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  // ...
                                },
                              ),
                              Divider(color: Theme.of(context).primaryColor),
                              ListTile(
                                leading: Icon(
                                  Icons.analytics,
                                  color: Theme.of(context).primaryColor,
                                ),
                                title: Text(
                                  'Analiz olustur',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  context.push(
                                    Paths.analizsayfasi,
                                    extra: {
                                      'baslangictarih': baslangictarih,
                                      'bitistarih': bitistarih,
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
