import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hackathon/hareketmodel.dart';
import 'package:hackathon/loader.dart';
import 'package:hackathon/main.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Firebaseservices {
  static User? currentuser;
  static bool isloading = false;
}

Future<void> getcurrentuser() async {
  Firebaseservices.currentuser = FirebaseAuth.instance.currentUser;
  Firebaseservices.isloading = true;
}
Future<void> addveri(Map<String,dynamic> veri)async{
  await FirebaseFirestore.instance.collection('gelirgidertablosu').add(veri);
}

Future<Map<String, dynamic>?> getUserData() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final querySnapshot =
      await FirebaseFirestore.instance
          .collection('kullanicibilgileri')
          .doc(uid)
          .get();

  if (querySnapshot.exists) {
    debugPrint(querySnapshot.data().toString());
    return querySnapshot.data();
  } else {
    return null;
  }
}

Future<Map<String, dynamic>?> changeUserData() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final querySnapshot =
      await FirebaseFirestore.instance
          .collection('kullanicibilgileri')
          .doc(uid)
          .get();

  if (querySnapshot.exists) {
    return querySnapshot.data();
  } else {
    return null;
  }
}

Future<List<Map<String, dynamic>?>> getUsermoneyData(
  DateTime baslangictarih,
  DateTime bitistarih,
) async {
  debugPrint(
    "baslangic :${baslangictarih.toString()}   bitis : ${bitistarih.toString()}",
  );
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final querySnapshot =
      await FirebaseFirestore.instance
          .collection('gelirgidertablosu')
          .where('ID', isEqualTo: uid)
          .where('tarih', isGreaterThanOrEqualTo: baslangictarih)
          .where('tarih', isLessThan: bitistarih)
          .orderBy('tarih', descending: true)
          .get();
  debugPrint(
    'gelen listenin boyutu :=====  ${querySnapshot.docs.map((doc) => doc.data()).toList().length}',
  );
  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
  return [];
}

Future<int> getUsermoneytoplami(
  DateTime baslangictarih,
  DateTime bitistarih,
) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final querySnapshot =
      await FirebaseFirestore.instance
          .collection('gelirgidertablosu')
          .where('ID', isEqualTo: uid)
          .where('tarih', isGreaterThanOrEqualTo: baslangictarih)
          .where('tarih', isLessThan: bitistarih)
          .orderBy('tarih', descending: true)
          .get();
  int toplamgelir = 0;
  List<Map<String, dynamic>> bilgiler =
      querySnapshot.docs.map((doc) => doc.data()).toList();
  int verisayisi = bilgiler.length;
  for (int i = 0; i < verisayisi; i++) {
    if (!bilgiler[i]['gidermi']) {
      toplamgelir += bilgiler[i]['deger'] as int;
    }
  }
  return toplamgelir;
}

Future<void> tumkayitlarisil( DateTime baslangictarih,
  DateTime bitistarih,) async {

  final uid = FirebaseAuth.instance.currentUser!.uid;
  final querySnapshot =
      await FirebaseFirestore.instance
          .collection('gelirgidertablosu')
          .where('ID', isEqualTo: uid)
          .where('tarih', isGreaterThanOrEqualTo: baslangictarih)
          .where('tarih', isLessThan: bitistarih)
          .orderBy('tarih', descending: true)
          .get();

  for (var doc in querySnapshot.docs) {
    await doc.reference.delete();
  }
}

Future<void> kayitsil(HareketModel hareket) async {
  
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final querySnapshot =
      await FirebaseFirestore.instance
          .collection('gelirgidertablosu')
          .where('ID', isEqualTo: uid)
          .where('aciklama', isEqualTo: hareket.aciklama)
          .where('baslik', isEqualTo: hareket.baslik)
          .where('deger', isEqualTo: hareket.deger)
          .get();

  for (var doc in querySnapshot.docs) {
    await doc.reference.delete();
  }
}

Future<int> getUserborctoplami(
  DateTime baslangictarih,
  DateTime bitistarih,
) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final querySnapshot =
      await FirebaseFirestore.instance
          .collection('gelirgidertablosu')
          .where('ID', isEqualTo: uid)
          .where('tarih', isGreaterThanOrEqualTo: baslangictarih)
          .where('tarih', isLessThan: bitistarih)
          .orderBy('tarih', descending: true)
          .get();
  int toplamborc = 0;
  List<Map<String, dynamic>> bilgiler =
      querySnapshot.docs.map((doc) => doc.data()).toList();
  int verisayisi = bilgiler.length;
  for (int i = 0; i < verisayisi; i++) {
    if (bilgiler[i]['gidermi']) {
      toplamborc += bilgiler[i]['deger'] as int;
    }
  }
  return toplamborc;
}

Future<UserCredential?> signInWithGoogle() async {
  getIt<Loader>().loading = true;
  getIt<Loader>().change();
  try {
    // Google kullanıcı seçimi
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      // Kullanıcı iptal etti
      return null;
    }

    // Kimlik doğrulama bilgilerini al
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Firebase kimlik bilgisi oluştur
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Firebase ile giriş yap
    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(credential);

    final user = userCredential.user;

    if (user != null) {
      debugPrint('kosula giris yapildi ------------------------');
      Firebaseservices.currentuser = user;
      Firebaseservices.isloading = true;

      final userDoc =
          await FirebaseFirestore.instance
              .collection('kullanicibilgileri')
              .doc(user.uid)
              .get();

      debugPrint(
        ' giris bilgileri alindi ve giris yapildi ------------------------',
      );
      // Eğer kullanıcı Firestore’da kayıtlı değilse, ekle
      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('kullanicibilgileri')
            .doc(user.uid)
            .set({
              'ID': user.uid,
              'isimsoyisim': user.displayName ?? '',
              'mail': user.email ?? '',
              'telefon': '',
              'sifre': '', // Google ile gelen kullanıcı için şifre boş olabilir
            });
      }
      getIt<Loader>().loading = false;
      getIt<Loader>().change();
      return userCredential;
    }
    getIt<Loader>().loading = false;
    getIt<Loader>().change();
    return null;
  } catch (e) {
    getIt<Loader>().loading = false;
    getIt<Loader>().change();
    debugPrint('Google Sign-In Hatası: $e');
    return null;
  }
}

Future<String?> resimYukleVeLinkAl() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  getIt<Loader>().loading = true;
  getIt<Loader>().change();
  if (image == null) return null;

  final apiKey = "6c92a28a573e07438d5e0c35cea3da08";

  final bytes = await File(image.path).readAsBytes();
  final base64Image = base64Encode(bytes);

  final response = await http.post(
    Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey"),
    body: {
      "image": base64Image,
      "name": "resim_${DateTime.now().millisecondsSinceEpoch}",
    },
  );
  getIt<Loader>().loading = false;
  getIt<Loader>().change();
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return json["data"]["url"];
  } else {
    print("Hata: ${response.body}");
    return null;
  }
}

Future<String?> cekilenresmiYukleVeLinkAl(String imagepath) async {
  getIt<Loader>().loading = true;
  getIt<Loader>().change();
  final apiKey = "6c92a28a573e07438d5e0c35cea3da08";

  final bytes = await File(imagepath).readAsBytes();
  final base64Image = base64Encode(bytes);

  final response = await http.post(
    Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey"),
    body: {
      "image": base64Image,
      "name": "resim_${DateTime.now().millisecondsSinceEpoch}",
    },
  );
  getIt<Loader>().loading = false;
  getIt<Loader>().change();
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return json["data"]["url"];
  } else {
    print("Hata: ${response.body}");
    return null;
  }
}
