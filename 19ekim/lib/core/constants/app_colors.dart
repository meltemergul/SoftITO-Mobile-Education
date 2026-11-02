// Flutter'ın temel Material kütüphanesini Color sınıfını kullanabilmek için import ettim.
import 'package:flutter/material.dart';

/// Dark Obsidian & Neon Gece Spor Salonu Renk Paleti
// Bu sınıfı 'abstract final' yaptım çünkü:
// 1) Sadece renk sabitlerini bir arada tutan bir 'namespace' (depo) olsun istiyorum.
// 2) Yanlışlıkla `AppColors()` diyerek nesne (instance) üretilmesini engelliyorum.
// 3) Başka bir sınıfın bunu miras (extend) almasına gerek yok.
abstract final class AppColors {
  // Neden 'static const'?
  // - 'static': Sınıftan nesne üretmeden doğrudan `AppColors.background` şeklinde erişebilmek için.
  // - 'const': Derleme anında (compile-time) sabitlendiği için her seferinde bellekte yeni nesne üretilmez, performans kazandırır.
  // Color(0xFF...): Baştaki 0xFF alfa (opaklık) değeridir (FF = %100 opak). Kalan 6 karakter ise hex renk kodudur.

  // --- Arka plan ve yüzey renkleri (Dark Obsidian Paleti) ---
  // Ekranın en arkasındaki koyu zemin rengi
  static const Color background = Color(0xFF090D14);
  // Kartlar ve paneller için bir tık daha açık yüzey rengi
  static const Color surface = Color(0xFF131924);
  // Modal, alert veya öne çıkan kartlar için daha belirgin yüzey
  static const Color surfaceElevated = Color(0xFF1C2536);
  // Kartların ve kutuların kenarlık (border) çizgileri için kullandığım renk
  static const Color surfaceBorder = Color(0xFF263248);

  // --- Neon Vurgu Renkleri ---
  // Su takibi sayfamdaki birincil parlak su mavisi (Cyan)
  static const Color neonWater = Color(0xFF00E5FF);       // Canlı Neon Su Mavisi
  // Parlaklık veya geçişlerde kullanabileceğim daha açık su tonu
  static const Color neonWaterLight = Color(0xFF67F6FF);  // Açık Su Parıltısı
  // Egzersiz, aktivite ve enerji göstergeleri için neon yeşil
  static const Color neonEnergy = Color(0xFF00FF88);      // Neon Egzersiz Yeşili
  // Yakılan kalori miktarını vurgulamak için ateş/kalori turuncusu
  static const Color neonCalorie = Color(0xFFFF5E36);     // Neon Kalori Turuncusu
  // Ağırlık / fitness kategorisi için neon mor vurgu
  static const Color neonPurple = Color(0xFFB55FE6);      // Neon Spor Vurgusu

  // --- Metin Renkleri (Tipografi Hiyerarşisi) ---
  // Başlıklar ve ana okunabilir metinler için en parlak açık renk
  static const Color textPrimary = Color(0xFFF8FAFC);
  // Açıklamalar ve alt başlıklar için ikincil gri ton
  static const Color textSecondary = Color(0xFF94A3B8);
  // İpuçları, birimler (örn: ml, kcal) veya pasif durumlar için soluk metin rengi
  static const Color textMuted = Color(0xFF64748B);

  // --- Durum (Feedback) Renkleri ---
  // Hedef tamamlandığında veya başarılı işlemlerde
  static const Color success = Color(0xFF00FF88);
  // Dikkat edilmesi gereken durumlarda
  static const Color warning = Color(0xFFFFB800);
  // Sıfırlama veya silme gibi kritik işlemlerde
  static const Color error = Color(0xFFFF3366);
}

