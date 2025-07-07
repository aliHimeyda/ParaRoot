import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hackathon/loader.dart';
import 'package:hackathon/themeprovider.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:xml/xml.dart';

Future<Map<String, dynamic>> fetchLast30DaysRatesWithAltin(
  String apiKey,
) async {
  final List<Map<String, dynamic>> ratesList = [];

  DateTime date = DateTime.now();
  int fetchedDays = 0;
  int maxLookBack = 60;
  int checkedDays = 0;

  while (fetchedDays < 30 && checkedDays < maxLookBack) {
    final formattedDate = DateFormat('ddMMyyyy').format(date);
    final yearMonth = DateFormat('yyyyMM').format(date);
    final url = 'https://www.tcmb.gov.tr/kurlar/$yearMonth/$formattedDate.xml';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final currencies = document.findAllElements('Currency');

        final usdList = currencies
            .where((el) => el.getAttribute('CurrencyCode') == 'USD')
            .toList();

        final eurList = currencies
            .where((el) => el.getAttribute('CurrencyCode') == 'EUR')
            .toList();

        final usd = usdList.isNotEmpty ? usdList.first : null;
        final eur = eurList.isNotEmpty ? eurList.first : null;

        if (usd != null && eur != null) {
          ratesList.add({
            'Tarih': DateFormat('dd.MM.yyyy').format(date),
            'USD Alış': usd.getElement('ForexBuying')?.text ?? 'Yok',
            'USD Satış': usd.getElement('ForexSelling')?.text ?? 'Yok',
            'EUR Alış': eur.getElement('ForexBuying')?.text ?? 'Yok',
            'EUR Satış': eur.getElement('ForexSelling')?.text ?? 'Yok',
          });

          fetchedDays++;
        }
      }
    } catch (_) {
      // geçersiz gün (hafta sonu vs.), atla
    }

    date = date.subtract(Duration(days: 1));
    checkedDays++;
  }

  // Bugünkü altın fiyatı (Finage üzerinden)
  String gramAltin = '';
  try {
    final xauUrl = 'https://api.finage.co.uk/last/forex/XAUUSD?apikey=$apiKey';
    final usdtryUrl =
        'https://api.finage.co.uk/last/forex/USDTRY?apikey=$apiKey';

    final xauResponse = await http.get(Uri.parse(xauUrl));
    final usdtryResponse = await http.get(Uri.parse(usdtryUrl));

    if (xauResponse.statusCode == 200 && usdtryResponse.statusCode == 200) {
      final xauData = json.decode(xauResponse.body);
      final usdtryData = json.decode(usdtryResponse.body);

      final xauUsdAsk = xauData['ask'];
      final usdTry = usdtryData['ask'];

      if (xauUsdAsk != null && usdTry != null) {
        final gram = (xauUsdAsk * usdTry) / 31.1035;
        gramAltin = gram.toStringAsFixed(2);
      } else {
        gramAltin = 'Veri eksik';
      }
    } else {
      gramAltin = 'API hatası';
    }
  } catch (e) {
    gramAltin = 'Hata: ${e.toString()}';
  }

  return {'Altın': gramAltin, 'Kurlar': ratesList};
}

class ChartData {
  ChartData(this.x, this.y);
  final DateTime x;
  final double y;
}

class Doviz extends StatefulWidget {
  const Doviz({super.key});

  @override
  State<Doviz> createState() => _DovizState();
}

class _DovizState extends State<Doviz> {
  late CrosshairBehavior _crosshairBehavior;
  late Future<Map<String, dynamic>?> datagetir;

  @override
  void initState() {
    _crosshairBehavior = CrosshairBehavior(
      enable: true,
      activationMode: ActivationMode.longPress,
      lineType: CrosshairLineType.both,
      lineWidth: 1,
      lineColor: Colors.grey[700],
    );
    super.initState();
    datagetir = fetchLast30DaysRatesWithAltin(
      'API_KEY12OV2ZXBOXON1DICGCBUZQ8I4D7R5CMJ',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).primaryColor,
        title: Text(
          'Doviz Fiyatlari',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge!.color, // Geri ok rengi
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: datagetir,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Provider.of<Loader>(context, listen: false).loader(context);
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return icerikbossa(context);
          }
          final items = snapshot.data!['Kurlar'];
          late List<ChartData> usddata = [];
          late List<ChartData> eurodata = [];

          for (Map<String, dynamic> item in items) {
            final price = ChartData(
              DateFormat('dd.MM.yyyy').parse(item['Tarih']),
              double.parse(item['USD Satış']),
            );
            usddata.add(price);
          }
          for (Map<String, dynamic> item in items) {
            final price = ChartData(
              DateFormat('dd.MM.yyyy').parse(item['Tarih']),
              double.parse(item['EUR Satış']),
            );
            eurodata.add(price);
          }

          return ListView(
            children: [
              buildCard(
                children: [
                  buildRow(
                    'Guncellenme Tarihi :',
                    items[0]['Tarih'],
                    bold: true,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              buildCard(
                    children: [
                      buildRow('USD ', '', bold: true),
                      Divider(color: Theme.of(context).primaryColor),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              buildRow('Alış:', '', bold: true),
                              Text(
                                items[0]['USD Alış'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1, // kalınlık
                            height: 40, // yükseklik
                            color: Theme.of(context).primaryColor,
                          ),
                          Column(
                            children: [
                              buildRow('Satış:', '', bold: true),
                              Text(
                                items[0]['USD Satış'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(color: Theme.of(context).primaryColor),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: SfCartesianChart(
                          title: ChartTitle(
                            text: '30 Günlük Dağılım (USD)',
                            textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          primaryXAxis: DateTimeAxis(
                            axisLine: AxisLine(
                              color: Theme.of(
                                context,
                              ).primaryColor, // X ekseni çizgi rengi
                            ),
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).primaryColor, // X ekseni etiket (tarih) rengi
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                            axisLine: AxisLine(
                              color: Theme.of(
                                context,
                              ).primaryColor, // Y ekseni çizgi rengi
                            ),
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).primaryColor, // Y ekseni etiket (sayı) rengi
                            ),
                            majorGridLines: MajorGridLines(
                              color: Theme.of(context).cardColor,
                            ),
                          ),

                          crosshairBehavior: _crosshairBehavior,
                          series: <CartesianSeries>[
                            LineSeries<ChartData, DateTime>(
                              dataSource: usddata,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fade()
                  .blur(begin: Offset(10, 10), end: Offset(0, 0))
                  .moveX(),
              buildCard(
                    children: [
                      buildRow('EUR ', '', bold: true),
                      Divider(color: Theme.of(context).primaryColor),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              buildRow('Alış:', '', bold: true),
                              Text(
                                items[0]['EUR Alış'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1, // kalınlık
                            height: 40, // yükseklik
                            color: Theme.of(context).primaryColor,
                          ),
                          Column(
                            children: [
                              buildRow('Satış:', '', bold: true),
                              Text(
                                items[0]['EUR Satış'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(color: Theme.of(context).primaryColor),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: SfCartesianChart(
                          title: ChartTitle(
                            text: '30 Günlük Dağılım (EUR)',
                            textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          primaryXAxis: DateTimeAxis(
                            axisLine: AxisLine(
                              color: Theme.of(
                                context,
                              ).primaryColor, // X ekseni çizgi rengi
                            ),
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).primaryColor, // X ekseni etiket (tarih) rengi
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                            axisLine: AxisLine(
                              color: Theme.of(
                                context,
                              ).primaryColor, // Y ekseni çizgi rengi
                            ),
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).primaryColor, // Y ekseni etiket (sayı) rengi
                            ),
                            majorGridLines: MajorGridLines(
                              color: Theme.of(context).cardColor,
                            ),
                          ),

                          crosshairBehavior: _crosshairBehavior,
                          series: <CartesianSeries>[
                            LineSeries<ChartData, DateTime>(
                              dataSource: eurodata,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fade()
                  .blur(begin: Offset(10, 10), end: Offset(0, 0))
                  .moveX(),

              buildCard(
                    children: [
                      buildRow('Altın ', '', bold: true),
                      Divider(color: Theme.of(context).primaryColor),
                      buildRow(
                        'Gram Altın =',
                        snapshot.data!['Altın'],
                        bold: true,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  )
                  .animate()
                  .fade()
                  .blur(begin: Offset(10, 10), end: Offset(0, 0))
                  .moveX(),

              buildCard(
                    children: [
                      buildRow('Kaynak ', '', bold: true),
                      Divider(color: Theme.of(context).primaryColor),
                      buildRow(
                        'USD ve EUR :',
                        'Türkiye Cumhuriyet Merkez Bankası',
                        bold: true,
                        color: Theme.of(context).primaryColor,
                      ),
                      buildRow(
                        '',
                        '(www.tcmb.gov.tr)',
                        color: Theme.of(context).primaryColor,
                      ),
                      buildRow(
                        'Altın :',
                        'Finage LTD  (https://finage.co.uk/)',
                        bold: true,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  )
                  .animate()
                  .fade()
                  .blur(begin: Offset(10, 10), end: Offset(0, 0))
                  .moveX(),

              SizedBox(height: 30),
            ],
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
              onPressed: () async {},
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
            style: bold
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

  Widget buildCard({required List<Widget> children}) {
    return Card(
      color:  Theme.of(context).secondaryHeaderColor,
      shape: context.watch<AppTheme>().isdarkmode
          ? RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).primaryColor, // Kenarlık rengi
                width: 1, // Kenarlık kalınlığı
              ),
              borderRadius: BorderRadius.circular(10),
            )
          : null,

      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}
