import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/water_tracker/controllers/water_tracker_controller.dart';
import 'features/water_tracker/view/water_tracker_view.dart';
import 'features/workout/controllers/workout_controller.dart';
import 'features/workout/view/workout_view.dart';

void main() {
  runApp(const SusadimApp());
}

/// Uygulama kök bileşeni: Karanlık ve Aydınlık tema desteğini ValueNotifier ile yönetir.
class SusadimApp extends StatefulWidget {
  const SusadimApp({super.key});

  @override
  State<SusadimApp> createState() => _SusadimAppState();
}

class _SusadimAppState extends State<SusadimApp> {
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = ThemeController(initialMode: ThemeMode.dark);
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeController.themeMode,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'susadım v1',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: MainNavigationWrapper(themeController: _themeController),
        );
      },
    );
  }
}

/// Ana alt gezinme çubuğu ve kontrolcü entegrasyon sarmalayıcısı.
class MainNavigationWrapper extends StatefulWidget {
  final ThemeController themeController;

  const MainNavigationWrapper({
    super.key,
    required this.themeController,
  });

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  late final WaterTrackerController _waterController;
  late final WorkoutController _workoutController;

  @override
  void initState() {
    super.initState();
    _waterController = WaterTrackerController();
    _workoutController = WorkoutController(
      onWorkoutAdded: (extraWater, workoutTitle) {
        _waterController.addWorkoutHydrationNeed(extraWater, workoutTitle);
      },
    );
  }

  @override
  void dispose() {
    _waterController.dispose();
    _workoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      WaterTrackerView(
        controller: _waterController,
        themeController: widget.themeController,
      ),
      WorkoutView(controller: _workoutController),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop_outlined),
            activeIcon: Icon(Icons.water_drop_rounded),
            label: 'Su Takibi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center_rounded),
            label: 'Egzersiz',
          ),
        ],
      ),
    );
  }
}
