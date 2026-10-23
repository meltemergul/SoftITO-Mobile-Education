import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/stats_entity.dart';
import 'category_distribution_widget.dart';

class WeeklyMomentumCard extends StatelessWidget {
  const WeeklyMomentumCard({
    super.key,
    required this.overallScore,
    this.bestHabit,
    required this.overallStreak,
  });

  final int overallScore;
  final BestHabitEntity? bestHabit;
  final int overallStreak;

  static IconData _getHabitIcon(String iconName) {
    switch (iconName) {
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'directions_run':
        return Icons.directions_run_rounded;
      case 'self_improvement':
        return Icons.self_improvement_rounded;
      case 'bedtime':
        return Icons.bedtime_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    String momentumTitle;
    String momentumSubtitle;
    if (overallScore >= 80) {
      momentumTitle = 'Yüksek Momentum!';
      momentumSubtitle = 'Zincirini mükemmel koruyorsun. "Usta Disiplinci" unvanına doğru hızla ilerliyorsun.';
    } else if (overallScore >= 50) {
      momentumTitle = 'Güçlü Bir İvme';
      momentumSubtitle = 'Adım adım alışkanlıklarını pekiştiriyorsun. Bir sonraki seviyeye az kaldı!';
    } else {
      momentumTitle = 'Gelişim Zamanı';
      momentumSubtitle = 'Her yeni gün yeni bir başlangıçtır. Küçük bir adımla bugün ritmini yakala.';
    }

    final habit = bestHabit;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary,
                      colors.primaryStrong,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: colors.textOnPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      momentumTitle,
                      style: AppTypography.heading.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Haftalık Özet & Momentum',
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            momentumSubtitle,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // En Düzenli Alışkanlık Öne Çıkarımı
          if (habit != null) ...[
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Icon(
                  Icons.military_tech_rounded,
                  size: 20,
                  color: colors.streakStrong,
                ),
                const SizedBox(width: 6),
                Text(
                  'En Düzenli Alışkanlık',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: colors.backgroundAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: CategoryDistributionWidget.getCategoryColor(habit.category, colors)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getHabitIcon(habit.icon),
                      size: 18,
                      color: CategoryDistributionWidget.getCategoryColor(habit.category, colors),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: AppTypography.body.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '%${habit.rate} başarı',
                          style: AppTypography.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: colors.streakStrong,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.currentStreak} Gün Seri',
                        style: AppTypography.caption.copyWith(
                          color: colors.streakStrong,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
