import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/formatters.dart';
import '../../../../shared/widgets/pnl_badge.dart';

/// Konsolide Bakiye Kartı (SKILL.md §4.1)
/// Toplam değer, 24s net değişim (tutar + %), tüm zamanlar PnL ve gizlilik toggle'ı.
class PortfolioSummaryCard extends StatelessWidget {
  final Decimal totalValue;
  final Decimal change24hAmount;
  final Decimal change24hPercentage;
  final Decimal allTimePnl;
  final Decimal allTimePnlPercentage;
  final String selectedCurrency;
  final ValueChanged<String> onCurrencyChanged;
  final bool isPrivate;
  final VoidCallback onPrivacyToggle;

  const PortfolioSummaryCard({
    super.key,
    required this.totalValue,
    required this.change24hAmount,
    required this.change24hPercentage,
    required this.allTimePnl,
    required this.allTimePnlPercentage,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
    required this.isPrivate,
    required this.onPrivacyToggle,
  });

  static const _mask = '••••••';

  String _money(Decimal v, {bool signed = false}) {
    if (isPrivate) return _mask;
    final formatted = AppFormatters.formatCurrency(v.abs(), selectedCurrency);
    if (!signed || v == Decimal.zero) return formatted;
    return v > Decimal.zero ? '+$formatted' : '-$formatted';
  }

  Color _pnlColor(Decimal v) {
    if (v > Decimal.zero) return AppColors.profitText;
    if (v < Decimal.zero) return AppColors.lossText;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.borderCard),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2236), AppColors.surface1],
        ),
      ),
      child: Stack(
        children: [
          // Cyan ışıma
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xlg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Toplam Portföy Değeri',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          _PrivacyButton(isPrivate: isPrivate, onTap: onPrivacyToggle),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _CurrencySwitch(
                      selected: selectedCurrency,
                      onChanged: onCurrencyChanged,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _money(totalValue),
                      key: ValueKey('$isPrivate-$totalValue-$selectedCurrency'),
                      style: AppTextStyles.displayBalance,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _money(change24hAmount, signed: true),
                        style: AppTextStyles.numeric(
                          fontSize: 14,
                          color: _pnlColor(change24hAmount),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    PnlBadge(percentage: change24hPercentage),
                    const SizedBox(width: AppSpacing.sm),
                    Text('24s', style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(height: 1, color: AppColors.borderDivider),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 4,
                      child: Text(
                        'Tüm Zamanlar PnL',
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      flex: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              _money(allTimePnl, signed: true),
                              style: AppTextStyles.numeric(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _pnlColor(allTimePnl),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          PnlBadge(percentage: allTimePnlPercentage),
                        ],
                      ),
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
}

class _PrivacyButton extends StatelessWidget {
  final bool isPrivate;
  final VoidCallback onTap;

  const _PrivacyButton({required this.isPrivate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isPrivate ? 'Tutarları göster' : 'Tutarları gizle',
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            isPrivate ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CurrencySwitch extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _CurrencySwitch({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: AppSpacing.roundedPill,
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['USD', 'TRY'].map((c) {
          final isSelected = c == selected;
          return GestureDetector(
            onTap: () => onChanged(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: AppSpacing.roundedPill,
              ),
              child: Text(
                c,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.primaryBright : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
