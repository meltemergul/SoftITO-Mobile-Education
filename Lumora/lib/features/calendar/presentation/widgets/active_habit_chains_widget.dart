import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/calendar_month_entity.dart';

class ActiveHabitChainsWidget extends StatelessWidget {
  const ActiveHabitChainsWidget({
    super.key,
    required this.habits,
  });

  final List<ActiveHabitChainEntity> habits;

  static Color getCategoryColor(String category, AppColorsExtension colors) {
    switch (category) {
      case 'water':
        return colors.water;
      case 'book':
        return colors.book;
      case 'sport':
        return colors.sport;
      case 'mind':
        return colors.mind;
      case 'custom':
      default:
        return colors.primary;
    }
  }

  static IconData getIconData(String iconName) {
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

    if (habits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktif Hedef Zincirleri',
          style: AppTypography.heading.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: habits.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
          itemBuilder: (context, index) {
            final habit = habits[index];
            final categoryColor = getCategoryColor(habit.category, colors);

            return AppCard(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Kategori renkli ikon
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s8),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          getIconData(habit.icon),
                          color: categoryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),

                      // Alışkanlık adı
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: AppTypography.body.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (habit.currentStreak > 0)
                              Text(
                                '🔥 ${habit.currentStreak} Gün Seri',
                                style: AppTypography.caption.copyWith(
                                  color: colors.streakStrong,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Tamamlanma oranı
                      Text(
                        '%${habit.completionRate}',
                        style: AppTypography.heading.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),

                  // Kategori renginde ilerleme çubuğu
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (habit.completionRate / 100).clamp(0.0, 1.0),
                      backgroundColor: colors.inactive,
                      valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),

                  // Son 7 günün mikro zincir halkaları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Son 7 Gün:',
                        style: AppTypography.caption.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      Row(
                        children: habit.last7Days.map((microDay) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _buildMicroDayCircle(microDay, categoryColor, colors),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMicroDayCircle(
    HabitMicroDayEntity microDay,
    Color categoryColor,
    AppColorsExtension colors,
  ) {
    if (!microDay.isPlanned) {
      // Planlı değil: minik soluk nokta
      return Container(
        width: 18,
        height: 18,
        alignment: Alignment.center,
        child: Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: colors.textSecondary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    if (microDay.isCompleted) {
      // Planlı ve tamamlandı: Kategori renginde dolgulu + onay
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: categoryColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 11,
          color: Colors.white,
        ),
      );
    }

    // Planlı ama tamamlanmadı: İnce halka
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.border,
          width: 1.5,
        ),
      ),
    );
  }
}
