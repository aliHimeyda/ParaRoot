import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/colors.dart';
import 'package:hackathon/firebaseServices.dart';
import 'package:hackathon/hareketlersayfasi.dart';
import 'package:hackathon/loader.dart';
import 'package:hackathon/router.dart';
import 'package:hackathon/themeprovider.dart';
import 'package:provider/provider.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  final TextEditingController _adsoyadController = TextEditingController();
  final TextEditingController _IDController = TextEditingController();
  bool isLogin = true;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Stack(
            children: [
              // 🔹 Background Image
              Container(
                height: MediaQuery.of(context).size.height / 2 + 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  image: DecorationImage(
                    alignment: Alignment.topCenter,
                    image: AssetImage(
                      'assets/loginpararoot.gif',
                    ), // Arka plan resmi
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // 🔹 Sliding Panel
              DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.4,
                maxChildSize: 0.75,
                builder: (context, scrollController) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔘 Tabs
                          SizedBox(height: 15),
                          Center(
                            child: Container(
                              width: 350,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  // Giriş Yap
                                  Expanded(
                                    child: GestureDetector(
                                      onTap:
                                          () => setState(() => isLogin = true),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isLogin
                                                  ? Theme.of(
                                                    context,
                                                  ).secondaryHeaderColor
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          border:
                                              isLogin
                                                  ? Border.all(
                                                    color: Colors.black,
                                                    width: 1,
                                                  )
                                                  : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Giriş Yap',
                                          style: TextStyle(
                                            color:
                                                isLogin
                                                    ? Colors.black
                                                    : Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Kayıt Ol
                                  Expanded(
                                    child: GestureDetector(
                                      onTap:
                                          () => setState(() => isLogin = false),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              !isLogin
                                                  ? Theme.of(
                                                    context,
                                                  ).secondaryHeaderColor
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          border:
                                              !isLogin
                                                  ? Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 1,
                                                  )
                                                  : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Kayıt Ol',
                                          style: TextStyle(
                                            color:
                                                isLogin
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            isLogin ? "Tekrar Hoş Geldiniz!" : "Hoş Geldiniz!",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (!isLogin)
                            TextField(
                              controller: _adsoyadController,
                              decoration: const InputDecoration(
                                labelText: "Adınız ve Soyadınız",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          if (!isLogin) const SizedBox(height: 12),
                          if (!isLogin)
                            TextField(
                              controller: _IDController,
                              decoration: const InputDecoration(
                                labelText: "ID numarasi (istege bagli)",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          if (!isLogin) const SizedBox(height: 12),

                          TextField(
                            controller: _mailController,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: _sifreController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Şifrenizi Girin",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style:
                                  Theme.of(context).elevatedButtonTheme.style,
                              onPressed: () async {
                                if (!isLogin) {
                                  _kayitEkle();
                                }
                                girisYap(context);
                              },
                              child: Text(
                                isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Color(
                                    0xFFE0E0E0,
                                  ), // açık gri çizgi rengi
                                  endIndent: 12,
                                ),
                              ),
                              Text(
                                "veya",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Color(0xFFE0E0E0),
                                  indent: 12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              icon: Image.asset('./assets/google.png'),
                              label: const Text(
                                "Google ile devam et",
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () async {
                                final userCredential = await signInWithGoogle();
                                if (userCredential != null) {
                                  print(
                                    'Giriş Başarılı: ${userCredential.user?.displayName}',
                                  );
                                  context.push(Paths.hareketler);
                                } else {
                                  print('Giriş iptal edildi veya hata oluştu');
                                }
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          if (!isLogin)
                            const Text.rich(
                              TextSpan(
                                text: "Kayıtlı butonuna basarak ",
                                children: [
                                  TextSpan(
                                    text: "Kişisel Verilerin Korunması Kanunu",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  TextSpan(text: "’nu ve "),
                                  TextSpan(
                                    text: "Üyelik Sözleşmesi’ni",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  TextSpan(text: " kabul etmiş sayılırsınız."),
                                ],
                              ),
                              style: TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        context.watch<Loader>().loading
            ? Provider.of<Loader>(context, listen: false).loader(context)
            : SizedBox(),
      ],
    );
  }

  Future<void> girisYap(BuildContext context) async {
    final mail = _mailController.text.trim();
    final sifre = _sifreController.text.trim();

    // 1. Klavyeyi kapat
    FocusScope.of(context).unfocus();

    if (mail.isEmpty || sifre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("E-posta ve şifre boş olamaz")),
      );
      return;
    }

    try {
      // Firebase Auth ile giriş
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: mail,
        password: sifre,
      );

      // 2. Controller'ları temizle
      _mailController.clear();
      _sifreController.clear();

      // 3. Giriş başarılı → sayfaya yönlendir
      context.pushReplacement(Paths.hareketler);
    } on FirebaseAuthException catch (e) {
      String mesaj = "Giriş başarısız";

      if (e.code == 'user-not-found') {
        mesaj = "Kullanıcı bulunamadı";
      } else if (e.code == 'wrong-password') {
        mesaj = "Şifre yanlış";
      } else if (e.code == 'invalid-email') {
        mesaj = "Geçersiz e-posta";
      } else if (e.code == 'user-disabled') {
        mesaj = "Kullanıcı devre dışı bırakılmış";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mesaj)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Bir hata oluştu")));
    }
  }

  Future<void> _kayitEkle() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _mailController.text.trim(),
            password: _sifreController.text.trim(),
          );

      final uid = userCredential.user!.uid;

      String id;
      if (_IDController.text.trim().isEmpty) {
        id = _mailController.text.trim();
      } else {
        id = _IDController.text.trim();
      }

      final veri = {
        'ID': uid, // UID kullanmak daha doğru
        'gosterilenID': id, // İstersen gösterilecek ID ayrı alan olarak sakla
        'isimsoyisim': _adsoyadController.text.trim(),
        'mail': _mailController.text.trim(),
        'sifre': _sifreController.text.trim(), // DİKKAT: Güvenli değil
        'telefon': "NO",
      };

      // Firestore'a kaydet — UID ile eşleştir
      await FirebaseFirestore.instance
          .collection('kullanicibilgileri')
          .doc(uid)
          .set(veri);

      // Giriş yapıldı → yönlendir
      context.go(Paths.hareketler);
    } on FirebaseAuthException catch (e) {
      String mesaj = "Bir hata oluştu";

      if (e.code == 'invalid-email') {
        mesaj = "Geçersiz e-posta formatı";
      } else if (e.code == 'email-already-in-use') {
        mesaj = "Bu e-posta zaten kayıtlı";
      } else if (e.code == 'weak-password') {
        mesaj = "Şifre en az 6 karakter olmalı";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mesaj)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Beklenmeyen bir hata oluştu")),
      );
    }
  }
}
