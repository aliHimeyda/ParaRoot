
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Profilmodel with ChangeNotifier {
  String? kamerailecekilenresimlinki;
  late Map<String, dynamic> currentuser;
  void guncelle() {
    notifyListeners();
  }
}
