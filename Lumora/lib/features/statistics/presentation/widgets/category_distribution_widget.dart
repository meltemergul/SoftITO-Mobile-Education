import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/stats_entity.dart';

class CategoryDistributionWidget extends StatelessWidget {
  const CategoryDistributionWidget({
    super.key,
    required this.categories,
  });

  final List<CategoryDistributionEntity> categories;

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

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'water':
        return Icons.water_drop_rounded;
      case 'book':
        return Icons.menu_book_rounded;
      case 'sport':
        return Icons.directions_run_rounded;
      case 'mind':
        return Icons.self_improvement_rounded;
      case 'custom':
      default:
        return Icons.category_rounded;
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
                'Kategori Dağılımı',
                style: AppTypography.heading.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 20,
                color: colors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
              child: Center(
                child: Text(
                  'Bu aralıkta planlı kategori verisi bulunmuyor.',
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
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
              itemBuilder: (context, index) {
                final item = categories[index];
                final catColor = getCategoryColor(item.category, colors);
                final catIcon = getCategoryIcon(item.category);
                final progressFactor = (item.rate / 100).clamp(0.0, 1.0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(catIcon, size: 16, color: catColor),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Expanded(
                          child: Text(
                            item.name,
                            style: AppTypography.body.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '%${item.rate}',
                          style: AppTypography.body.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          Container(
                            height: 8,
                            width: double.infinity,
                            color: colors.inactive,
                          ),
                          FractionallySizedBox(
                            widthFactor: progressFactor,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: catColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${item.completedCount}/${item.totalPlanned} tamamlandı',
                        style: AppTypography.caption.copyWith(
                          color: colors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
