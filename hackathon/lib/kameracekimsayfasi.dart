import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/firebaseServices.dart';
import 'package:hackathon/loader.dart';
import 'package:hackathon/main.dart';
import 'package:hackathon/profilmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class KameraCekimSayfasi extends StatefulWidget {
  const KameraCekimSayfasi({super.key});

  @override
  State<KameraCekimSayfasi> createState() => _KameraCekimSayfasiState();
}

class _KameraCekimSayfasiState extends State<KameraCekimSayfasi> {
  final TextEditingController _resimYoluController = TextEditingController();
  late String? resimURL = null;
  CameraController? _cameraController;
  bool _isFlashOn = false;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await Permission.camera.request();
    _cameras = await availableCameras();

    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    if (_cameraController != null) {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    }
  }

  Future<void> _capturePhoto(context) async {
    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final XFile photo = await _cameraController!.takePicture();
        debugPrint("Çekilen fotoğraf: ${photo.path}");
        showDialog(
          context: context,
          builder:
              (BuildContext dialogContext) => AlertDialog(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                title: Text(
                  "Çekilen Fotoğraf",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                content: Image.file(File(photo.path), fit: BoxFit.cover),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: Text(
                      "Kapat",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      final cekilenresimlinki = await cekilenresmiYukleVeLinkAl(
                        photo.path,
                      );
                      if (cekilenresimlinki != null) {
                        getItprofil<Profilmodel>().kamerailecekilenresimlinki =
                            cekilenresimlinki;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            content: Text(
                              "basarili",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        );
                        getItprofil<Profilmodel>().guncelle();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            content: Text(
                              "hata olustu",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      "Kaydet",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
        );
      } else {
        debugPrint("Kamera başlatılmamış.");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Kamera hazır değil.")));
      }
    } catch (e) {
      debugPrint("Fotoğraf çekme hatası: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fotoğraf çekilemedi")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(
              "Kamera",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            centerTitle: true,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body:
              _cameraController == null ||
                      !_cameraController!.value.isInitialized
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      // Kamera Görüntüsü
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CameraPreview(_cameraController!),
                            Container(
                              width: 250,
                              height: 330,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.orange,
                                  width: 2,
                                ),
                              ),
                            ),
                            const Positioned(
                              bottom: 60,
                              child: Text(
                                "Fişinizi Gösterin",
                                style: TextStyle(
                                  backgroundColor: Colors.black54,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Alt Menü
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: _toggleFlash,
                              icon: Icon(
                                _isFlashOn
                                    ? Icons.flash_on
                                    : Icons.flash_off_outlined,
                                color: Theme.of(context).primaryColor,
                                size: 28,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _capturePhoto(context);
                              },
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                context.pop();
                                _resimSecVeYukle(context);
                              },
                              icon: Icon(
                                Icons.photo_library_outlined,
                                color: Theme.of(context).primaryColor,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
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

  void _resimSecVeYukle(BuildContext context) async {
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
}
