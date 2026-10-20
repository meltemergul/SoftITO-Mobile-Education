import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/workout_controller.dart';
import '../models/workout_model.dart';

class QuickWorkoutPresets extends StatelessWidget {
  final WorkoutController controller;
  final void Function(WorkoutItem item)? onWorkoutAdded;

  const QuickWorkoutPresets({
    super.key,
    required this.controller,
    this.onWorkoutAdded,
  });

  static const List<_PresetWorkout> _presets = [
    _PresetWorkout(
      title: 'Kardiyo',
      category: 'Kardiyo',
      durationMinutes: 30,
      caloriesBurned: 240,
      icon: Icons.directions_run,
      color: AppColors.neonEnergy,
    ),
    _PresetWorkout(
      title: 'Ağırlık',
      category: 'Fitness',
      durationMinutes: 45,
      caloriesBurned: 320,
      icon: Icons.fitness_center,
      color: AppColors.neonPurple,
    ),
    _PresetWorkout(
      title: 'HIIT',
      category: 'Yoğun',
      durationMinutes: 20,
      caloriesBurned: 220,
      icon: Icons.bolt,
      color: AppColors.neonCalorie,
    ),
    _PresetWorkout(
      title: 'Bisiklet',
      category: 'Kardiyo',
      durationMinutes: 35,
      caloriesBurned: 260,
      icon: Icons.directions_bike,
      color: AppColors.neonWater,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hızlı Egzersiz Ekle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _PresetsGrid(
          presets: _presets,
          onTap: (preset) {
            final item = controller.addWorkout(
              title: preset.title,
              category: preset.category,
              durationMinutes: preset.durationMinutes,
              caloriesBurned: preset.caloriesBurned,
            );
            if (item != null && onWorkoutAdded != null) {
              onWorkoutAdded!(item);
            }
          },
        ),
      ],
    );
  }
}

class _PresetsGrid extends StatelessWidget {
  final List<_PresetWorkout> presets;
  final void Function(_PresetWorkout preset) onTap;

  const _PresetsGrid({required this.presets, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final item = presets[index];
        return _PresetTile(preset: item, onTap: () => onTap(item));
      },
    );
  }
}

class _PresetWorkout {
  final String title;
  final String category;
  final int durationMinutes;
  final int caloriesBurned;
  final IconData icon;
  final Color color;

  const _PresetWorkout({
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.icon,
    required this.color,
  });
}

class _PresetTile extends StatelessWidget {
  final _PresetWorkout preset;
  final VoidCallback onTap;

  const _PresetTile({required this.preset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: preset.color.withValues(alpha: 0.15),
              child: Icon(preset.icon, color: preset.color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(child: _PresetTileText(preset: preset)),
          ],
        ),
      ),
    );
  }
}

class _PresetTileText extends StatelessWidget {
  final _PresetWorkout preset;

  const _PresetTileText({required this.preset});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          preset.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          '${preset.durationMinutes} dk • ${preset.caloriesBurned} kcal',
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
