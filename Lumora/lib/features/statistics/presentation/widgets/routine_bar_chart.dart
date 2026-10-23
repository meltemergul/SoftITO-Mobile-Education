import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/stats_entity.dart';

class RoutineBarChart extends StatefulWidget {
  const RoutineBarChart({
    super.key,
    required this.chartItems,
  });

  final List<DailyChartEntity> chartItems;

  @override
  State<RoutineBarChart> createState() => _RoutineBarChartState();
}

class _RoutineBarChartState extends State<RoutineBarChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = widget.chartItems;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rutin Performansı',
                style: AppTypography.heading.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // Tepe gün göstergesi etiketi
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.primaryStrong,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Zirve Günler',
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),

          // Seçili gün balonu (Tooltip / Değer balonu)
          SizedBox(
            height: 28,
            child: _selectedIndex != null && _selectedIndex! < items.length
                ? _buildSelectedDayBubble(items[_selectedIndex!], colors)
                : Center(
                    child: Text(
                      'Detay görmek için bir güne dokunun',
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.s8),

          // Çubuklar Alanı
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = _selectedIndex == index;
                final heightFactor = (item.rate / 100).clamp(0.04, 1.0);

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _selectedIndex = (_selectedIndex == index) ? null : index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Çubuk
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: heightFactor,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: item.rate == 0
                                        ? colors.inactive
                                        : item.isPeak
                                            ? colors.primaryStrong
                                            : colors.primary.withValues(alpha: 0.75),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6),
                                    ),
                                    border: isSelected
                                        ? Border.all(color: colors.streakStrong, width: 2)
                                        : null,
                                    boxShadow: item.isPeak && item.rate > 0
                                        ? [
                                            BoxShadow(
                                              color: colors.primaryStrong.withValues(alpha: 0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Gün etiketi (Pzt, Sal...)
                          Text(
                            item.dayLabel,
                            style: AppTypography.caption.copyWith(
                              color: isSelected
                                  ? colors.primaryStrong
                                  : item.isPeak
                                      ? colors.textPrimary
                                      : colors.textSecondary,
                              fontWeight: item.isPeak || isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayBubble(DailyChartEntity item, AppColorsExtension colors) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: colors.primaryStrong,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.primaryStrong.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '${item.dayLabel} (${item.date}): %${item.rate} · ${item.completed}/${item.total} tamamlandı',
          style: AppTypography.caption.copyWith(
            color: colors.textOnPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
