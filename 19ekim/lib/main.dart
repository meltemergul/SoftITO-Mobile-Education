import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/water_tracker/controller/water_tracker_controller.dart';
import 'features/water_tracker/view/water_tracker_view.dart';
import 'features/workout/controller/workout_controller.dart';
import 'features/workout/view/workout_view.dart';

void main() {
  runApp(const SusadimApp());
}

class SusadimApp extends StatelessWidget {
  const SusadimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'susadım',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final WaterTrackerController _waterController = WaterTrackerController();
  final WorkoutController _workoutController = WorkoutController();
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _workoutController.addListener(_syncWorkoutHydration);
  }

  void _syncWorkoutHydration() {
    _waterController.setExtraWorkoutWater(
      _workoutController.totalRecommendedWaterMl,
    );
  }

  @override
  void dispose() {
    _workoutController.removeListener(_syncWorkoutHydration);
    _waterController.dispose();
    _workoutController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _currentIndex,
      builder: (context, index, _) {
        return Scaffold(
          appBar: _buildAppBar(index),
          body: IndexedStack(
            index: index,
            children: [
              WaterTrackerView(controller: _waterController),
              WorkoutView(
                controller: _workoutController,
                onQuickWaterAdd: (amount) => _waterController.addWater(amount),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(index),
        );
      },
    );
  }

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

  Widget _buildBottomNav(int index) {
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (val) => _currentIndex.value = val,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.water_drop_outlined),
          selectedIcon: Icon(Icons.water_drop),
          label: 'Su Takibi',
        ),
        NavigationDestination(
          icon: Icon(Icons.fitness_center_outlined),
          selectedIcon: Icon(Icons.fitness_center),
          label: 'Egzersiz',
        ),
      ],
    );
  }
}
