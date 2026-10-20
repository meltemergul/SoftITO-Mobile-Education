import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/workout_controller.dart';
import '../models/workout_model.dart';

class WorkoutHistoryList extends StatelessWidget {
  final WorkoutController controller;

  const WorkoutHistoryList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final workouts = controller.workouts;

    if (workouts.isEmpty) {
      return const _EmptyWorkoutPlaceholder();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workouts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = workouts[index];
        return _WorkoutHistoryTile(
          item: item,
          onDelete: () => controller.removeWorkout(item.id),
        );
      },
    );
  }
}

class _EmptyWorkoutPlaceholder extends StatelessWidget {
  const _EmptyWorkoutPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: const Column(
        children: [
          Icon(Icons.fitness_center_outlined, color: AppColors.surfaceBorder, size: 40),
          SizedBox(height: 8),
          Text(
            'Henüz tamamlanan egzersiz kaydı yok.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _WorkoutHistoryTile extends StatelessWidget {
  final WorkoutItem item;
  final VoidCallback onDelete;

  const _WorkoutHistoryTile({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.8),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: AppColors.neonEnergy, size: 22),
          const SizedBox(width: 12),
          Expanded(child: _WorkoutTileInfo(item: item)),
          _WorkoutMetricsColumn(item: item),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
            onPressed: onDelete,
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}

class _WorkoutTileInfo extends StatelessWidget {
  final WorkoutItem item;

  const _WorkoutTileInfo({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        Text(
          '${item.durationMinutes} dakika • ${item.category}',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

class _WorkoutMetricsColumn extends StatelessWidget {
  final WorkoutItem item;

  const _WorkoutMetricsColumn({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '+${item.caloriesBurned} kcal',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.neonCalorie,
            fontSize: 14,
          ),
        ),
        Text(
          '+${item.recommendedWaterMl} ml su',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.neonWater,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
