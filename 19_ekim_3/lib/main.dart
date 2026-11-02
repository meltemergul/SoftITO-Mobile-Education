// Flutter'ın Material Design bileşenlerini kullanabilmek için gerekli kütüphaneyi içe aktarıyorum.
import 'package:flutter/material.dart';

// Uygulamanın açık ve koyu tema tasarımlarını içeren dosyayı içe aktarıyorum.
import 'core/theme/app_theme.dart';

// Tema değişimini yöneten controller'ı içe aktarıyorum.
import 'core/theme/theme_controller.dart';

// Su takibi modülünün controller ve ekran dosyalarını içe aktarıyorum.
import 'features/water_tracker/controllers/water_tracker_controller.dart';
import 'features/water_tracker/view/water_tracker_view.dart';

// Egzersiz modülünün controller ve ekran dosyalarını içe aktarıyorum.
import 'features/workout/controllers/workout_controller.dart';
import 'features/workout/view/workout_view.dart';

// Uygulamanın çalışmaya başladığı ana giriş fonksiyonu.
void main() {
  // Flutter widget sisteminin uygulama başlamadan önce hazır olmasını sağlıyorum.
  WidgetsFlutterBinding.ensureInitialized();

  // Uygulamayı SusadimApp widget'ı üzerinden başlatıyorum.
  runApp(const SusadimApp());
}

/// Susadım uygulamasının kök widget'ı.
/// Açık ve koyu tema ayarlarını uygulamanın tamamına uygular.
class SusadimApp extends StatelessWidget {
  const SusadimApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema değişikliklerini dinleyerek arayüzün otomatik güncellenmesini sağlıyorum.
    return ValueListenableBuilder<ThemeMode>(
      // Tema controller'ındaki değişiklikleri dinliyorum.
      valueListenable: ThemeController.instance.themeModeNotifier,

      // Tema değiştiğinde yeni themeMode değeriyle MaterialApp'i yeniden oluşturuyorum.
      builder: (context, themeMode, _) {
        return MaterialApp(
          // Uygulamanın adını belirliyorum.
          title: 'susadım',

          // Sağ üst köşedeki debug yazısını gizliyorum.
          debugShowCheckedModeBanner: false,

          // Uygulamanın açık tema tasarımını belirliyorum.
          theme: AppTheme.lightTheme,

          // Uygulamanın koyu tema tasarımını belirliyorum.
          darkTheme: AppTheme.darkTheme,

          // Kullanıcının seçtiği tema modunu uyguluyorum.
          themeMode: themeMode,

          // Uygulama açıldığında gösterilecek ilk ekranı belirliyorum.
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}

/// Su takibi ve egzersiz modülleri arasında geçiş yapmamı sağlayan ana navigasyon ekranı.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Alt navigasyonda başlangıçta seçili olacak ekranın indeksini tutuyorum.
  int _currentIndex = 0;

  // Uygulamada kullanılacak ekranları bir liste içerisinde tutuyorum.
  // Controller'ları instance üzerinden aldığım için ilgili modüllerin ortak
  // controller nesneleriyle çalışmasını sağlıyorum.
  final List<Widget> _screens = [
    WaterTrackerView(controller: WaterTrackerController.instance),
    WorkoutView(controller: WorkoutController.instance),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ekranları ve tema değiştirme butonunu üst üste yerleştiriyorum.
      body: Stack(
        children: [
          // Yalnızca seçili ekranı görünür yapıyorum.
          // Diğer ekranların durumlarını koruyarak sekmeler arası geçiş sağlıyorum.
          IndexedStack(index: _currentIndex, children: _screens),

          // Tema değiştirme butonunu ekranın sağ üst tarafına konumlandırıyorum.
          const Positioned(top: 48, right: 56, child: _ThemeToggleButton()),
        ],
      ),

      // Ekranın alt kısmına sekmeli navigasyon menüsü ekliyorum.
      bottomNavigationBar: NavigationBar(
        // Hangi sekmenin seçili olduğunu belirliyorum.
        selectedIndex: _currentIndex,

        // Kullanıcı farklı bir sekmeye dokunduğunda seçili indeksi güncelliyorum.
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        // Alt navigasyonda göstereceğim sekmeleri tanımlıyorum.
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop_rounded),
            label: 'Su Takibi',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center_rounded),
            label: 'Egzersiz',
          ),
        ],
      ),
    );
  }
}

/// Uygulamanın açık ve koyu temaları arasında geçiş yapmamı sağlayan buton.
class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Tema modundaki değişiklikleri dinliyorum.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.themeModeNotifier,

      builder: (context, themeMode, _) {
        // Mevcut tema koyu moddaysa true, değilse false döndürür.
        final isDark = themeMode == ThemeMode.dark;

        // Mevcut temaya göre ikon ve açıklamayı değiştiriyorum.
        return IconButton.filledTonal(
          tooltip: isDark ? 'Aydınlık Moda Geç' : 'Karanlık Moda Geç',

          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          ),

          // Butona basıldığında tema controller'ındaki geçiş fonksiyonunu çağırıyorum.
          onPressed: ThemeController.instance.toggleTheme,
        );
      },
    );
  }
}
