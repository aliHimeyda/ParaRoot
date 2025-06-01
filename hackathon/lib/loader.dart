import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hackathon/themeprovider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loader with ChangeNotifier {
  late bool loading = false;
  void change() {
    notifyListeners();
  }

  Center loader(context) {
    return Center(
      child: LoadingAnimationWidget.inkDrop(
        // LoadingAnimationwidget that call the
        color: Theme.of(context).primaryColor, // staggereddotwave animation
        size: 50,
      ),
    );
  }
}
