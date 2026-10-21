import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/formatters.dart';
import '../../../../shared/widgets/pnl_badge.dart';

class PortfolioSummaryCard extends StatelessWidget {
  final Decimal totalValue;
  final Decimal pnlPercentage;
  final String selectedCurrency;
  final ValueChanged<String> onCurrencyChanged;

  const PortfolioSummaryCard({
    super.key,
    required this.totalValue,
    required this.pnlPercentage,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.borderCard, width: 1),
      ),
      child: Stack(
        children: [
          // Hafif cyan ışıma (glow)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppSpacing.roundedCard,
                gradient: RadialGradient(
                  center: const Alignment(0, -0.8),
                  radius: 0.8,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOPLAM PORTFÖY DEĞERİ',
                      style: AppTextStyles.labelSm,
                    ),
                    // USD / TL Seçici
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: AppSpacing.roundedPill,
                        border: Border.all(color: AppColors.borderCard),
                      ),
                      child: Row(
                        children: [
                          _buildCurrencyTab('USD'),
                          _buildCurrencyTab('TRY'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppFormatters.formatCurrency(totalValue, selectedCurrency),
                  style: AppTextStyles.labelNumericLg.copyWith(fontSize: 28),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    PnlBadge(percentage: pnlPercentage),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Tüm zamanlar',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyTab(String currency) {
    final isSelected = selectedCurrency == currency;
    return GestureDetector(
      onTap: () => onCurrencyChanged(currency),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface3 : Colors.transparent,
          borderRadius: AppSpacing.roundedPill,
        ),
        child: Text(
          currency,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
