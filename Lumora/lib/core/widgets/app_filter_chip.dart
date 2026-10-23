import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/dimensions.dart';
import '../theme/typography.dart';

class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // design-skill.md Bölüm 3: Dolgulu buton/çip zemininde primaryStrong kullanılarak WCAG AA kontrastı sağlanır.
    final backgroundColor = isSelected ? colors.primaryStrong : colors.surface;
    final foregroundColor = isSelected ? colors.textOnPrimary : colors.textSecondary;
    final borderSide = isSelected ? BorderSide.none : BorderSide(color: colors.border);

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label filtreleme çipi, ${isSelected ? "seçili" : "seçili değil"}',
      child: Material(
        color: backgroundColor,
        shape: StadiumBorder(side: borderSide),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onSelected(!isSelected),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTouchTarget,
              minWidth: AppSpacing.minTouchTarget,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: AppSpacing.s4),
                ] else if (isSelected) ...[
                  // design-skill.md Bölüm 3: Renge ek şekil/ikon kuralı (yalnızca renkle durum belirtilmez)
                  Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: foregroundColor,
                  ),
                  const SizedBox(width: AppSpacing.s4),
                ],
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: foregroundColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
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
