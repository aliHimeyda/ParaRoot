import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Savethemeinformation {
  late String modeinformation = 'light';
}

class AppTheme extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  ThemeData themeData = AppTheme.lightMode;
  late bool isdarkmode = false;
  late IconData temaiconu = Icons.light_mode;
  ThemeData get theme => themeData;
  AppTheme() {
    _loadTheme();
  }
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('thmemode') ?? 'system';

    switch (savedTheme) {
      case 'light':
        themeData = AppTheme.lightMode;
        isdarkmode = false;
        break;
      case 'dark':
        themeData = AppTheme.darkMode;
        isdarkmode = true;

        break;
      default:
        themeData = AppTheme.lightMode;
        isdarkmode = false;
    }

    notifyListeners();
  }

  void changetheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (themeData == AppTheme.lightMode) {
      themeData = AppTheme.darkMode;
      isdarkmode = true;
      temaiconu = Icons.dark_mode;
      await prefs.setString('thmemode', 'dark');
      notifyListeners();
    } else {
      themeData = AppTheme.lightMode;
      isdarkmode = false;
      temaiconu = Icons.light_mode;
      await prefs.setString('thmemode', 'light');
      notifyListeners();
    }
  }

  /// **Açık Tema (Light Mode)**
  static final ThemeData lightMode = ThemeData(
    brightness: Brightness.light, // Tema parlaklığını açık mod olarak ayarlar
    primaryColor: const Color(0xFF005C78), // Uygulamanın ana rengini belirler
    secondaryHeaderColor: Color.fromARGB(255, 230, 234, 222), // turuncumsu
    canvasColor: const Color.fromARGB(75, 0, 92, 120),
    scaffoldBackgroundColor: const Color(
      0xFFF3F7EC,
    ), // Sayfanın arka plan rengini belirler

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors
          .yesil, // Uygulama çubuğunun (AppBar) arka plan rengini belirler
      titleTextStyle: const TextStyle(
        color: AppColors.mavi, // AppBar başlık rengini beyaz yapar
        fontSize: 20, // Başlık yazı boyutunu ayarlar
        fontWeight: FontWeight.bold, // Başlık yazısını kalın yapar
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ), // AppBar'daki ikon rengini beyaz yapar
    ),

    iconTheme: IconThemeData(
      color: AppColors
          .sari, // Genel ikon rengini koyu gri yapar (örn: klasör ikonları)
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor:
          AppColors.sari, // FAB (Floating Action Button) rengini kırmızı yapar
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor:
          AppColors.mavi, // Alt navigasyon çubuğunun arka plan rengini belirler
      indicatorColor:
          AppColors.yesil, // Seçili ikonun arka plan rengini belirler

      labelTextStyle: WidgetStateProperty.all(
        TextStyle(
          color: AppColors
              .koyuGri, // Alt navigasyon etiketi (label) rengini koyu gri yapar
          fontSize: 12, // Etiket yazı boyutunu belirler
          fontWeight: FontWeight.bold, // Etiket yazısını kalın yapar
        ),
      ),

      iconTheme: WidgetStateProperty.all(
        IconThemeData(
          color: AppColors.yesil,
        ), // Seçili olmayan ikonların rengini koyu gri yapar
      ),
    ),

    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: Colors.black,
        fontSize: 16,
      ), // Genel metin stilini belirler (büyük)
      bodyMedium: TextStyle(
        color: AppColors.koyuGri,
        fontSize: 12,
      ), // Genel metin stilini belirler (orta)
      titleLarge: TextStyle(
        color: AppColors.mavi, // Başlık yazılarının rengini bordo yapar
        fontSize: 20, // Başlık yazılarının boyutunu belirler
        fontWeight: FontWeight.bold, // Başlık yazılarını kalın yapar
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: TextStyle(color: AppColors.yesil, fontSize: 13),
        backgroundColor: AppColors
            .mavi, // Yükseltilmiş butonların (ElevatedButton) arka plan rengini belirler
        foregroundColor:
            Colors.white, // Buton içindeki yazının rengini beyaz yapar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), // Buton köşelerini yuvarlatır
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        // Varsayılan kenarlık tipi
        borderRadius: BorderRadius.circular(12), // Kenarları yuvarlat
        borderSide: const BorderSide(color: AppColors.mavi), // Kenar rengi
      ),

      enabledBorder: OutlineInputBorder(
        // TextField aktif ama focus değilken
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.mavi), // Gri kenar
      ),

      focusedBorder: OutlineInputBorder(
        // TextField focus (tıklanmış) olduğunda
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.mavi,
          width: 2,
        ), // Kalın mavi kenar
      ),

      labelStyle: const TextStyle(
        color: AppColors.mavi,
      ), // Label (üstteki yazı) rengi
      hintStyle: const TextStyle(
        color: AppColors.mavi,
      ), // Hint (ipucu yazısı) rengi
      iconColor: Colors.blue, // prefixIcon ya da suffixIcon rengi
    ),
  );

  /// **Koyu Tema (Dark Mode)**
  static final ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.sari, // Koyu mavi - Ana Renk
    secondaryHeaderColor: Color.fromARGB(200, 232, 142, 103), // turuncumsu,
    canvasColor: const Color.fromARGB(71, 232, 142, 103),
    scaffoldBackgroundColor: AppColors.siyah, // Siyah arka plan
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.siyah, // Koyu başlık rengi
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    iconTheme: IconThemeData(
      color: AppColors.acikGri, // İkonlar için açık gri
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.sari, // Koyu temada buton bordo
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.siyah, // Arka plan rengi siyah
      indicatorColor: AppColors.sari, // Seçili ikon arkaplanı sarı
      labelTextStyle: WidgetStateProperty.all(
        TextStyle(
          color: AppColors.sari,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: WidgetStateProperty.all(
        IconThemeData(color: AppColors.siyah), // Seçilmemiş ikon gri
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.acikGri, fontSize: 12),
      titleLarge: TextStyle(
        color: AppColors.sari, // Koyu temada vurgu rengi yeşil
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: TextStyle(color: AppColors.siyah, fontSize: 13),
        backgroundColor: AppColors.sari, // Buton kırmızı
        foregroundColor: AppColors.siyah,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        // Varsayılan kenarlık tipi
        borderRadius: BorderRadius.circular(12), // Kenarları yuvarlat
        borderSide: const BorderSide(color: AppColors.sari), // Kenar rengi
      ),

      enabledBorder: OutlineInputBorder(
        // TextField aktif ama focus değilken
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.sari), // Gri kenar
      ),

      focusedBorder: OutlineInputBorder(
        // TextField focus (tıklanmış) olduğunda
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.sari,
          width: 2,
        ), // Kalın mavi kenar
      ),

      labelStyle: const TextStyle(
        color: AppColors.sari,
      ), // Label (üstteki yazı) rengi
      hintStyle: const TextStyle(
        color: AppColors.sari,
      ), // Hint (ipucu yazısı) rengi
      iconColor: AppColors.sari, // prefixIcon ya da suffixIcon rengi
    ),
  );
}

class AppColors {
  static const Color acikmavi = Color.fromARGB(255, 1, 130, 169); // mavi;
  static const Color mavi = Color(0xFF005C78); // mavi;
  static const Color kirmizi = Color(0xFFD6453D); // Kırmızı
  static const Color yesil = Color(0xFFF3F7EC); // açık yeşilimsi beyaz// Yeşil
  static const Color koyuMavi = Color(
    0xFF002B5C,
  ); // Koyu Mavi (Koyu mod ana renk)
  static const Color acikGri = Color(0xFFD1D1D1); // Açık gri
  static const Color koyuGri = Color(0xFF505050); // Koyu gri
  static const Color sari = Color(0xFFE88D67); // turuncumsu; // Sarı
  static const Color koyuBeyaz = Color(
    0xFFF2ECEC,
  ); // Açık Beyaz (Light Mode Arka Plan)
  static const Color siyah = Color(0xFF121212); // Siyah (Dark Mode Arka Plan)
  static const Color bordo = Color(0xFF7A1E1E); // Bordo
  static const Color krem = Color(
    0xFFF4E1C0,
  ); // Krem (Light Mode'da Kart Rengi)
}
