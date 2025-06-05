import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/firebaseServices.dart';
import 'package:hackathon/loader.dart';
import 'package:hackathon/router.dart';
import 'package:provider/provider.dart';

class Analizsayfasi extends StatefulWidget {
  final DateTime baslangictarih;
  final DateTime bitistarih;
  const Analizsayfasi({
    super.key,
    required this.baslangictarih,
    required this.bitistarih,
  });

  @override
  State<Analizsayfasi> createState() => _AnalizsayfasiState();
}

class _AnalizsayfasiState extends State<Analizsayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder(
        future: getUsermoneyData(widget.baslangictarih, widget.bitistarih),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Provider.of<Loader>(context, listen: false).loader(context);
          }
          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return icerikbossa(context);
          }
          final List<Map<String, dynamic>?> gelenveriler = snapshot.data!;
          late double kiralar = 0;
          late double faturalar = 0;
          late double yemek = 0;
          late double kiyafet = 0;
          late double digergider = 0;
          late double maas = 0;
          late double burs = 0;
          late double yangelir = 0;
          late double digergelir = 0;
          late double toplamgelir = 0;
          late double toplamgider = 0;
          if (gelenveriler.isNotEmpty) {
            for (Map<String, dynamic>? veri in gelenveriler) {
              if (veri!['gidermi']) {
                if (veri['gelirturu'] == 'kiralar') {
                  kiralar++;
                  toplamgider += veri['deger'];
                } else if (veri['gelirturu'] == 'faturalar') {
                  toplamgider += veri['deger'];
                  faturalar++;
                } else if (veri['gelirturu'] == 'yemek') {
                  toplamgider += veri['deger'];
                  yemek++;
                } else if (veri['gelirturu'] == 'kiyafet') {
                  toplamgider += veri['deger'];
                  kiyafet++;
                } else {
                  toplamgider += veri['deger'];
                  digergider++;
                }
              } else {
                if (veri['gelirturu'] == 'maas') {
                  toplamgelir += veri['deger'];
                  maas++;
                } else if (veri['gelirturu'] == 'burs') {
                  toplamgelir += veri['deger'];
                  burs++;
                } else if (veri['gelirturu'] == 'yangelir') {
                  toplamgelir += veri['deger'];
                  yangelir++;
                } else {
                  toplamgelir += veri['deger'];
                  digergelir++;
                }
              }
            }
          }
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: ListView(
              children: [
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 50,
                    child:
                        buildCard(
                              children: [
                                buildRow(
                                  'Gelir Dagilim Grafigi',
                                  '',
                                  bold: true,
                                ),
                                Divider(color: Theme.of(context).primaryColor),
                                gelirbuildPieChart(
                                  maas,
                                  burs,
                                  yangelir,
                                  digergelir,
                                ),
                                SizedBox(height: 5),
                                Divider(color: Theme.of(context).primaryColor),
                                buildRow('Genel Bakis:', ''),
                                buildRow(
                                  'Toplam Gelir:',
                                  '$toplamgelir',
                                  bold: true,
                                  color: Theme.of(context).primaryColor,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Gelirinizin artis ivmesini arttirmak icin , Yan Gelir"den gelen orani arttirmanizi oneririz',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            )
                            .animate()
                            .fade()
                            .blur(begin: Offset(10, 10), end: Offset(0, 0))
                            .moveX(),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 50,
                    child:
                        buildCard(
                              children: [
                                buildRow(
                                  'Gider Dagilim Grafigi',
                                  '',
                                  bold: true,
                                ),
                                Divider(color: Theme.of(context).primaryColor),
                                giderbuildPieChart(
                                  kiralar,
                                  faturalar,
                                  yemek,
                                  kiyafet,
                                  digergider,
                                ),
                                SizedBox(height: 5),
                                Divider(color: Theme.of(context).primaryColor),
                                buildRow('Genel Bakis:', ''),
                                buildRow(
                                  'Toplam Gider:',
                                  '$toplamgider',
                                  bold: true,
                                  color: Theme.of(context).primaryColor,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Giderinizdeki artis ivmesini azaltmak icin , Diger"den gelen orani azaltmanizi oneririz',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            )
                            .animate(delay: Duration(milliseconds: 300))
                            .fade()
                            .blur(begin: Offset(10, 10), end: Offset(0, 0))
                            .moveX(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                bold
                    ? TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    )
                    : null,
          ),
          Text(value, style: TextStyle(color: valueColor ?? color)),
        ],
      ),
    );
  }

  Widget giderbuildPieChart(
    double kiralar,
    double faturalar,
    double yemek,
    double kiyafet,
    double diger,
  ) {
    double toplam = kiralar + faturalar + yemek + kiyafet + diger;
    double yuzdelikbirimi = 100 / toplam;
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 0,
              sections: [
                PieChartSectionData(
                  value: kiralar,
                  color: Color(0xFFF2DFBA), // açık bej
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: faturalar,
                  color: Color(0xFFDAA9E1), // açık mor
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: yemek,
                  color: Color(0xFFFF6F4F), // turuncu
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: kiyafet,
                  color: Color(0xFF9F2C55), // koyu kırmızı
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: diger,
                  color: Color(0xFF89A888), // yeşil
                  showTitle: false,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 5),
        Wrap(
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          spacing: 15,
          runSpacing: 8,
          children: [
            SizedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Container(width: 10, height: 10, color: Color(0xFFF2DFBA)),
                  Column(
                    children: [
                      Text(
                        'kiralar',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${(yuzdelikbirimi * kiralar).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Container(width: 10, height: 10, color: Color(0xFFDAA9E1)),
                  Column(
                    children: [
                      Text(
                        'faturalar',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${(yuzdelikbirimi * faturalar).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Container(width: 10, height: 10, color: Color(0xFFFF6F4F)),
                  Column(
                    children: [
                      Text(
                        'yemek',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${(yuzdelikbirimi * yemek).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Container(width: 10, height: 10, color: Color(0xFF9F2C55)),
                  Column(
                    children: [
                      Text(
                        'kiyafet',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${(yuzdelikbirimi * kiyafet).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Container(width: 10, height: 10, color: Color(0xFF89A888)),
                  Column(
                    children: [
                      Text(
                        'diger',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${(yuzdelikbirimi * diger).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget gelirbuildPieChart(
    double maas,
    double burs,
    double yangelir,
    double diger,
  ) {
    double toplam = maas + burs + yangelir + diger;
    double yuzdelikbirimi = 100 / toplam;
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 0,
              sections: [
                PieChartSectionData(
                  value: maas,
                  color: Color(0xFFF2DFBA),
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: burs,
                  color: Color(0xFFDAA9E1),
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: yangelir,
                  color: Color(0xFFFF6F4F),
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: diger,
                  color: Color(0xFF89A888),
                  showTitle: false,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 5),
        Wrap(
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          spacing: 15,
          runSpacing: 8,
          children: [
            SizedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Container(width: 10, height: 10, color: Color(0xFFF2DFBA)),
                  Column(
                    children: [
                      Text(
                        'maas',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${(yuzdelikbirimi * maas).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Container(width: 10, height: 10, color: Color(0xFFDAA9E1)),
                  Column(
                    children: [
                      Text(
                        'burs',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${(yuzdelikbirimi * burs).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Container(width: 10, height: 10, color: Color(0xFFFF6F4F)),
                  Column(
                    children: [
                      Text(
                        'yan gelir',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${(yuzdelikbirimi * yangelir).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Container(width: 10, height: 10, color: Color(0xFF89A888)),
                  Column(
                    children: [
                      Text(
                        'diger',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${(yuzdelikbirimi * diger).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCard({required List<Widget> children}) {
    return Card(
      color: Theme.of(context).secondaryHeaderColor,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
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
            "Secilen tarihler arasinda kayıtlı bir gelir veya gider bulunmuyor.\nGelir/gider analizlerini takip etmek için bilgi ekleyin.",
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
}
