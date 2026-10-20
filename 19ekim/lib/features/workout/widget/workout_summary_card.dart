import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/workout_controller.dart';

class WorkoutSummaryCard extends StatelessWidget {
  final WorkoutController controller;

  const WorkoutSummaryCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryHeader(controller: controller),
            const SizedBox(height: 16),
            _CalorieProgressBar(progress: controller.calorieProgress),
            const SizedBox(height: 16),
            _StatsRow(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final WorkoutController controller;

  const _SummaryHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yakılan Kalori',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            SizedBox(height: 2),
            Text(
              'Günlük Hedef',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${controller.totalCaloriesBurned}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.neonCalorie,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '/ ${controller.dailyCalorieGoal} kcal',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}

class _CalorieProgressBar extends StatelessWidget {
  final double progress;

  const _CalorieProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 10,
        backgroundColor: AppColors.surfaceBorder,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonCalorie),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final WorkoutController controller;

  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _MetricItem(
          icon: Icons.timer_outlined,
          color: AppColors.neonEnergy,
          title: 'Toplam Süre',
          value: '${controller.totalDurationMinutes} dk',
        ),
        Container(width: 1, height: 28, color: AppColors.surfaceBorder),
        _MetricItem(
          icon: Icons.fitness_center,
          color: AppColors.neonPurple,
          title: 'Tamamlanan',
          value: '${controller.workouts.length}',
        ),
        Container(width: 1, height: 28, color: AppColors.surfaceBorder),
        _MetricItem(
          icon: Icons.water_drop,
          color: AppColors.neonWater,
          title: 'Ek Su İhtiyacı',
          value: '+${controller.totalRecommendedWaterMl} ml',
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _MetricItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
