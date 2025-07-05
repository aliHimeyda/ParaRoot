import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/firebaseServices.dart';
import 'package:hackathon/router.dart';
import 'package:hackathon/themeprovider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        decoration: BoxDecoration(color: const Color(0xFF005C78)),
        child: Center(child: Image.asset('./assets/pararoot.gif')),
      ),
    );
  }
}
