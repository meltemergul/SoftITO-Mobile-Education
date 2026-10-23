import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/stats_entity.dart';

class ProductiveHoursWidget extends StatelessWidget {
  const ProductiveHoursWidget({
    super.key,
    required this.productiveHours,
  });

  final List<ProductiveHourEntity> productiveHours;

  static IconData _getPeriodIcon(String period) {
    switch (period) {
      case 'morning':
        return Icons.wb_sunny_rounded;
      case 'afternoon':
        return Icons.wb_twilight_rounded;
      case 'evening':
        return Icons.nights_stay_rounded;
      case 'night':
      default:
        return Icons.bedtime_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totalCount = productiveHours.fold<int>(0, (sum, item) => sum + item.count);
    final maxPercentage = productiveHours.fold<int>(
      0,
      (max, item) => item.percentage > max ? item.percentage : max,
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'En Verimli Saatler',
                style: AppTypography.heading.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.access_time_filled_rounded,
                size: 20,
                color: colors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Alışkanlıklarını en çok hangi zaman diliminde tamamlıyorsun?',
            style: AppTypography.caption.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          if (totalCount == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
              child: Center(
                child: Text(
                  'Bu aralıkta henüz tamamlanan alışkanlık kaydı yok.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            )
          else
            Column(
              children: productiveHours.map((hour) {
                final isPeak = hour.percentage > 0 && hour.percentage == maxPercentage;
                final factor = (hour.percentage / 100).clamp(0.0, 1.0);

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getPeriodIcon(hour.period),
                            size: 18,
                            color: isPeak ? colors.primaryStrong : colors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          Expanded(
                            child: Text(
                              hour.label,
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.textPrimary,
                                fontWeight: isPeak ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isPeak)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'En Odaklı',
                                style: AppTypography.caption.copyWith(
                                  color: colors.primaryStrong,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          Text(
                            '%${hour.percentage}',
                            style: AppTypography.bodySmall.copyWith(
                              color: isPeak ? colors.primaryStrong : colors.textPrimary,
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
                              height: 6,
                              width: double.infinity,
                              color: colors.inactive,
                            ),
                            FractionallySizedBox(
                              widthFactor: factor,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isPeak ? colors.primaryStrong : colors.primary.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
