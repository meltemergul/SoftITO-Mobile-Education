import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Hızlı su ekleme butonlarını sunan widget.
class QuickWaterButtons extends StatelessWidget {
  final void Function(int amount, String source) onAdd;

  const QuickWaterButtons({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildOption(
          context: context,
          label: '200 ml',
          subLabel: 'Bardak',
          icon: Icons.local_drink_rounded,
          amount: 200,
        ),
        _buildOption(
          context: context,
          label: '330 ml',
          subLabel: 'Kutu',
          icon: Icons.coffee_rounded,
          amount: 330,
        ),
        _buildOption(
          context: context,
          label: '500 ml',
          subLabel: 'Şişe',
          icon: Icons.sports_bar_rounded,
          amount: 500,
        ),
        _buildOption(
          context: context,
          label: '750 ml',
          subLabel: 'Matara',
          icon: Icons.fitness_center_rounded,
          amount: 750,
        ),
      ],
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String label,
    required String subLabel,
    required IconData icon,
    required int amount,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final iconColor = isDark ? AppColors.neonCyan : AppColors.lightPrimary;

    return InkWell(
      onTap: () => onAdd(amount, subLabel),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            Text(
              subLabel,
              style: TextStyle(
                fontSize: 10,
                color: subTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
