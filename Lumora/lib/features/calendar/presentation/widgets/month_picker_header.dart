import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';

class MonthPickerHeader extends StatelessWidget {
  const MonthPickerHeader({
    super.key,
    required this.currentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime currentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  static const List<String> _turkishMonths = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final monthName = _turkishMonths[currentMonth.month - 1];
    final year = currentMonth.year;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$monthName $year',
              style: AppTypography.heading.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Zinciri Kırma Takvimi',
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              tooltip: 'Önceki Ay',
              icon: Icon(
                Icons.chevron_left_rounded,
                color: colors.textPrimary,
                size: 28,
              ),
              padding: const EdgeInsets.all(AppSpacing.s8),
              constraints: const BoxConstraints(),
              onPressed: onPreviousMonth,
            ),
            const SizedBox(width: AppSpacing.s4),
            IconButton(
              tooltip: 'Sonraki Ay',
              icon: Icon(
                Icons.chevron_right_rounded,
                color: colors.textPrimary,
                size: 28,
              ),
              padding: const EdgeInsets.all(AppSpacing.s8),
              constraints: const BoxConstraints(),
              onPressed: onNextMonth,
            ),
          ],
        ),
      ],
    );
  }
}
