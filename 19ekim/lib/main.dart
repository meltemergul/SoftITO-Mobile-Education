import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/water_tracker/controller/water_tracker_controller.dart';
import 'features/water_tracker/view/water_tracker_view.dart';
import 'features/workout/controller/workout_controller.dart';
import 'features/workout/view/workout_view.dart';

// Dart & Flutter uygulamalarının başlangıç / giriş noktası (entry point) burasıdır.
// 'runApp' fonksiyonu ile widget ağacının en köküne 'SusadimApp' widget'ımı yerleştiriyorum.
void main() {
  runApp(const SusadimApp());
}

// Uygulamamın temel MaterialApp yapılandırmasını tutan kök widget.
class SusadimApp extends StatelessWidget {
  const SusadimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'susadım',
      debugShowCheckedModeBanner: false, // Sağ üst köşedeki kırmızı "DEBUG" şeridini kaldırıp temiz bir görüntü elde ettim
      theme: AppTheme.darkTheme,          // core/theme/app_theme.dart içinde tanımladığım Obsidian & Neon temasını bağladım
      home: const MainShell(),            // Uygulamanın ana kabuğu (iskeleti)
    );
  }
}

// Uygulamanın ana kabuğu (MainShell):
// Neden StatefulWidget yaptım?
// Controller'ların yaşam döngüsünü (Lifecycle) yönetmek için!
// Uygulama açık olduğu sürece controller'ların hayatta kalması ve uygulama kapandığında
// dispose edilerek bellek sızıntısının (memory leak) önlenmesi gerekiyor.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Su takibi ve Egzersiz durumlarını yönetecek iki ana controller örneği oluşturdum:
  final WaterTrackerController _waterController = WaterTrackerController();
  final WorkoutController _workoutController = WorkoutController();

  // Aktif sekmenin (0: Su Takibi, 1: Egzersiz) indeksini tutan ValueNotifier.
  // Neden ValueNotifier? Tüm ekranı setState ile yeniden çizdirmek yerine sadece ilgili kısmı güncellemek için.
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    // Egzersiz modülünde her yeni spor yapıldığında veya silindiğinde
    // 'addListener' ile su takibi modülüne otomatik haber veriyorum!
    _workoutController.addListener(_syncWorkoutHydration);
  }

  // Egzersizlerden hesaplanan toplam ek su ihtiyacını su controller'ına aktaran köprü fonksiyonum
  void _syncWorkoutHydration() {
    _waterController.setExtraWorkoutWater(
      _workoutController.totalRecommendedWaterMl,
    );
  }

  @override
  void dispose() {
    // Bellek sızıntılarını (memory leaks) önlemek için:
    // Dinleyiciyi kaldırıyorum ve tüm controller'ları yok ediyorum (dispose).
    _workoutController.removeListener(_syncWorkoutHydration);
    _waterController.dispose();
    _workoutController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder: _currentIndex değiştiğinde sadece bu Scaffold bloğunu günceller
    return ValueListenableBuilder<int>(
      valueListenable: _currentIndex,
      builder: (context, index, _) {
        return Scaffold(
          // Aktif sekmeye göre başlığı değişen üst çubuk
          appBar: _buildAppBar(index),

          // IndexedStack : Normalde sekmeler arası geçişte sayfalar yeniden inşa edilir ve scroll pozisyonu sıfırlanır.
          // IndexedStack ise çocuk widget'ları bellekte canlı tutar; sadece görünür olanı ekrana basar.
          // Böylece kullanıcı sekmeler arasında gezinirken sayfadaki durumlar asla kaybolmaz!
          body: IndexedStack(
            index: index,
            children: [
              WaterTrackerView(controller: _waterController),
              WorkoutView(
                controller: _workoutController,
                // Egzersiz tamamlandı uyarısındaki "İçtim" butonuna basıldığında su eklenmesini sağlıyorum
                onQuickWaterAdd: (amount) => _waterController.addWater(amount),
              ),
            ],
          ),

          // Alt menü çubuğu
          bottomNavigationBar: _buildBottomNav(index),
        );
      },
    );
  }

  // Üst çubuk (AppBar) tasarımı: Sekmeye göre dinamik başlık ve sağda app icon
  PreferredSizeWidget _buildAppBar(int index) {
    final title = index == 0 ? '💧 Su Takibi' : '⚡ Egzersiz & Kalori';
    return AppBar(
      title: Text(title),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/icons/app_icon.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  // Material 3 standartlarında alt gezinme çubuğu (NavigationBar)
  Widget _buildBottomNav(int index) {
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (val) => _currentIndex.value = val, // Tıklanan sekme indeksini günceller
      destinations: const [
        // 1. Sekme: Su Takibi
        NavigationDestination(
          icon: Icon(Icons.water_drop_outlined),
          selectedIcon: Icon(Icons.water_drop),
          label: 'Su Takibi',
        ),
        // 2. Sekme: Egzersiz
        NavigationDestination(
          icon: Icon(Icons.fitness_center_outlined),
          selectedIcon: Icon(Icons.fitness_center),
          label: 'Egzersiz',
        ),
      ],
    );
  }
}

