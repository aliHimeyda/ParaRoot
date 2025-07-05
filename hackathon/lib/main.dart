import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:hackathon/alarm.dart';
import 'package:hackathon/loader.dart';
import 'package:hackathon/profilmodel.dart';
import 'package:hackathon/router.dart';
import 'package:hackathon/themeprovider.dart';
import 'package:hackathon/veriprovider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final getIt = GetIt.instance;
final getItveri = GetIt.instance;
final getItprofil = GetIt.instance;
final getItalarms = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<Loader>(() => Loader());
  getItveri.registerLazySingleton<Veriprovider>(() => Veriprovider());
  getItprofil.registerLazySingleton<Profilmodel>(() => Profilmodel());
  getItalarms.registerLazySingleton<Alarmmodel>(() => Alarmmodel());
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  Bildirim ayarları
  await initNotifications();

  //  Zaman dilimi ayarları
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

  setupLocator();
  await Firebase.initializeApp();
  await initializeDateFormatting('tr_TR', null); // Türkçe için locale başlat
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Loader>.value(value: getIt<Loader>()),
        ChangeNotifierProvider<Veriprovider>.value(
          value: getItveri<Veriprovider>(),
        ),
        ChangeNotifierProvider<Profilmodel>.value(
          value: getItprofil<Profilmodel>(),
        ),
        ChangeNotifierProvider<Alarmmodel>.value(value: getIt<Alarmmodel>()),
        ChangeNotifierProvider(create: (_) => AppTheme()),
        ChangeNotifierProvider(create: (_) => Veriprovider()),
        ChangeNotifierProvider(create: (_) => Isgelir()),
      ],
      child: Program(),
    ),
  );
}

class Program extends StatelessWidget {
  const Program({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppTheme>(
      builder: (context, viewModel, child) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: viewModel.theme,
        routerConfig: router,
      ),
    );
  }
}
