import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Özet sayı kartı (toplam bağış, değişim yüzdesi vb.).
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final double? changePercent;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.changePercent,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final change = changePercent;
    final changeColor = change == null || change >= 0
        ? AppColors.eligible
        : AppColors.ineligible;

    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.labelMedium),
              const SizedBox(height: 6),
              Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (change != null)
                Text(
                  '${change >= 0 ? '▲' : '▼'} %${change.abs().toStringAsFixed(1)}',
                  style: textTheme.labelMedium?.copyWith(color: changeColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Başlıklı bölüm kartı.
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const SectionCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
