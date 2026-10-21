import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/formatters.dart';
import '../../../portfolio/domain/cost_calculator.dart';

enum PnlFilter { all, profitOnly, lossOnly }

class RealizedPnlTable extends StatefulWidget {
  final List<RealizedSalePnl> sales;
  final String currency;

  const RealizedPnlTable({
    super.key,
    required this.sales,
    required this.currency,
  });

  @override
  State<RealizedPnlTable> createState() => _RealizedPnlTableState();
}

class _RealizedPnlTableState extends State<RealizedPnlTable> {
  PnlFilter _filter = PnlFilter.all;

  @override
  Widget build(BuildContext context) {
    if (widget.sales.isEmpty) {
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
              Icon(Icons.receipt_long_outlined, color: AppColors.textMuted, size: 36),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Henüz gerçekleşmiş kâr/zarar kaydı yok',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                'Satış işlemi yaptığınızda gerçekleşen kâr ve zararlarınız burada listelenir.',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final filtered = widget.sales.where((s) {
      if (_filter == PnlFilter.profitOnly) return s.netPnl > Decimal.zero;
      if (_filter == PnlFilter.lossOnly) return s.netPnl < Decimal.zero;
      return true;
    }).toList();

    Decimal totalNetPnl = Decimal.zero;
    for (final s in filtered) {
      totalNetPnl += s.netPnl;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        children: [
          // Filtre Butonları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SATIŞ DÖKÜMÜ', style: AppTextStyles.labelSm),
                Row(
                  children: [
                    _buildFilterChip('Tümü', PnlFilter.all),
                    const SizedBox(width: 4),
                    _buildFilterChip('Kârlı', PnlFilter.profitOnly),
                    const SizedBox(width: 4),
                    _buildFilterChip('Zararlı', PnlFilter.lossOnly),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.borderDivider),

          // Liste Satırları
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => Divider(height: 1, color: AppColors.borderDivider),
            itemBuilder: (context, i) {
              final sale = filtered[i];
              final isProfit = sale.netPnl >= Decimal.zero;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppFormatters.formatDateTime(sale.executedAt),
                            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${AppFormatters.formatQuantity(sale.soldQuantity)} adet satıldı',
                            style: AppTextStyles.bodySm,
                          ),
                          Text(
                            'Ort. Alış: ${AppFormatters.formatCurrency(sale.averageBuyPrice, widget.currency)} → Satış: ${AppFormatters.formatCurrency(sale.sellPrice, widget.currency)}',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isProfit ? '+' : ''}${AppFormatters.formatCurrency(sale.netPnl, widget.currency)}',
                            style: AppTextStyles.labelNumericMd.copyWith(
                              color: isProfit ? AppColors.profitText : AppColors.lossText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (sale.fee > Decimal.zero)
                            Text(
                              'Kom: ${AppFormatters.formatCurrency(sale.fee, widget.currency)}',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Alt Toplam Özeti (Footer)
          Divider(height: 1, color: AppColors.borderSheet),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surface2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'TOPLAM GERÇEKLEŞMİŞ K/Z',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${totalNetPnl >= Decimal.zero ? '+' : ''}${AppFormatters.formatCurrency(totalNetPnl, widget.currency)}',
                  style: AppTextStyles.labelNumericMd.copyWith(
                    color: totalNetPnl >= Decimal.zero ? AppColors.profitText : AppColors.lossText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, PnlFilter targetFilter) {
    final isSelected = _filter == targetFilter;
    return GestureDetector(
      onTap: () => setState(() => _filter = targetFilter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
