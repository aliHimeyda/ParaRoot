import 'package:flutter/material.dart';

class Loader with ChangeNotifier {
  late bool loading = false;
  void change() {
    notifyListeners();
  }

  Container loader(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: const Color.fromARGB(46, 0, 0, 0),
      child: Center(
        child: Image.asset(
          color: Theme.of(context).primaryColor,
          'assets/loading.gif',
          width: 100,
          height: 100,
          // color: Theme.of(context).primaryColor,
        ),
        // child: LoadingAnimationWidget.inkDrop(
        //   // LoadingAnimationwidget that call the
        //   color: Theme.of(context).primaryColor, // staggereddotwave animation
        //   size: 50,
        // ),
      ),
    );
  }
}
