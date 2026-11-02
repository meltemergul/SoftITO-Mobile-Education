import 'package:flutter/material.dart';

// Dart'ın 'extension' özelliğini kullanarak BuildContext sınıfını genişlettim.
// Neden böyle yaptım?
// Normalde temaya veya ekran ölçülerine ulaşmak için her seferinde:
// `Theme.of(context).colorScheme` veya `MediaQuery.of(context).size.width` gibi uzun uzun kodlar yazmam gerekiyordu.
// Bu extension sayesinde artık widget'larımın içinde sadece `context.theme` veya `context.screenWidth` yazarak
// çok daha temiz ve okunabilir bir kod elde edebiliyorum.
extension ContextExtensions on BuildContext {
  // Aktif temanın ThemeData nesnesine hızlıca ulaşmak için
  ThemeData get theme => Theme.of(this);

  // Temadaki yazı stillerine (TextTheme) doğrudan erişim için
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Temanın renk paletine (ColorScheme) erişim için
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Ekran boyutuna (Size) erişim için.
  // Not: Flutter 3.10+ ile gelen 'MediaQuery.sizeOf(this)' metodunu tercih ettim,
  // çünkü eski 'MediaQuery.of(this).size' kullanımına göre sadece ekran boyutu değiştiğinde
  // widget'ı rebuild eder, klavye açılma/kapanma gibi durumlarda gereksiz rebuild'i önler.
  Size get screenSize => MediaQuery.sizeOf(this);

  // Ekranın genişliğini (width) double cinsinden almak için
  double get screenWidth => screenSize.width;

  // Ekranın yüksekliğini (height) double cinsinden almak için
  double get screenHeight => screenSize.height;
}

