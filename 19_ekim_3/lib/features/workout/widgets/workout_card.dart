import 'package:flutter/material.dart';
import '../models/workout_model.dart';

/// Tekil egzersiz kayıt kartı (<= 40 satır build)
class WorkoutCard extends StatelessWidget {
  final WorkoutItem item;

  const WorkoutCard({
    super.key,
    required this.item,
  });

  IconData _getIcon(WorkoutType type) {
    switch (type) {
      case WorkoutType.running:
        return Icons.directions_run_rounded;
      case WorkoutType.cycling:
        return Icons.directions_bike_rounded;
      case WorkoutType.strength:
        return Icons.fitness_center_rounded;
      case WorkoutType.cardio:
        return Icons.flash_on_rounded;
      case WorkoutType.yoga:
        return Icons.self_improvement_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Icon(_getIcon(item.type), color: theme.colorScheme.primary),
        ),
        title: Text(item.type.label, style: theme.textTheme.titleMedium),
        subtitle: Text(
          '${item.durationMinutes} dakika • ${item.caloriesBurned} kcal',
          style: theme.textTheme.bodyMedium,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '+${item.calculatedExtraWaterMl} ml su',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
