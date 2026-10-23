import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';

class RangeFilterSelector extends StatelessWidget {
  const RangeFilterSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  final String selectedRange;
  final ValueChanged<String> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: colors.inactive,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Row(
        children: [
          _buildItem(context, 'weekly', 'Haftalık', colors),
          _buildItem(context, 'monthly', 'Aylık', colors),
          _buildItem(context, 'all', 'Tüm Zamanlar', colors),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    String key,
    String label,
    AppColorsExtension colors,
  ) {
    final isSelected = selectedRange == key;

    return Expanded(
      child: GestureDetector(
        onTap: () => onRangeChanged(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
          decoration: BoxDecoration(
            color: isSelected ? colors.primaryStrong : Colors.transparent,
            borderRadius: AppRadius.pillRadius,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.primaryStrong.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isSelected ? colors.textOnPrimary : colors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
