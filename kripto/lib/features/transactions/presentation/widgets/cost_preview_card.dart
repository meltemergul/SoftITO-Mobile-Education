import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/formatters.dart';

class CostPreviewCard extends StatelessWidget {
  final bool isBuy;
  final Decimal newAverageCost;
  final Decimal totalAmount;
  final Decimal heldQuantity;
  final Decimal? estimatedPnl;
  final String currency;
  final String assetSymbol;

  const CostPreviewCard({
    super.key,
    required this.isBuy,
    required this.newAverageCost,
    required this.totalAmount,
    required this.heldQuantity,
    this.estimatedPnl,
    required this.currency,
    required this.assetSymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text('Eldeki Bakiye', style: AppTextStyles.bodySm, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${AppFormatters.formatQuantity(heldQuantity)} $assetSymbol',
                style: AppTextStyles.labelNumericMd.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, color: AppColors.borderDivider),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  isBuy ? 'Yeni Ortalama Maliyet' : 'Mevcut Ortalama Maliyet',
                  style: AppTextStyles.bodySm,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppFormatters.formatCurrency(newAverageCost, currency),
                style: AppTextStyles.labelNumericMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (!isBuy && estimatedPnl != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text('Tahmini Gerçekleşen K/Z', style: AppTextStyles.bodySm, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  AppFormatters.formatCurrency(estimatedPnl!, currency),
                  style: AppTextStyles.labelNumericMd.copyWith(
                    color: estimatedPnl! >= Decimal.zero ? AppColors.profitText : AppColors.lossText,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, color: AppColors.borderDivider),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text('Toplam İşlem Tutarı', style: AppTextStyles.bodySm, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppFormatters.formatCurrency(totalAmount, currency),
                style: AppTextStyles.labelNumericMd,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
