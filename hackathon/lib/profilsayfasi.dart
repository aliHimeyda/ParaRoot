import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/firebaseServices.dart';
import 'package:hackathon/loader.dart';
import 'package:hackathon/main.dart';
import 'package:hackathon/profilmodel.dart';
import 'package:hackathon/router.dart';
import 'package:hackathon/themeprovider.dart';
import 'package:provider/provider.dart';

class ProfilSayfasi extends StatefulWidget {
  const ProfilSayfasi({super.key});

  @override
  State<ProfilSayfasi> createState() => _ProfilSayfasiState();
}

class _ProfilSayfasiState extends State<ProfilSayfasi> {
  late Future<Map<String, dynamic>?> _userFuture;
  String? resimURL;
  late TextEditingController resim = TextEditingController();
  late final TextEditingController _telefonController = TextEditingController();
  late TextEditingController currentController = TextEditingController();
  late TextEditingController newController = TextEditingController();
  late TextEditingController email = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userFuture = getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          "Profil Bilgileri",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, // ← oku kırmızı yapar
        ),
      ),
      body: Stack(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Provider.of<Loader>(
                  context,
                  listen: false,
                ).loader(context);
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Text("Kullanıcı bulunamadı");
              }

              Provider.of<Profilmodel>(context, listen: false).currentuser =
                  snapshot.data!;
              debugPrint(context.watch<Profilmodel>().currentuser.toString());
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).primaryColor, // Gri çizgi rengi
                  ),

                  const SizedBox(height: 50),

                  // Fotoğraf ve isim
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          // Büyük profil dairesi
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                            ), // açık gri arka plan
                            child:
                                context
                                        .watch<Profilmodel>()
                                        .currentuser['profilresmi'] ==
                                    ''
                                ? Image.asset(
                                    'assets/anonimresmi.png',
                                    fit: BoxFit.contain,
                                  )
                                : Image.network(
                                    context
                                        .watch<Profilmodel>()
                                        .currentuser['profilresmi'],
                                    fit: BoxFit.cover,
                                  ),
                          ),

                          // Küçük kamera dairesi
                          GestureDetector(
                            onTap: () {
                              showBelgeSecimPopup(context);
                            },
                            child: Positioned(
                              bottom: 0,
                              right: 4,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(6),
                                child: Image.asset(
                                  'assets/kamera.png',
                                  fit: BoxFit.contain,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        context.watch<Profilmodel>().currentuser['isimsoyisim'],
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  Divider(
                    height: 32,
                    thickness: 1,
                    color: Theme.of(context).primaryColor, // Gri çizgi rengi
                  ),
                  const SizedBox(height: 20),
                  // İsim alanı
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Adınız ve Soyadınız",
                      hintText: context
                          .watch<Profilmodel>()
                          .currentuser['isimsoyisim'],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bilgi kartları
                  _infoTile(
                    context,
                    "Telefon Numarası",
                    "**********${context.watch<Profilmodel>().currentuser['telefon'].substring(context.watch<Profilmodel>().currentuser['telefon'].length - 2)}",
                    _telefonPopup,
                  ),
                  _infoTile(
                    context,
                    "E-Mail",
                    '${context.watch<Profilmodel>().currentuser['mail'].substring(0, 2)}*********${context.watch<Profilmodel>().currentuser['mail'].substring(context.watch<Profilmodel>().currentuser['mail'].length - 10, context.watch<Profilmodel>().currentuser['mail'].length)}',
                    _emailPopup,
                  ),
                  _infoTile(
                    context,
                    "Şifre",
                    '${context.watch<Profilmodel>().currentuser['sifre'].substring(0, 2)}********',
                    _sifrePopup,
                  ),
                  SizedBox(height: 50),
                  Container(
                    width: MediaQuery.of(context).size.width - 20,
                    height: MediaQuery.of(context).size.height / 10,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.3,
                          color: AppColors.koyuGri,
                        ),
                        top: BorderSide(width: 0.3, color: AppColors.koyuGri),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(context.watch<AppTheme>().temaiconu, size: 30),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tema Modu',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: context.watch<AppTheme>().isdarkmode,
                            onChanged: (value) {
                              Provider.of<AppTheme>(
                                context,
                                listen: false,
                              ).changetheme();
                            },
                            // value: widget.isDarkMode,
                            // onChanged: widget.onChanged, // Tema değiştirme fonksiyonunu çağırır
                            activeColor: Theme.of(
                              context,
                            ).primaryColor, // Açık mod rengi
                            inactiveThumbColor: Theme.of(
                              context,
                            ).primaryColor, // Karanlık mod rengi
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  // Kaydet butonu
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _verilerikaydet(context);
                      },
                      style: Theme.of(context).elevatedButtonTheme.style,
                      child: const Text(
                        "degisiklikleri Kaydet",
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Firebaseservices.isloading = false;
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          context.go(Paths.loginpage);
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("Çıkış Yap"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  SizedBox(height: 150),
                ],
              );
            },
          ),
          context.watch<Loader>().loading
              ? Provider.of<Loader>(context, listen: false).loader(context)
              : SizedBox(),
        ],
      ),
    );
  }

  Future<void> _verilerikaydet(context) async {
    getIt<Loader>().loading = true;
    getIt<Loader>().change();

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Kullanıcının kendi belgesini güncelle
    try {
      await FirebaseFirestore.instance
          .collection('kullanicibilgileri')
          .doc(uid)
          .update({
            'isimsoyisim': Provider.of<Profilmodel>(
              context,
              listen: false,
            ).currentuser['isimsoyisim'],
            'mail': Provider.of<Profilmodel>(
              context,
              listen: false,
            ).currentuser['mail'],
            'profilresmi': Provider.of<Profilmodel>(
              context,
              listen: false,
            ).currentuser['profilresmi'],
            'sifre': Provider.of<Profilmodel>(
              context,
              listen: false,
            ).currentuser['sifre'],
            'telefon': Provider.of<Profilmodel>(
              context,
              listen: false,
            ).currentuser['telefon'],
          });
      getIt<Loader>().loading = false;
      getIt<Loader>().change();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("islem basarili")));
    } catch (e) {
      getIt<Loader>().loading = false;
      getIt<Loader>().change();
      debugPrint('guncelleme hatasi : $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("hata olustu")));
    }
  }

  Widget _infoTile(
    BuildContext context,
    String title,
    String maskedValue,
    Function modalFunc,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 4),
              Text(maskedValue, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          InkWell(
            onTap: () => modalFunc(context),
            child: Text(
              "Düzenle",
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resimSecVeYukle(context) async {
    resimURL = await resimYukleVeLinkAl();
    if (resimURL != null) {
      getItprofil<Profilmodel>().currentuser['profilresmi'] = resimURL!;
      getItprofil<Profilmodel>().guncelle();

      print("Resim başarıyla yüklendi: $resimURL");
      // Bu URL'yi Image.network(resimURL) ile kullanabilirsin
    } else {
      print("Resim yüklenemedi.");
    }
  }

  // Telefon Popup
  void _telefonPopup(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Telefon Numarası",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _telefonController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Telefon Numarası",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: Theme.of(context).elevatedButtonTheme.style,
                  onPressed: () {
                    Provider.of<Profilmodel>(
                      context,
                      listen: false,
                    ).currentuser['telefon'] = _telefonController.text;

                    Provider.of<Profilmodel>(context, listen: false).guncelle();
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                        content: Text(
                          "basarili",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Değiştir",
                    style: Theme.of(
                      context,
                    ).elevatedButtonTheme.style?.textStyle?.resolve({}),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  // E-Mail Popup
  void _emailPopup(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),
              Text("E-Mail", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "E-Mail",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: Theme.of(context).elevatedButtonTheme.style,
                  onPressed: () {
                    Provider.of<Profilmodel>(
                      context,
                      listen: false,
                    ).currentuser['mail'] = email.text;

                    Provider.of<Profilmodel>(context, listen: false).guncelle();
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                        content: Text(
                          "basarili",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Değiştir",
                    style: Theme.of(
                      context,
                    ).elevatedButtonTheme.style?.textStyle?.resolve({}),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  // Şifre Popup
  void _sifrePopup(BuildContext context) {
    bool isCurrentVisible = false;
    bool isNewVisible = false;

    showModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text("Şifre", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: currentController,
                    obscureText: !isCurrentVisible,
                    decoration: InputDecoration(
                      labelText: "Mevcut Şifreniz",
                      suffixIcon: IconButton(
                        icon: Icon(
                          isCurrentVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setModalState(
                          () => isCurrentVisible = !isCurrentVisible,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newController,
                    obscureText: !isNewVisible,
                    decoration: InputDecoration(
                      labelText: "Yeni Şifreniz",
                      suffixIcon: IconButton(
                        icon: Icon(
                          isNewVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setModalState(() => isNewVisible = !isNewVisible),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: Theme.of(context).elevatedButtonTheme.style,
                      onPressed: () {
                        if (currentController ==
                            Provider.of<Profilmodel>(
                              context,
                              listen: false,
                            ).currentuser['sifre']) {
                          Provider.of<Profilmodel>(
                            context,
                            listen: false,
                          ).currentuser['sifre'] = newController.text;

                          Provider.of<Profilmodel>(
                            context,
                            listen: false,
                          ).guncelle();
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Theme.of(
                                context,
                              ).scaffoldBackgroundColor,
                              content: Text(
                                "basarili",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Theme.of(
                                context,
                              ).scaffoldBackgroundColor,
                              content: Text(
                                "mevcut sifreniz hatali,tekrar deneyiniz",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        "Değiştir",
                        style: Theme.of(
                          context,
                        ).elevatedButtonTheme.style?.textStyle?.resolve({}),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showBelgeSecimPopup(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Profil Resmi Secimi",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Divider(
              height: 32,
              thickness: 1,
              color: Theme.of(context).primaryColor, // Gri çizgi rengi
            ),

            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.download_outlined, color: Colors.blue),
              title: Text(
                "Galeriden Yükle",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                context.pop();
                _resimSecVeYukle(context);
                // Buraya galeri seçimi fonksiyonu eklenecek
              },
            ),
            Divider(
              height: 60,
              thickness: 1,
              color: Theme.of(context).primaryColor, // Gri çizgi rengi
            ),

            const SizedBox(height: 80),
          ],
        );
      },
    );
  }
}
