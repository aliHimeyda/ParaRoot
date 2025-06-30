import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/analizsayfasi.dart';
import 'package:hackathon/gelirgidereklesayfasi.dart';
import 'package:hackathon/hareketdetaysayfasi.dart';
import 'package:hackathon/hareketlersayfasi.dart';
import 'package:hackathon/hareketmodel.dart';
import 'package:hackathon/kameracekimsayfasi.dart';
import 'package:hackathon/loading.dart';
import 'package:hackathon/loginpage.dart';
import 'package:hackathon/mainpage.dart';
import 'package:hackathon/profilsayfasi.dart';
import 'package:hackathon/qrsayfasi.dart';

final routerkey = GlobalKey<NavigatorState>();

class Paths {
  Paths._();

  static const String loadingpage = '/';
  static const String loginpage = '/loginpage';
  static const String hareketler = '/hareketlersayfasi';
  static const String hareketdetaysayfasi = '/hareketdetaysayfasi';
  static const String gelirgidereklesayfasi = '/GelirGiderEkleSayfasi';
  static const String profilsayfasi = '/profilsayfasi';
  static const String kameracekimsayfasi = '/kameracekimsayfasi';
  static const String analizsayfasi = '/analizsayfasi';
  static const String qrsayfasi = '/qrsayfasi';
}

// ignore: non_constant_identifier_names
final router = GoRouter(
  navigatorKey: routerkey,

  initialLocation: Paths.loadingpage,
  routes: [
    StatefulShellRoute.indexedStack(
      builder:
          (context, state, navigationShell) =>
              Anasayfa(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Paths.loadingpage,
              builder: (context, state) => const LoadingPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Paths.loginpage,
              builder: (context, state) => const Loginpage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Paths.hareketler,
              builder: (context, state) => const Hareketlersayfasi(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Paths.hareketdetaysayfasi,
              builder: (context, state) {
                final hareket = state.extra as HareketModel;
                return HareketDetaySayfasi(detaynesnesi: hareket);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Paths.gelirgidereklesayfasi,
              builder: (context, state) => const GelirGiderEkleSayfasi(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Paths.profilsayfasi,
              builder: (context, state) => const ProfilSayfasi(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Paths.kameracekimsayfasi,
              builder: (context, state) => const KameraCekimSayfasi(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Paths.qrsayfasi,
              builder: (context, state) => const Qrsayfasi(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Paths.analizsayfasi,
              builder: (context, state) => const Analizsayfasi(),
            ),
          ],
        ),
      ],
    ),
  ],
);
