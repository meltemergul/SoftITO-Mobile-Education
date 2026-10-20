import 'package:flutter/material.dart';
import '../models/water_tracker_model.dart';

/// İstatistik özet gridi (Kalan miktar ve egzersiz ek su miktarı) (<= 40 satır build)
class WaterStatsGrid extends StatelessWidget {
  final WaterTrackerModel model;

  const WaterStatsGrid({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Kalan İhtiyaç',
            value: '${model.remainingMl} ml',
            icon: Icons.water_drop_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Egzersiz Ek Su',
            value: '+${model.workoutExtraMl} ml',
            icon: Icons.fitness_center_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.secondary, size: 24),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
