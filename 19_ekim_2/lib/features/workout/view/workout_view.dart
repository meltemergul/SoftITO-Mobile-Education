import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/workout_controller.dart';
import '../models/workout_model.dart';
import '../widgets/add_workout_dialog.dart';
import '../widgets/workout_card.dart';

/// Egzersiz takip ana ekranı (Clean UI & StatelessWidget).
class WorkoutView extends StatelessWidget {
  final WorkoutController controller;

  const WorkoutView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Egzersiz ve Kalori'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsOverview(context),
            const SizedBox(height: 24),
            _buildWorkoutListHeader(context),
            const SizedBox(height: 12),
            _buildWorkoutList(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Egzersiz Ekle'),
      ),
    );
  }

  void _openAddSheet(BuildContext context) {
    AddWorkoutSheet.show(
      context,
      onSave: ({
        required String title,
        required WorkoutType type,
        required int durationMinutes,
      }) {
        controller.addWorkout(
          title: title,
          type: type,
          durationMinutes: durationMinutes,
        );
      },
    );
  }

  Widget _buildStatsOverview(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder;
    final primaryColor = isDark ? AppColors.neonCyan : AppColors.lightPrimary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context: context,
            label: 'Toplam Süre',
            notifier: controller.totalMinutes,
            suffix: ' dk',
            icon: Icons.timer_outlined,
            color: primaryColor,
          ),
          Container(width: 1, height: 36, color: borderColor),
          _buildStatItem(
            context: context,
            label: 'Yakılan Kalori',
            notifier: controller.totalCalories,
            suffix: ' kcal',
            icon: Icons.local_fire_department_rounded,
            color: AppColors.neonOrange,
          ),
          Container(width: 1, height: 36, color: borderColor),
          _buildStatItem(
            context: context,
            label: 'Ek Su İhtiyacı',
            notifier: controller.totalExtraWater,
            suffix: ' ml',
            icon: Icons.water_drop_rounded,
            color: AppColors.neonBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required ValueNotifier<int> notifier,
    required String suffix,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (context, value, _) {
        return Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              '$value$suffix',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: subTextColor),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWorkoutListHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Text(
      'Yapılan Antrenmanlar',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );
  }

  Widget _buildWorkoutList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return ValueListenableBuilder<List<WorkoutModel>>(
      valueListenable: controller.workouts,
      builder: (context, list, _) {
        if (list.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              'Henüz egzersiz kaydı eklenmedi.\nSağ alttaki butondan antrenman ekleyebilirsin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: mutedColor,
                height: 1.5,
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final workout = list[index];
            return WorkoutCard(
              workout: workout,
              onDelete: () => controller.removeWorkout(workout.id),
            );
          },
        );
      },
    );
  }
}
