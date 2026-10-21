import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/formatters.dart';
import '../../../../shared/widgets/pnl_badge.dart';
import '../../../portfolio/domain/position.dart';

enum AllocationSort { byValue, byPnl, byName }

class AllocationTable extends StatelessWidget {
  final List<Position> positions;
  final String currency;
  final AllocationSort sort;
  final ValueChanged<AllocationSort> onSortChanged;

  const AllocationTable({
    super.key,
    required this.positions,
    required this.currency,
    required this.sort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (positions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: AppSpacing.roundedCard,
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.pie_chart_outline, color: AppColors.textMuted, size: 36),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Görüntülenecek varlık bulunmuyor',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final sorted = List<Position>.from(positions);
    switch (sort) {
      case AllocationSort.byValue:
        sorted.sort((a, b) => b.currentValue.compareTo(a.currentValue));
        break;
      case AllocationSort.byPnl:
        sorted.sort((a, b) => b.unrealizedPnl.compareTo(a.unrealizedPnl));
        break;
      case AllocationSort.byName:
        sorted.sort((a, b) => a.asset.symbol.compareTo(b.asset.symbol));
        break;
    }

    Decimal totalValue = Decimal.zero;
    Decimal totalCost = Decimal.zero;
    for (final p in positions) {
      totalValue += p.currentValue;
      totalCost += p.totalCost;
    }
    final totalPnl = totalValue - totalCost;
    final totalPercentage = totalCost > Decimal.zero
        ? (totalPnl / totalCost).toDecimal(scaleOnInfinitePrecision: 8) * Decimal.fromInt(100)
        : Decimal.zero;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        children: [
          // Sıralama Seçenekleri Çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('VARLIK TABLOSU', style: AppTextStyles.labelSm),
                Row(
                  children: [
                    _buildSortChip('Değer', AllocationSort.byValue),
                    const SizedBox(width: 4),
                    _buildSortChip('K/Z', AllocationSort.byPnl),
                    const SizedBox(width: 4),
                    _buildSortChip('İsim', AllocationSort.byName),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDivider),

          // Liste Satırları
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderDivider),
            itemBuilder: (context, i) {
              final pos = sorted[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Coin Başlığı & Adet
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pos.asset.symbol, style: AppTextStyles.headlineSm.copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(
                            '${AppFormatters.formatQuantity(pos.quantity)} adet',
                            style: AppTextStyles.bodySm,
                          ),
                          Text(
                            'Ort: ${AppFormatters.formatCurrency(pos.averageBuyPrice, currency)}',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    // Değer & K/Z
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppFormatters.formatCurrency(pos.currentValue, currency),
                            style: AppTextStyles.labelNumericMd,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppFormatters.formatCurrency(pos.unrealizedPnl, currency),
                                style: AppTextStyles.caption.copyWith(
                                  color: pos.unrealizedPnl >= Decimal.zero
                                      ? AppColors.profitText
                                      : AppColors.lossText,
                                ),
                              ),
                              const SizedBox(width: 6),
                              PnlBadge(percentage: pos.unrealizedPnlPercentage),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Alt Toplam Satırı (Footer)
          const Divider(height: 1, color: AppColors.borderSheet),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surface2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOPLAM PORTFÖY',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppFormatters.formatCurrency(totalValue, currency),
                      style: AppTextStyles.labelNumericMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    PnlBadge(percentage: totalPercentage),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, AllocationSort targetSort) {
    final isSelected = sort == targetSort;
    return GestureDetector(
      onTap: () => onSortChanged(targetSort),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface3 : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
