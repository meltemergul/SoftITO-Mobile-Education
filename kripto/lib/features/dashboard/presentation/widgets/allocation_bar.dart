import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class AllocationSegment {
  final String label;
  final double percentage; // 0-100
  final Color color;

  const AllocationSegment({
    required this.label,
    required this.percentage,
    required this.color,
  });
}

/// Varlık Dağılım Çubuğu: renk kodlu segmentli progress bar (SKILL.md §4.1)
class AllocationBar extends StatelessWidget {
  final List<AllocationSegment> segments;

  const AllocationBar({super.key, required this.segments});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppSpacing.roundedPill,
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  for (int i = 0; i < segments.length; i++) ...[
                    if (i > 0) const SizedBox(width: 2),
                    Expanded(
                      flex: (segments[i].percentage * 10).round().clamp(1, 1000),
                      child: Container(color: segments[i].color),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: segments
                .map(
                  (s) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(s.label,
                          style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(width: 4),
                      Text(
                        '%${s.percentage.toStringAsFixed(1)}',
                        style: AppTextStyles.numeric(fontSize: 12, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
