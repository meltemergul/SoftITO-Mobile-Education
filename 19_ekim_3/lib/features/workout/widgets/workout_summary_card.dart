import 'package:flutter/material.dart';
import '../models/workout_model.dart';

/// Egzersiz genel toplam ve su etkisi özet kartı (<= 40 satır build)
class WorkoutSummaryCard extends StatelessWidget {
  final WorkoutStateModel state;

  const WorkoutSummaryCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              label: 'Yakılan Kalori',
              value: '${state.totalCalories} kcal',
              icon: Icons.local_fire_department_rounded,
              color: theme.colorScheme.primary,
            ),
            Container(
              height: 40,
              width: 1,
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            _SummaryItem(
              label: 'Ek Su İhtiyacı',
              value: '+${state.totalExtraWaterMl} ml',
              icon: Icons.water_drop_rounded,
              color: theme.colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(value,
            style:
                theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
