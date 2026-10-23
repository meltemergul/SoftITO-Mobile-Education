import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';

class OverallScoreCard extends StatelessWidget {
  const OverallScoreCard({
    super.key,
    required this.overallScore,
    this.trend,
    required this.totalCompletedDays,
    required this.longestStreak,
  });

  final int overallScore;
  final int? trend;
  final int totalCompletedDays;
  final int longestStreak;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Genel Başarı Skoru',
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              if (trend != null) _buildTrendBadge(trend!, colors),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '%$overallScore',
                style: AppTypography.display.copyWith(
                  color: colors.primaryStrong,
                  fontWeight: FontWeight.w800,
                  fontSize: 40,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                'tamamlanma oranı',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.s12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 16, color: colors.primaryStrong),
                  const SizedBox(width: 6),
                  Text(
                    'Tamamlanan Gün: ',
                    style: AppTypography.caption.copyWith(color: colors.textSecondary),
                  ),
                  Text(
                    '$totalCompletedDays Gün',
                    style: AppTypography.caption.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.local_fire_department_rounded, size: 16, color: colors.streakStrong),
                  const SizedBox(width: 6),
                  Text(
                    'En Uzun Seri: ',
                    style: AppTypography.caption.copyWith(color: colors.textSecondary),
                  ),
                  Text(
                    '$longestStreak Gün',
                    style: AppTypography.caption.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBadge(int trendValue, AppColorsExtension colors) {
    final isPositive = trendValue > 0;
    final isNegative = trendValue < 0;

    Color bg;
    Color fg;
    IconData icon;
    String text;

    if (isPositive) {
      bg = colors.primary.withValues(alpha: 0.15);
      fg = colors.primaryStrong;
      icon = Icons.trending_up_rounded;
      text = '+$trendValue%';
    } else if (isNegative) {
      bg = Colors.redAccent.withValues(alpha: 0.12);
      fg = Colors.redAccent;
      icon = Icons.trending_down_rounded;
      text = '$trendValue%';
    } else {
      bg = colors.inactive;
      fg = colors.textSecondary;
      icon = Icons.trending_flat_rounded;
      text = '0%';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
