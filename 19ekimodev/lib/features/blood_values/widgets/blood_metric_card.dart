import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/blood_metric_model.dart';

Color metricStatusColor(MetricStatus status) {
  switch (status) {
    case MetricStatus.eligible:
      return AppColors.eligible;
    case MetricStatus.warning:
      return AppColors.warning;
    case MetricStatus.ineligible:
      return AppColors.ineligible;
  }
}

String formatMetric(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(1);

class BloodMetricCard extends StatelessWidget {
  final BloodMetricModel metric;
  final VoidCallback onTap;

  const BloodMetricCard({super.key, required this.metric, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = metricStatusColor(metric.status);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: statusColor.withAlpha(77), width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          metric.title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Hedef: ${formatMetric(metric.minThreshold)} - '
          '${formatMetric(metric.maxThreshold)} ${metric.unit}',
          style: textTheme.bodySmall,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(31),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${formatMetric(metric.currentValue)} ${metric.unit}',
            style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
