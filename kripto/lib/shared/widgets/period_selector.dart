import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class PeriodSelector extends StatelessWidget {
  final List<String> periods;
  final String selectedPeriod;
  final ValueChanged<String> onSelected;

  const PeriodSelector({
    super.key,
    this.periods = const ['1G', '1H', '1A'],
    required this.selectedPeriod,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppSpacing.roundedPill,
        border: Border.all(color: AppColors.borderCard, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: periods.map((period) {
          final isSelected = period == selectedPeriod;
          return GestureDetector(
            onTap: () => onSelected(period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surface2 : Colors.transparent,
                borderRadius: AppSpacing.roundedPill,
                border: Border.all(
                  color: isSelected ? AppColors.borderCyanFocus : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Text(
                period,
                style: AppTextStyles.labelSm.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
