import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/formatters.dart';
import '../../../../shared/widgets/pnl_badge.dart';

/// Varlık Listesi satırı (SKILL.md §4.1):
/// simge, ad, sembol, adet, toplam değer, 24s getiri % ve bireysel kâr tutarı.
class AssetRow extends StatelessWidget {
  final String symbol;
  final String name;
  final Decimal quantity;
  final Decimal totalValue;
  final Decimal? change24h;
  final Decimal pnlAmount;
  final String currency;
  final Color accent;
  final bool isPrivate;
  final bool showDivider;

  const AssetRow({
    super.key,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.totalValue,
    required this.change24h,
    required this.pnlAmount,
    required this.currency,
    this.accent = AppColors.primary,
    this.isPrivate = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final pnlColor = pnlAmount > Decimal.zero
        ? AppColors.profitText
        : pnlAmount < Decimal.zero
            ? AppColors.lossText
            : AppColors.textSecondary;
    final pnlSign = pnlAmount > Decimal.zero ? '+' : pnlAmount < Decimal.zero ? '-' : '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: AppColors.borderDivider))
            : null,
      ),
      child: Row(
        children: [
          // Coin simgesi
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: AppSpacing.roundedButton,
              border: Border.all(color: accent.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              symbol.isEmpty ? '?' : symbol.substring(0, 1).toUpperCase(),
              style: AppTextStyles.headlineSm.copyWith(color: accent, fontSize: 15),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Ad, sembol ve adet
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(symbol.toUpperCase(),
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isPrivate ? '•••• $symbol' : '${AppFormatters.formatQuantity(quantity)} $symbol',
                  style: AppTextStyles.numeric(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Değer, 24s % ve kâr
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 165),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    isPrivate ? '••••' : AppFormatters.formatCurrency(totalValue, currency),
                    style: AppTextStyles.labelNumericMd.copyWith(fontSize: 15),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          isPrivate
                              ? '••••'
                              : '$pnlSign${AppFormatters.formatCurrency(pnlAmount.abs(), currency)}',
                          style: AppTextStyles.numeric(fontSize: 11, color: pnlColor),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    PnlBadge(percentage: change24h ?? Decimal.zero),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
