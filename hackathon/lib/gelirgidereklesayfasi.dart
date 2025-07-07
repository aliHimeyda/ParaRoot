import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/firebaseServices.dart';
import 'package:hackathon/loader.dart';
import 'package:hackathon/main.dart';
import 'package:hackathon/profilmodel.dart';
import 'package:hackathon/router.dart';
import 'package:hackathon/veriprovider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GelirGiderEkleSayfasi extends StatefulWidget {
  const GelirGiderEkleSayfasi({super.key});

  @override
  State<GelirGiderEkleSayfasi> createState() => _GelirGiderEkleSayfasiState();
}

class _GelirGiderEkleSayfasiState extends State<GelirGiderEkleSayfasi> {
  String? resimURL;
  bool isGelir = true;
  DateTime selectedDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _turController = TextEditingController();
  final TextEditingController _resimController = TextEditingController();
  final TextEditingController _baslikController = TextEditingController();
  final TextEditingController _degerController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd.MM.yyyy').format(selectedDate);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor, // Seçili gün rengi
              onPrimary: Colors.white, // Seçili gün üzerindeki yazı
              onSurface: Theme.of(
                context,
              ).primaryColor, // Takvim üzerindeki yazı rengi
              surface: Theme.of(
                context,
              ).scaffoldBackgroundColor, // 🟡 İŞTE BU: Arka plan rengini burada ayarla
            ),
            textTheme: Theme.of(context).textTheme,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            title: Text(
              "Gelir / Gider Ekle",
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ÜST SEÇİM BUTONLARI
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          isGelir = true;
                          _turController.text = '';
                        }),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isGelir ? Colors.green : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Gelir',
                            style: TextStyle(
                              color: isGelir
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          isGelir = false;
                          _turController.text = '';
                        }),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !isGelir ? Colors.red : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Gider',
                            style: TextStyle(
                              color: !isGelir
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              //baslik
              _customField(
                hint: 'başlık',
                controller: _baslikController,
                isDropdown: true,
              ),
              const SizedBox(height: 12),

              // Tür
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'diger') {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _turController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _turController.text;
                                    });
                                  },
                                  child: Text(
                                    'Tamam',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    _turController.text = value;
                    setState(() {
                      _turController.text;
                    });
                  }
                },
                itemBuilder: isGelir
                    ? (context) => [
                        PopupMenuItem(value: 'maas', child: Text('Maas')),
                        PopupMenuItem(value: 'burs', child: Text('Burs')),
                        PopupMenuItem(
                          value: 'yangelir',
                          child: Text('Yan Gelir'),
                        ),
                        PopupMenuItem(value: 'diger', child: Text('Diğer')),
                      ]
                    : (context) => [
                        PopupMenuItem(value: 'kiralar', child: Text('Kiralar')),
                        PopupMenuItem(
                          value: 'faturalar',
                          child: Text('Faturalar'),
                        ),
                        PopupMenuItem(value: 'yemek', child: Text('Yemek')),
                        PopupMenuItem(value: 'Yatirim', child: Text('Yatirim')),
                        PopupMenuItem(value: 'diger', child: Text('Diğer')),
                      ],
                child: Container(
                  width: MediaQuery.of(context).size.width - 20,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Theme.of(context).primaryColor,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _turController.text == ''
                              ? isGelir
                                    ? "Gelir Türü"
                                    : "Gider Türü"
                              : _turController.text,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Icon(
                          Icons.arrow_circle_down,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tarih
              _customField(
                hint: isGelir ? "Gelir Tarihi" : "Gider Tarihi",
                controller: _dateController,
                icon: Icons.calendar_month_outlined,
                onTap: _selectDate,
              ),
              const SizedBox(height: 12),

              // Değer
              _customField(
                hint: isGelir ? "Gelir Değeri (TL)" : "Gider Değeri (TL)",
                controller: _degerController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Belge butonları
              Row(
                children: [
                  Expanded(
                    child: _customField(
                      hint: isGelir ? "Belge" : "Fiş / Fatura",
                      controller: _resimController,
                      enabled: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => showBelgeSecimPopup(context),
                    icon: const Icon(Icons.camera_alt_outlined),
                  ),
                  IconButton(
                    onPressed: () => showBelgeSecimPopup(context),
                    icon: const Icon(Icons.upload_file_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              resimURL != null
                  ? Container(
                      width: MediaQuery.of(context).size.width - 100,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      child: Image.network(resimURL!),
                    )
                  : (context.watch<Profilmodel>().kamerailecekilenresimlinki ==
                            null ||
                        context
                                .watch<Profilmodel>()
                                .kamerailecekilenresimlinki ==
                            '')
                  ? SizedBox()
                  : Container(
                      width: MediaQuery.of(context).size.width - 100,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      child: Image.network(
                        context
                            .watch<Profilmodel>()
                            .kamerailecekilenresimlinki!,
                      ),
                    ),
              SizedBox(height: 7),

              // Açıklama
              TextField(
                controller: _aciklamaController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Açıklama",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Alt Butonlar
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Provider.of<Profilmodel>(
                          context,
                          listen: false,
                        ).kamerailecekilenresimlinki = '';
                        context.pop();
                      },
                      child: Text(
                        "Vazgeç",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        _veriEkle(context);
                      },
                      style: Theme.of(context).elevatedButtonTheme.style,
                      child: Text(
                        "Ekle",
                        style: Theme.of(
                          context,
                        ).elevatedButtonTheme.style?.textStyle?.resolve({}),
                      ),
                    ),
                  ),
                ],
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

  Widget _customField({
    required String hint,
    TextEditingController? controller,
    IconData? icon,
    VoidCallback? onTap,
    bool isDropdown = false,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        absorbing: onTap != null,
        child: TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: icon != null ? Icon(icon) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ),
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
            Text("Fiş / Fatura", style: Theme.of(context).textTheme.titleLarge),
            Divider(
              height: 32,
              thickness: 1,
              color: Theme.of(context).primaryColor, // Gri çizgi rengi
            ),

            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: Colors.orange,
              ),
              title: Text(
                "Fotoğraf Çek",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                resimURL = null;
                context.pop();
                context.push(Paths.kameracekimsayfasi);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined, color: Colors.blue),
              title: Text(
                "Galeriden Yükle",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                context.pop();
                _resimSecVeYukle();
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

  Future<void> _veriEkle(BuildContext context) async {
    getIt<Loader>().loading = true;
    getIt<Loader>().change();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final veri = {
      'ID': uid,
      'gelirturu': _turController.text,
      'baslik': _baslikController.text,
      'tarih': Timestamp.fromDate(selectedDate),
      'deger': int.tryParse(_degerController.text) ?? 0.0,
      'aciklama': _aciklamaController.text,
      'gidermi': isGelir ? false : true,
      'imageUrl':
          resimURL ??
          '', //_resimController.text, hata verdigi icin simdilik devre disi
    };
    await addveri(veri);
    Provider.of<Veriprovider>(context, listen: false).addveri(veri);
    getIt<Loader>().loading = false;
    getIt<Loader>().change();
    context.pop();
  }

  void _resimSecVeYukle() async {
    resimURL = await resimYukleVeLinkAl();
    if (resimURL != null) {
      _resimController.text = resimURL!;
      setState(() {
        resimURL;
      });
      print("Resim başarıyla yüklendi: $resimURL");
      // Bu URL'yi Image.network(resimURL) ile kullanabilirsin
    } else {
      print("Resim yüklenemedi.");
    }
  }
}
