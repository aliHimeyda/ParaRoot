import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/colors.dart';
import 'package:hackathon/firebaseServices.dart';
import 'package:hackathon/hareketlersayfasi.dart';
import 'package:hackathon/loader.dart';
import 'package:hackathon/router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hackathon/themeprovider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await getcurrentuser();
      }
      if (Firebaseservices.isloading) {
        context.pushReplacement(Paths.hareketler);
      } else {
        context.pushReplacement(Paths.loginpage);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Center(child: Image.asset('./assets/pararoot.gif')),
      ),
    );
  }
}
