
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Profilmodel with ChangeNotifier {
  late String? kamerailecekilenresimlinki = null;
  late Map<String, dynamic> currentuser;
  void guncelle() {
    notifyListeners();
  }
}
