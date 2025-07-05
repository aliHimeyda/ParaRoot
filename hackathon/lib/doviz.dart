import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:hackathon/loader.dart';

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

class PriceData {
  final DateTime date;
  final double price;

  PriceData(this.date, this.price);
}

class Doviz extends StatefulWidget {
  const Doviz({super.key});

  @override
  State<Doviz> createState() => _DovizState();
}

class _DovizState extends State<Doviz> {
  late Future<Map<String, dynamic>?> datagetir;
  final List<PriceData> data = [
    PriceData(DateTime(2025, 6, 10), 3.7850),
    PriceData(DateTime(2025, 6, 20), 3.7835),
    PriceData(DateTime(2025, 7, 1), 3.7860),
    PriceData(DateTime(2025, 7, 10), 3.7842),
    PriceData(DateTime(2025, 7, 20), 3.7875),
    PriceData(DateTime(2025, 8, 1), 3.7856),
    PriceData(DateTime(2025, 8, 10), 3.7868),
    PriceData(DateTime(2025, 8, 20), 3.7840),
  ];

  @override
  void initState() {
    super.initState();
    datagetir = fetchLast30DaysRatesWithAltin(
      'API_KEY12OV2ZXBOXON1DICGCBUZQ8I4D7R5CMJ',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Doviz Fiyatlari',
          style: Theme.of(context).textTheme.bodyLarge,
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
          late List<PriceData> usddata = [];
          late List<PriceData> eurodata = [];

          for (Map<String, dynamic> item in items) {
            final price = PriceData(
              DateFormat('dd.MM.yyyy').parse(item['Tarih']),
              double.parse(item['USD Satış']),
            );
            usddata.add(price);
          }
          for (Map<String, dynamic> item in items) {
            final price = PriceData(
              DateFormat('dd.MM.yyyy').parse(item['Tarih']),
              double.parse(item['EUR Satış']),
            );
            eurodata.add(price);
          }

          return ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${items[0]['Tarih']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ListTile(
                    title: Text('USD Alış: ${items[0]['USD Alış']}'),
                    trailing: Text('USD Satış: ${items[0]['USD Satış']} TL'),
                  ),
                  ListTile(
                    title: Text('EUR Alış: ${items[0]['EUR Alış']}'),
                    trailing: Text('EUR Satış: ${items[0]['EUR Satış']} TL'),
                  ),

                  ListTile(title: Text('Altın: ${snapshot.data!['Altın']}')),
                  Divider(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(),
                  primaryYAxis: NumericAxis(),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries>[
                    ColumnSeries<PriceData, DateTime>(
                      dataSource: usddata,
                      xValueMapper: (PriceData p, _) => p.date,
                      yValueMapper: (PriceData p, _) => p.price,
                      name: 'Altın',
                      color: Colors.brown,
                      dataLabelSettings: DataLabelSettings(isVisible: false),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(),
                  primaryYAxis: NumericAxis(),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries>[
                    ColumnSeries<PriceData, DateTime>(
                      dataSource: eurodata,
                      xValueMapper: (PriceData p, _) => p.date,
                      yValueMapper: (PriceData p, _) => p.price,
                      name: 'Altın',
                      color: Colors.brown,
                      dataLabelSettings: DataLabelSettings(isVisible: false),
                    ),
                  ],
                ),
              ),
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
      color: Theme.of(context).secondaryHeaderColor,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}
