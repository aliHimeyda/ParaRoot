import 'package:flutter/material.dart';
import 'package:hackathon/firebaseServices.dart';
import 'package:hackathon/loader.dart';
import 'package:hackathon/main.dart';

class Veriprovider with ChangeNotifier {
  late List<Map<String, dynamic>?> veri = [];
  late int gelirtoplami = 0;
  late int borctoplami = 0;
  final now = DateTime.now();
  late DateTime baslangictarih = DateTime(now.year, now.month, 1);
  late DateTime bitistarih = DateTime(now.year, now.month + 1, 1);

  Future<void> getusermoneydata() async {
    veri = await getUsermoneyData(baslangictarih, bitistarih);

    notifyListeners();
  }

  Future<void> getusermoneytoplami() async {
    gelirtoplami = await getUsermoneytoplami(baslangictarih, bitistarih);
    notifyListeners();
  }

  Future<void> getuserborctoplami() async {
    borctoplami = await getUserborctoplami(baslangictarih, bitistarih);
    notifyListeners();
  }

  Future<void> addveri(Map<String, dynamic> yeniveri) async {
    veri.add(yeniveri);
    if (yeniveri['gidermi']) {
      borctoplami += (yeniveri['deger'] as num).toInt();
    } else {
      gelirtoplami += (yeniveri['deger'] as num).toInt();
    }
    notifyListeners();
  }

  Future<void> gettumveries() async {
    getIt<Loader>().loading = true;
    getIt<Loader>().change();
    veri = await getUsermoneyData(baslangictarih, bitistarih);
    gelirtoplami = await getUsermoneytoplami(baslangictarih, bitistarih);
    borctoplami = await getUserborctoplami(baslangictarih, bitistarih);
    getIt<Loader>().loading = false;
    getIt<Loader>().change();
    notifyListeners();
  }
}
