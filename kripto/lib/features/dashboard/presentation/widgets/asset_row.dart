import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/formatters.dart';
import '../../../../shared/widgets/pnl_badge.dart';

class AssetRow extends StatelessWidget {
  final String symbol;
  final String name;
  final Decimal quantity;
  final Decimal currentPrice;
  final Decimal pnlPercentage;
  final String currency;

  const AssetRow({
    super.key,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.currentPrice,
    required this.pnlPercentage,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderDivider, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Squircle Token İkonu
          Container(
            width: AppSpacing.tokenIconSize,
            height: AppSpacing.tokenIconSize,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderCard),
            ),
            alignment: Alignment.center,
            child: Text(
              symbol.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Sembol ve Miktar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(symbol.toUpperCase(), style: AppTextStyles.headlineSm.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  '${AppFormatters.formatQuantity(quantity)} $symbol',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
          // Fiyat ve K/Z Rozeti
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.formatCurrency(currentPrice, currency),
                style: AppTextStyles.labelNumericMd,
              ),
              const SizedBox(height: 4),
              PnlBadge(percentage: pnlPercentage),
            ],
          ),
        ],
      ),
    );
  }
}
