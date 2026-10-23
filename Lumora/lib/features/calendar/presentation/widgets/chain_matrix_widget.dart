import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/calendar_month_entity.dart';

class ChainMatrixWidget extends StatelessWidget {
  const ChainMatrixWidget({
    super.key,
    required this.days,
    required this.weekStartsOn,
    required this.onDaySelected,
  });

  final List<CalendarDayEntity> days;
  final int weekStartsOn; // 1 = Pazartesi ... 7 = Pazar
  final ValueChanged<String> onDaySelected;

  static const List<String> _mondayFirstWeekdayLabels = [
    'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'
  ];

  static const List<String> _sundayFirstWeekdayLabels = [
    'Paz', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt'
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final weekdayLabels = weekStartsOn == 7 ? _sundayFirstWeekdayLabels : _mondayFirstWeekdayLabels;

    // Ayın ilk gününün haftanın hangi gününe geldiğini hesapla
    int leadingBlanks = 0;
    if (days.isNotEmpty) {
      final firstDayDate = DateTime.parse(days.first.date);
      // firstDayDate.weekday: 1 = Mon ... 7 = Sun
      final dayOfWeek = firstDayDate.weekday;
      if (weekStartsOn == 1) {
        leadingBlanks = dayOfWeek - 1; // Mon = 0, Sun = 6
      } else {
        leadingBlanks = dayOfWeek % 7; // Sun = 0, Mon = 1 ... Sat = 6
      }
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Zincir Matrisi',
                style: AppTypography.heading.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _buildLegend(colors),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),

          // Haftanın günleri başlıkları
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdayLabels.map((label) {
              return Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.s12),

          // Gün hücreleri ızgarası (7 sütun)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingBlanks + days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              if (index < leadingBlanks) {
                return const SizedBox.shrink();
              }

              final day = days[index - leadingBlanks];
              return _buildDayCell(context, day, colors);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(AppColorsExtension colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegendItem(
          icon: Icons.check_rounded,
          color: colors.primary,
          label: 'Tam',
          colors: colors,
        ),
        const SizedBox(width: AppSpacing.s8),
        _buildLegendItem(
          icon: Icons.square_rounded,
          color: colors.streak,
          label: 'Kısmi',
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required Color color,
    required String label,
    required AppColorsExtension colors,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 10, color: Colors.white),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: colors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    CalendarDayEntity day,
    AppColorsExtension colors,
  ) {
    // Duruma göre stil ve şekil
    Color backgroundColor;
    Color borderColor;
    Widget? iconWidget;
    Color textColor;
    double opacity = 1.0;

    switch (day.status) {
      case CalendarDayStatus.completed:
        // Tamamlanan gün: Yeşil dolgulu halka + Onay işareti
        backgroundColor = colors.primary;
        borderColor = colors.primaryStrong;
        textColor = colors.textOnPrimary;
        iconWidget = const Icon(
          Icons.check_rounded,
          size: 14,
          color: Colors.white,
        );
        break;

      case CalendarDayStatus.partial:
        // Kısmi gün: Turuncu ton + Şekil (kare/nokta)
        backgroundColor = colors.streak.withValues(alpha: 0.15);
        borderColor = colors.streak;
        textColor = colors.streakStrong;
        iconWidget = Icon(
          Icons.square_rounded,
          size: 8,
          color: colors.streakStrong,
        );
        break;

      case CalendarDayStatus.empty:
        // Kaçırılan/Boş gün: İnce gri halka, içi boş
        backgroundColor = colors.surface;
        borderColor = colors.border;
        textColor = colors.textSecondary;
        iconWidget = null;
        break;

      case CalendarDayStatus.rest:
        // Dinlenme günü: Çok hafif zemin, çizgisiz
        backgroundColor = colors.inactive.withValues(alpha: 0.5);
        borderColor = Colors.transparent;
        textColor = colors.textSecondary.withValues(alpha: 0.7);
        iconWidget = null;
        break;

      case CalendarDayStatus.future:
        // Gelecek gün: Soluk
        backgroundColor = Colors.transparent;
        borderColor = colors.border.withValues(alpha: 0.4);
        textColor = colors.textSecondary.withValues(alpha: 0.4);
        iconWidget = null;
        opacity = 0.5;
        break;
    }

    final isToday = day.isToday;

    return Semantics(
      label: '${day.dayNumber}. gün: ${day.status.value}',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onDaySelected(day.date),
          child: Opacity(
            opacity: opacity,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isToday ? colors.streakStrong : borderColor,
                      width: isToday ? 2.0 : 1.0,
                    ),
                    boxShadow: day.status == CalendarDayStatus.completed
                        ? [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.dayNumber}',
                        style: AppTypography.caption.copyWith(
                          color: textColor,
                          fontWeight: isToday || day.status == CalendarDayStatus.completed
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      if (iconWidget != null) ...[
                        const SizedBox(height: 2),
                        iconWidget,
                      ],
                    ],
                  ),
                ),
                // Bugün vurgusu: Alev rozeti
                if (isToday)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colors.streakStrong,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        size: 9,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
