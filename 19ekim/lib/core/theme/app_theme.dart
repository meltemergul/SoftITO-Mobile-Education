import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// Uygulamanın tüm görsel temasını tek bir merkezde toplamak için bu sınıfı yazdım.
// Böylece MaterialApp içindeki 'theme' özelliğine bunu verip tüm tasarımı tutarlı kılabiliyorum.
// 'abstract final' yaptım çünkü sadece tema sağlayan statik bir yapı, nesne üretilmesine gerek yok.
abstract final class AppTheme {
  // Statik getter ile koyu temayı (ThemeData) döndürüyorum.
  static ThemeData get darkTheme {
    return ThemeData(
      // Material Design 3 standartlarını ve yeni bileşen tasarımlarını kullanmak için true yaptım
      useMaterial3: true,

      // Sisteme uygulamanın koyu modda (Dark) olduğunu bildiriyorum
      brightness: Brightness.dark,

      // Ekranların arka plan rengini Obsidian paletime bağladım
      scaffoldBackgroundColor: AppColors.background,

      // Material 3'ün kalbi ColorScheme'dir. Butonlar, yazılar, yüzeyler bu şemadan beslenir.
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonWater,         // Ana vurgu rengi (örn: butonlar, aktif çizgiler)
        onPrimary: AppColors.background,      // Primary rengin üzerine yazılacak metin rengi
        secondary: AppColors.neonEnergy,      // İkincil vurgu (egzersiz yeşili)
        onSecondary: AppColors.background,
        tertiary: AppColors.neonCalorie,      // Üçüncül vurgu (kalori turuncusu)
        surface: AppColors.surface,           // Kart ve modal yüzey rengi
        onSurface: AppColors.textPrimary,     // Yüzey üzerindeki metin rengi
        error: AppColors.error,               // Hata bildirimleri için renk
        onError: Colors.white,
      ),

      // Üst çubuk (AppBar) stilini uygulama genelinde özelleştirdim
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background, // Arka planla bütünleşsin diye aynı rengi verdim
        elevation: 0,                         // Gölgeyi sıfırlayıp düz ve modern bir görünüm elde ettim
        centerTitle: false,                   // Başlık sola hizalı dursun
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,                // Harf aralığını biraz daraltıp modern bir hava kattım
        ),
        iconTheme: IconThemeData(color: AppColors.neonWater),
      ),

      // Kart bileşenlerinin (Card) varsayılan görünümü
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,                         // Koyu temada gölge yerine kenarlık çizgisi kullanmak daha şık duruyor
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Köşeleri modern ve yumuşak şekilde yuvarladım
          side: const BorderSide(color: AppColors.surfaceBorder, width: 1), // İnce kenarlık
        ),
      ),

      // Alt menü çubuğunun (NavigationBar) stili
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        // Seçilen sekmenin arkasındaki parlama göstergesi (indicator)
        indicatorColor: AppColors.neonWater.withValues(alpha: 0.15),
        
        // Menü butonlarının altındaki yazıların stilini durumuna göre (seçili / seçili değil) belirliyorum
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            // Eğer sekme seçiliyse parlak neon mavi ve daha kalın yazı
            return const TextStyle(
              color: AppColors.neonWater,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          // Seçili değilse soluk gri ton
          return const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),

        // Menü ikonlarının rengini ve boyutunu durumuna göre ayarlıyorum
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            // Seçili olan ikon biraz daha büyük (26px) ve neon su mavisi
            return const IconThemeData(color: AppColors.neonWater, size: 26);
          }
          // Seçili olmayan ikon 24px ve soluk
          return const IconThemeData(color: AppColors.textMuted, size: 24);
        }),
      ),
    );
  }
}

