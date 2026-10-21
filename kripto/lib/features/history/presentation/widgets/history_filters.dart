import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class HistoryFilters extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const HistoryFilters({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('İşlem Geçmişi', 0),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabButton('Gerçekleşmiş Kâr', 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface2 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.borderCyanFocus : Colors.transparent,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: AppTextStyles.labelSm.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
