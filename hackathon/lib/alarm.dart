import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:hackathon/loader.dart';
import 'package:hackathon/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

// alarm metodu : arka planda calismasi icin global olmasi lazim !!
Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.status;
  debugPrint("${status.isGranted}");
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}

class Alarmmodel with ChangeNotifier {
  late List<Map<String, dynamic>> alarmmap = [];
  late List<Alarm> alarms = [];
  void savechanges() {
    notifyListeners();
  }
}

class Alarm {
  late DateTime zaman;
  late String aciklama;
  late bool isActive = true;
  late String tekrar = 'gunluk';
  late bool isgider = true;
  late int alarmID = 0;
  Alarm({required this.zaman, required this.aciklama});
}

class Bildirim extends StatelessWidget {
  const Bildirim({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Isgelir with ChangeNotifier {
  late bool isGelir = false;
  void savechanges() {
    notifyListeners();
  }
}

class Alarmpage extends StatefulWidget {
  const Alarmpage({super.key});

  @override
  State<Alarmpage> createState() => _AlarmpageState();
}

class _AlarmpageState extends State<Alarmpage> {
  late Future<void> getalarms;
  final TextEditingController _turController = TextEditingController();
  // Alarm a1 = Alarm(zaman: DateTime.now(), aciklama: 'su faturasi odeme');
  // Alarm a2 = Alarm(zaman: DateTime.now(), aciklama: 'elektrik faturasi odeme');
  // Alarm a3 = Alarm(zaman: DateTime.now(), aciklama: 'dogalgaz faturasi odeme');
  @override
  void initState() {
    super.initState();

    getalarms = getAlarms();
    // Provider.of<Alarmmodel>(context, listen: false).alarms.add(a1);
    // Provider.of<Alarmmodel>(context, listen: false).alarms.add(a2);
    // Provider.of<Alarmmodel>(context, listen: false).alarms.add(a3);
  }

  @override
  void dispose() {
    unawaited(saveAlarms());
    getIt<Alarmmodel>().alarms.clear();
    getIt<Alarmmodel>().alarmmap.clear();
    print('Sayfa kapandı! ${getIt<Alarmmodel>().alarms.length}');
    super.dispose(); // Bunu en son çağır
  }

  Future<void> saveAlarms() async {
    try {
      debugPrint('saveAlarms çalıştı ');

      // Alarm listelerini map'e çevir
      final model = getItalarms<Alarmmodel>();

      debugPrint('maplistuzunlugugu : ${model.alarmmap.length}');
      final jsonString = jsonEncode(model.alarmmap);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('alarms', jsonString);

      debugPrint('Alarm listesi başarıyla kaydedildi ');
    } catch (e, s) {
      debugPrint('HATA: saveAlarms başarısız oldu  $e');
      debugPrintStack(stackTrace: s);
    }
  }

  Future<void> getAlarms() async {
    await requestNotificationPermission();

    final prefs = await SharedPreferences.getInstance();

    String? jsonString = prefs.getString('alarms');
    if (jsonString == null) return;
    debugPrint('verileralindiiiii  : $jsonString');

    // JSON string → Liste'ye çevir
    List<dynamic> decoded = jsonDecode(jsonString);
    List<Map<String, dynamic>> alarms = decoded.cast<Map<String, dynamic>>();
    debugPrint('verileralindiiiii :   ${alarms.length}|||${decoded.length}');
    alarms.forEach((element) {
      Alarm a = Alarm(
        zaman: DateTime.fromMillisecondsSinceEpoch(element['zaman']),
        aciklama: element['aciklama'],
      );
      a.isActive = element['isactive'];
      a.isgider = element['isgider'];
      a.tekrar = element['tekrar'];
      getIt<Alarmmodel>().alarms.add(a);
      getIt<Alarmmodel>().alarmmap.add(element);
      debugPrint('verileralindiiiii :   $a');
    });
    getIt<Alarmmodel>().savechanges();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Theme.of(context).primaryColor, // ← geri ok rengi
            ),
            title: Text(
              'Alarmlar',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: FutureBuilder(
            future: getalarms,
            builder: (context, snapshot) {
              final alarmModel = context.watch<Alarmmodel>();
              final alarms = alarmModel.alarms;
              final alarmmap = alarmModel.alarmmap;

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Provider.of<Loader>(
                  context,
                  listen: false,
                ).loader(context);
              }

              if (alarms.isEmpty) {
                return icerikbossa(context);
              }

              return ListView.builder(
                itemCount: alarms.length,
                itemBuilder: (context, index) {
                  final alarm = alarms[index];
                  final alarmm = alarmmap[index];

                  return Dismissible(
                    key: Key('benzersiz-key-$index'),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) async {
                      final model = Provider.of<Alarmmodel>(
                        context,
                        listen: false,
                      );
                      model.alarms.removeAt(index);
                      model.alarmmap.removeAt(index);
                      await flutterLocalNotificationsPlugin.cancel(
                        model.alarms[index].alarmID,
                      );

                      model.savechanges();
                    },
                    background: Container(
                      color: Color.fromARGB(255, 181, 50, 41),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${alarm.zaman.hour.toString().padLeft(2, '0')}:${alarm.zaman.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Text(
                            alarm.isgider ? 'Gider' : 'Gelir',
                            style: TextStyle(
                              color: alarm.isgider ? Colors.red : Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        '${alarm.aciklama} | ${alarm.tekrar}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      trailing: Switch(
                        value: alarm.isActive,
                        onChanged: (value) async {
                          final model = Provider.of<Alarmmodel>(
                            context,
                            listen: false,
                          );
                          alarms[index].isActive = !alarm.isActive;
                          alarmmap[index]['isactive'] = !alarmm['isactive'];
                          if (!alarms[index].isActive) {
                            await flutterLocalNotificationsPlugin.cancel(
                              alarms[index].alarmID,
                            );
                            debugPrint('cencel edildi');
                          } else {
                            await yenidenAktifEt(alarms[index].alarmID);
                            debugPrint('yenidden aktif edildi');
                          }
                          model.savechanges();
                        },
                        activeColor: Theme.of(context).primaryColor,
                        inactiveThumbColor: Theme.of(context).primaryColor,
                        focusColor: Theme.of(context).primaryColor,
                        inactiveTrackColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showAlarmDialog(context);
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
        context.watch<Loader>().loading
            ? Provider.of<Loader>(context, listen: false).loader(context)
            : SizedBox(),
      ],
    );
  }

  void showAlarmDialog(BuildContext context) {
    DateTime selectedDateTime = DateTime.now();
    TextEditingController labelController = TextEditingController();
    String repeatOption = 'Günlük';

    final isgelirProvider = Provider.of<Isgelir>(context, listen: false);
    final alarmModel = Provider.of<Alarmmodel>(context, listen: false);
    final loader = Provider.of<Loader>(context, listen: false);
    final isGelir = Provider.of<Isgelir>(context, listen: false).isGelir;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gelir/Gider Toggle
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          isgelirProvider.isGelir = true;
                          isgelirProvider.savechanges();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isGelir ? Colors.green : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Gelir',
                            style: TextStyle(
                              color: isGelir
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          isgelirProvider.isGelir = false;
                          isgelirProvider.savechanges();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: !isGelir ? Colors.red : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Gider',
                            style: TextStyle(
                              color: !isGelir
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 10),

              // Saat Seçici
              TimePickerSpinner(
                is24HourMode: true,
                normalTextStyle: Theme.of(context).textTheme.bodyLarge,
                spacing: 40,
                itemHeight: 50,
                highlightedTextStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                itemWidth: 60,
                isForce2Digits: true,
                onTimeChange: (time) => selectedDateTime = time,
              ),

              const SizedBox(height: 10),

              // Açıklama
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 20),

              // Tekrar Dropdown
              DropdownButtonFormField<String>(
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                value: repeatOption,
                onChanged: (String? value) {
                  if (value != null) repeatOption = value;
                },
                items: ['Günlük', 'Her Pazar', 'Aylık (30\'u)']
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Tekrar',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              const SizedBox(height: 20),

              // Butonlar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "İptal",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      loader.loading = true;
                      loader.change();

                      final yeniAlarm = Alarm(
                        zaman: selectedDateTime,
                        aciklama: labelController.text,
                      );

                      yeniAlarm.tekrar = repeatOption;
                      yeniAlarm.isActive = true;
                      yeniAlarm.isgider = !isgelirProvider.isGelir;
                      yeniAlarm.alarmID = DateTime.now().millisecondsSinceEpoch
                          .remainder(100000);

                      alarmModel.alarms.add(yeniAlarm);

                      final mapalarm = {
                        'zaman': yeniAlarm.zaman.millisecondsSinceEpoch,
                        'aciklama': yeniAlarm.aciklama,
                        'isactive': yeniAlarm.isActive,
                        'isgider': yeniAlarm.isgider,
                        'tekrar': yeniAlarm.tekrar,
                        'alarmID': yeniAlarm.alarmID,
                      };
                      alarmModel.alarmmap.add(mapalarm);
                      alarmModel.savechanges();
                      final model = getItalarms<Alarmmodel>();
                      if (repeatOption == 'Günlük') {
                        gunlukbildirim(
                          yeniAlarm.zaman,
                          yeniAlarm.alarmID,
                          yeniAlarm.aciklama,
                        );
                      } else if (repeatOption == 'Her Pazar') {
                        haftalikbildirim(
                          yeniAlarm.zaman,
                          yeniAlarm.alarmID,
                          yeniAlarm.aciklama,
                        );
                      } else {
                        aylikbildirim(
                          yeniAlarm.zaman,
                          yeniAlarm.alarmID,
                          yeniAlarm.aciklama,
                        );
                      }

                      debugPrint(
                        'maplistuzunlugugu : ${model.alarmmap.length}',
                      );
                      Navigator.pop(context);

                      loader.loading = false;
                      loader.change();
                    },
                    child: const Text(
                      "Oluştur",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
        ],
      ),
    );
  }

  Future<void> gunlukbildirim(
    DateTime dateTime,
    int bildirimID,
    String aciklama,
  ) async {
    debugPrint('geliyorrrrrrr  $dateTime');
    final tzDateTime = tz.TZDateTime.from(dateTime, tz.local);

    debugPrint('tzDateTime:  $tzDateTime');
    await flutterLocalNotificationsPlugin.zonedSchedule(
      bildirimID,
      'Para Root',
      'bekleyen bir $aciklama islemin var , unutma !!!',
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pararootalarms23',
          'Para Root Alarm Bildirimleri',
          channelDescription: 'pararootalarms',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: 'loading',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // her gün aynı saatte
    );
    debugPrint('geldiiiiiiii');
    final prefs = await SharedPreferences.getInstance();

    // Bildirim bilgilerini string formatta sakla
    await prefs.setStringList('bildirim_$bildirimID', [
      dateTime.toIso8601String(),
      'gunluk',
      aciklama,
    ]);

    debugPrint("Bildirim ID: $bildirimID, zaman: $dateTime belleğe kaydedildi");
  }

  Future<void> haftalikbildirim(
    DateTime dateTime,
    int bildirimID,
    String aciklama,
  ) async {
    final tzDateTime = tz.TZDateTime.from(dateTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      bildirimID,
      'Para Root',
      'bekleyen bir $aciklama islemin var , unutma !!!',
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pararootalarms',
          'Para Root Alarm Bildirimleri',
          channelDescription: 'pararootalarms',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: 'loading',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime, // her hafta aynı saatte
    );
    final prefs = await SharedPreferences.getInstance();

    // Bildirim bilgilerini string formatta sakla
    await prefs.setStringList('bildirim_$bildirimID', [
      dateTime.toIso8601String(),
      'haftalik',
      aciklama,
    ]);

    debugPrint("Bildirim ID: $bildirimID, zaman: $dateTime belleğe kaydedildi");
  }

  Future<void> aylikbildirim(
    DateTime dateTime,
    int bildirimID,
    String aciklama,
  ) async {
    final tzDateTime = tz.TZDateTime.from(dateTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      bildirimID,
      'Para Root',
      'bekleyen bir $aciklama islemin var , unutma !!!',
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pararootalarms',
          'Para Root Alarm Bildirimleri',
          channelDescription: 'pararootalarms',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: 'loading',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.dateAndTime, // her ay aynı saatte
    );
    final prefs = await SharedPreferences.getInstance();

    // Bildirim bilgilerini string formatta sakla
    await prefs.setStringList('bildirim_$bildirimID', [
      dateTime.toIso8601String(),
      'aylik',
      aciklama,
    ]);

    debugPrint("Bildirim ID: $bildirimID, zaman: $dateTime belleğe kaydedildi");
  }

  Future<void> yenidenAktifEt(int bildirimID) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getStringList('bildirim_$bildirimID');

    if (dateStr != null) {
      final dateTime = DateTime.parse(dateStr[0]);
      if (dateStr[1] == 'gunluk') {
        await gunlukbildirim(dateTime, bildirimID, dateStr[2]);
      } else if (dateStr[1] == 'haftalik') {
        await haftalikbildirim(dateTime, bildirimID, dateStr[2]);
      } else {
        await aylikbildirim(dateTime, bildirimID, dateStr[2]);
      }
      debugPrint(
        "$bildirimID ID'li ve ${dateStr[1]} tekrarli bildirim tekrar aktif edildi",
      );
    } else {
      debugPrint(" Bildirim bilgisi bulunamadı");
    }
  }
}
