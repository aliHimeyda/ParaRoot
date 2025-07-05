
import 'package:flutter/material.dart';

class Profilmodel with ChangeNotifier {
  String? kamerailecekilenresimlinki;
  late Map<String, dynamic> currentuser;
  void guncelle() {
    notifyListeners();
  }
}
