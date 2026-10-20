import 'package:flutter/material.dart';
import '../models/water_tracker_model.dart';

/// İlerleme yüzdesi ve kalan miktar kartı (<= 40 satır build)
class WaterProgressCard extends StatelessWidget {
  final WaterTrackerModel model;

  const WaterProgressCard({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (model.progressRatio * 100).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          children: [
            Text(
              '${model.currentWaterMl} / ${model.totalGoalMl} ml',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Günlük Hedef Tamamlanma: %$percentage',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: model.progressRatio,
                minHeight: 14,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor:
                    AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
