import 'package:flutter/material.dart';
// Flutter'ın Material Design bileşenlerini kullanabilmek için gerekli kütüphaneyi içe aktarıyorum.

// Uygulama açıldığında gösterilecek ana ekranı içe aktarıyorum.
import 'screens/dashboard_screen.dart';

// Dart uygulamasının çalışmaya başladığı giriş noktasıdır.
void main() {
  // Flutter uygulamasını başlatıyorum.
  // runApp() içerisine uygulamanın en üst seviye widget'ını veriyorum.
  runApp(const BudgetlyApp());
}

// Uygulamanın genel ayarlarını ve temasını yöneten ana widget'ı oluşturuyorum.
class BudgetlyApp extends StatelessWidget {
  // BudgetlyApp widget'ının constructor'ı.
  // super.key ile widget'ın key bilgisini üst sınıfa iletiyorum.
  const BudgetlyApp({super.key});

  // Uygulamanın arayüzünü oluşturuyorum.
  @override
  Widget build(BuildContext context) {
    // MaterialApp, uygulamanın genel yapılandırmasını sağlar.
    return MaterialApp(
      // Sağ üst köşede görünen DEBUG yazılı bandı kaldırıyorum.
      debugShowCheckedModeBanner: false,

      // Uygulamanın adını belirliyorum.
      title: 'Budgetly',

      // Uygulamanın genel tasarım ve renk ayarlarını belirliyorum.
      theme: ThemeData(
        // Material Design 3 tasarım sistemini etkinleştiriyorum.
        useMaterial3: true,

        // Scaffold kullanan ekranların varsayılan arka plan rengini belirliyorum.
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),

        // Uygulamanın genel renk paletini oluşturuyorum.
        // Seed color, diğer renklerin türetilmesinde temel olarak kullanılıyor.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),

        // Uygulamadaki AppBar bileşenlerinin varsayılan görünümünü ayarlıyorum.
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
        ),

        // TextFormField ve TextField gibi giriş alanlarının
        // varsayılan kenarlık görünümünü belirliyorum.
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      // Uygulama ilk açıldığında gösterilecek ekranı belirliyorum.
      home: const DashboardScreen(),
    );
  }
}
