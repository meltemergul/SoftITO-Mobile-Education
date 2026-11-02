import 'package:flutter/material.dart';

// Harici bir state management paketi kullanmadan Flutter'ın kendi ValueNotifier
// yapısıyla uygulamanın tema durumunu yönetiyorum.
class ThemeController {
  // Private constructor kullanarak sınıfın dışarıdan new ile oluşturulmasını engelliyorum.
  ThemeController._();

  // Singleton Pattern kullanarak uygulama genelinde tek bir ThemeController
  // nesnesi oluşturulmasını sağlıyorum.
  static final ThemeController instance = ThemeController._();

  // Uygulamanın aktif tema modunu tutuyorum.
  // Başlangıçta koyu temayı varsayılan olarak belirliyorum.
  // ValueNotifier sayesinde değer değiştiğinde dinleyicilere haber veriliyor.
  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(
    ThemeMode.dark,
  );

  // Aktif tema koyu moddaysa true, değilse false döndüren getter.
  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  // Açık ve koyu tema arasında geçiş yapılmasını sağlıyorum.
  void toggleTheme() {
    // Mevcut tema koyu moddaysa açık moda geçiyorum.
    if (themeModeNotifier.value == ThemeMode.dark) {
      themeModeNotifier.value = ThemeMode.light;
    } else {
      // Mevcut tema koyu değilse koyu moda geçiyorum.
      themeModeNotifier.value = ThemeMode.dark;
    }
  }

  // Dışarıdan gönderilen tema modunu doğrudan uyguluyorum.
  // Böylece sadece geçiş yapmak yerine belirli bir tema da seçilebiliyor.
  void setTheme(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }
}
