import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class PnlBadge extends StatelessWidget {
  final Decimal percentage;
  final Decimal? amount;
  final String? currency;

  const PnlBadge({
    super.key,
    required this.percentage,
    this.amount,
    this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final doubleVal = percentage.toDouble();
    final isPositive = doubleVal > 0;
    final isZero = doubleVal == 0;

    final Color bgColor;
    final Color textColor;
    final Color borderColor;
    final String prefix;

    if (isZero) {
      bgColor = AppColors.surface3;
      textColor = AppColors.textSecondary;
      borderColor = Colors.transparent;
      prefix = '';
    } else if (isPositive) {
      bgColor = AppColors.profitBg;
      textColor = AppColors.profitText;
      borderColor = AppColors.profitBorder;
      prefix = '+';
    } else {
      bgColor = AppColors.lossBg;
      textColor = AppColors.lossText;
      borderColor = AppColors.lossBorder;
      prefix = '';
    }

    final displayText = '$prefix${doubleVal.toStringAsFixed(2)}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.roundedPill,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPositive)
            Icon(Icons.arrow_drop_up, size: 14, color: textColor)
          else if (!isZero)
            Icon(Icons.arrow_drop_down, size: 14, color: textColor),
          Text(
            displayText,
            style: AppTextStyles.labelSm.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
