import 'package:flutter/material.dart';

import '../models/blood_metric_model.dart';
import 'blood_metric_card.dart';

/// Tüm metriklerden genel bağış uygunluğunu özetleyen üst kart.
class EligibilitySummaryCard extends StatelessWidget {
  final List<BloodMetricModel> metrics;

  const EligibilitySummaryCard({super.key, required this.metrics});

  MetricStatus get _overall {
    if (metrics.any((m) => m.status == MetricStatus.ineligible)) {
      return MetricStatus.ineligible;
    }
    if (metrics.any((m) => m.status == MetricStatus.warning)) {
      return MetricStatus.warning;
    }
    return MetricStatus.eligible;
  }

  @override
  Widget build(BuildContext context) {
    final status = _overall;
    final color = metricStatusColor(status);
    final eligibleCount = metrics
        .where((m) => m.status == MetricStatus.eligible)
        .length;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(64), color.withAlpha(13)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Row(
        children: [
          Icon(_iconFor(status), color: color, size: 44),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleFor(status),
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$eligibleCount / ${metrics.length} değer referans aralığında',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(MetricStatus status) {
    switch (status) {
      case MetricStatus.eligible:
        return Icons.verified;
      case MetricStatus.warning:
        return Icons.warning_amber_rounded;
      case MetricStatus.ineligible:
        return Icons.block;
    }
  }

  String _titleFor(MetricStatus status) {
    switch (status) {
      case MetricStatus.eligible:
        return 'Bağışa Uygunsunuz';
      case MetricStatus.warning:
        return 'Sınırda Değerler Var';
      case MetricStatus.ineligible:
        return 'Şu An Uygun Değil';
    }
  }
}
