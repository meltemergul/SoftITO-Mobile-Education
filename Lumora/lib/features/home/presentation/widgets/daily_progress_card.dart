import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/today_entity.dart';

class DailyProgressCard extends StatelessWidget {
  const DailyProgressCard({
    super.key,
    required this.progress,
    required this.xp,
    required this.overallStreak,
  });

  final DailyProgressEntity progress;
  final UserXpEntity xp;
  final int overallStreak;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progressFraction = progress.total > 0
        ? (progress.completed / progress.total).clamp(0.0, 1.0)
        : 1.0;

    return AppCard(
      child: Row(
        children: [
          // 1. Dairesel İlerleme Halkası
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progressFraction,
                  strokeWidth: 8,
                  backgroundColor: colors.backgroundAlt,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress.isAllCompleted ? colors.primary : colors.streak,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${progress.percentage}%',
                      style: AppTypography.heading.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${progress.completed}/${progress.total}',
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s16),

          // 2. Metrikler ve XP Bilgisi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Günün İlerlemesi',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Zincir Serisi Rozeti
                    if (overallStreak > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s8,
                          vertical: AppSpacing.s4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.streak.withValues(alpha: 0.15),
                          borderRadius: AppRadius.pillRadius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 14,
                              color: colors.streakStrong,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$overallStreak Gün',
                              style: AppTypography.caption.copyWith(
                                color: colors.streakStrong,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  progress.isAllCompleted
                      ? 'Harika! Günün tüm hedefleri bitti.'
                      : '${progress.total - progress.completed} hedef kaldı',
                  style: AppTypography.heading.copyWith(
                    color: colors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),

                // XP ve Seviye Barı
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.pillRadius,
                      ),
                      child: Text(
                        '${xp.totalXp} XP · Seviye ${xp.level}',
                        style: AppTypography.caption.copyWith(
                          color: colors.accessibleGreenText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: AppRadius.pillRadius,
                        child: LinearProgressIndicator(
                          value: xp.progressPercent / 100.0,
                          minHeight: 6,
                          backgroundColor: colors.backgroundAlt,
                          valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
