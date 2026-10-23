import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/stats_entity.dart';
import 'category_distribution_widget.dart';

class HabitDetailsListWidget extends StatelessWidget {
  const HabitDetailsListWidget({
    super.key,
    required this.habitProgress,
  });

  final List<HabitProgressDetailEntity> habitProgress;

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
        return Icons.star_rounded;
    }
  }

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
                'Alışkanlık Detayı',
                style: AppTypography.heading.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.format_list_bulleted_rounded,
                size: 20,
                color: colors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Seçili dönemde alışkanlık bazlı ilerleme ve seriler',
            style: AppTypography.caption.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          if (habitProgress.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
              child: Center(
                child: Text(
                  'Bu dönemde planlı bir alışkanlık kaydı bulunamadı.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: habitProgress.length,
              separatorBuilder: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s8),
                child: Divider(height: 1),
              ),
              itemBuilder: (context, index) {
                final item = habitProgress[index];
                final catColor = CategoryDistributionWidget.getCategoryColor(item.category, colors);
                final factor = (item.rate / 100).clamp(0.0, 1.0);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getHabitIcon(item.icon),
                              size: 18,
                              color: catColor,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: AppTypography.body.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.completedDays}/${item.totalPlannedDays} gün tamamlandı',
                                  style: AppTypography.caption.copyWith(
                                    color: colors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Başarı oranı
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '%${item.rate}',
                              style: AppTypography.caption.copyWith(
                                color: colors.primaryStrong,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // İlerleme çubuğu
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Stack(
                          children: [
                            Container(
                              height: 6,
                              width: double.infinity,
                              color: colors.inactive,
                            ),
                            FractionallySizedBox(
                              widthFactor: factor,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: catColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Seri bilgileri
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                size: 14,
                                color: colors.streakStrong,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Mevcut Seri: ${item.currentStreak} Gün',
                                style: AppTypography.caption.copyWith(
                                  color: colors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'En Uzun: ${item.longestStreak} Gün',
                            style: AppTypography.caption.copyWith(
                              color: colors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
