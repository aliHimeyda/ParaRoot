import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hackathon/loader.dart';
import 'package:hackathon/profilmodel.dart';
import 'package:hackathon/router.dart';
import 'package:hackathon/themeprovider.dart';
import 'package:hackathon/veriprovider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

final getIt = GetIt.instance;
final getItveri = GetIt.instance;
final getItprofil = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<Loader>(() => Loader());
  getItveri.registerLazySingleton<Veriprovider>(() => Veriprovider());
  getItprofil.registerLazySingleton<Profilmodel>(() => Profilmodel());
}

Future<void> main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized(); // async işlemler için
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('tr_TR', null); // Türkçe için locale başlat
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Loader>.value(value: getIt<Loader>()),
        ChangeNotifierProvider<Veriprovider>.value(value: getItveri<Veriprovider>()),
        ChangeNotifierProvider<Profilmodel>.value(value: getItprofil<Profilmodel>()),
        ChangeNotifierProvider(create: (_) => AppTheme()),
        ChangeNotifierProvider(create: (_) => Veriprovider()),
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
      builder:
          (context, viewModel, child) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: viewModel.theme,
            routerConfig: router,
          ),
    );
  }
}
