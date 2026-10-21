import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/formatters.dart';
import '../../../portfolio/domain/cost_calculator.dart';
import '../../../portfolio/domain/position.dart';

/// Anasayfa İşlem Verimliliği Kartı
/// Kullanıcının işlem başarı oranını (Win Rate), kâr faktörünü,
/// kârlı/zararlı işlem dağılımını ve net verimliliğini gösterir.
class TradeEfficiencyCard extends StatelessWidget {
  final List<RealizedSalePnl> sales;
  final List<Position> positions;
  final int totalTransactionsCount;
  final String currency;
  final VoidCallback onDetailsTap;

  const TradeEfficiencyCard({
    super.key,
    required this.sales,
    required this.positions,
    required this.totalTransactionsCount,
    required this.currency,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Gerçekleşmiş satışlar varsa onlardan metrik çıkar
    final hasSales = sales.isNotEmpty;

    int winningTrades = 0;
    int losingTrades = 0;
    double grossProfit = 0;
    double grossLoss = 0;

    if (hasSales) {
      for (final s in sales) {
        final pnl = s.netPnl.toDouble();
        if (pnl > 0) {
          winningTrades++;
          grossProfit += pnl;
        } else if (pnl < 0) {
          losingTrades++;
          grossLoss += pnl.abs();
        }
      }
    } else {
      // Satış yoksa mevcut açık pozisyonların kâr/zarar durumuna bak
      for (final p in positions) {
        final pnl = p.unrealizedPnl.toDouble();
        if (pnl > 0) {
          winningTrades++;
          grossProfit += pnl;
        } else if (pnl < 0) {
          losingTrades++;
          grossLoss += pnl.abs();
        }
      }
    }

    final countedTrades = winningTrades + losingTrades;
    final winRate = countedTrades > 0 ? (winningTrades / countedTrades * 100) : 0.0;
    final profitFactor = grossLoss > 0
        ? (grossProfit / grossLoss)
        : (grossProfit > 0 ? 9.99 : (countedTrades > 0 ? 1.0 : 0.0));
    final netPnl = grossProfit - grossLoss;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.borderCard),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F1E2E),
            AppColors.surface1,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kart Başlığı & Detay Butonu
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.auto_graph_rounded,
                  color: AppColors.primaryBright,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İşlem Verimliliği',
                      style: AppTextStyles.headlineSm.copyWith(fontSize: 15),
                    ),
                    Text(
                      hasSales ? 'Kapanan İşlemler Başarısı' : 'Açık Pozisyonlar Verimliliği',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onDetailsTap,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Geçmiş',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.primaryBright,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right, size: 16, color: AppColors.primaryBright),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Metrik Grid (4 Kutucuk)
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  title: 'Kazanma Oranı',
                  value: countedTrades > 0 ? '%${winRate.toStringAsFixed(1)}' : '—',
                  sub: '$winningTrades Kârlı / $countedTrades İşlem',
                  valColor: winRate >= 50 ? AppColors.profitText : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildMetricBox(
                  title: 'Kâr Faktörü',
                  value: countedTrades > 0 ? profitFactor.toStringAsFixed(2) : '—',
                  sub: profitFactor >= 1.5
                      ? 'Yüksek Başarı'
                      : (profitFactor >= 1.0 ? 'Pozitif' : 'Geliştirilebilir'),
                  valColor: profitFactor >= 1.0 ? AppColors.profitText : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  title: hasSales ? 'Gerçekleşen K/Z' : 'Net K/Z',
                  value: AppFormatters.formatCurrency(
                    Decimal.parse(netPnl.abs().toStringAsFixed(2)),
                    currency,
                  ),
                  prefix: netPnl > 0 ? '+' : (netPnl < 0 ? '-' : ''),
                  sub: hasSales ? '${sales.length} Satış Kapanışı' : '${positions.length} Açık Pozisyon',
                  valColor: netPnl >= 0 ? AppColors.profitText : AppColors.lossText,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildMetricBox(
                  title: 'Toplam İşlem',
                  value: '$totalTransactionsCount',
                  sub: 'Kayıtlı Emir',
                  valColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Görsel Verimlilik Çubuğu (Kazanma / Kaybetme Oranı)
          if (countedTrades > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: [
                    Expanded(
                      flex: (winRate * 10).round().clamp(1, 1000),
                      child: Container(color: AppColors.profit),
                    ),
                    Expanded(
                      flex: ((100 - winRate) * 10).round().clamp(1, 1000),
                      child: Container(color: AppColors.loss),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kârlı (%${winRate.toStringAsFixed(0)})',
                  style: AppTextStyles.caption.copyWith(color: AppColors.profitText, fontSize: 11),
                ),
                Text(
                  'Zararlı (%${(100 - winRate).toStringAsFixed(0)})',
                  style: AppTextStyles.caption.copyWith(color: AppColors.lossText, fontSize: 11),
                ),
              ],
            ),
          ] else ...[
            Text(
              'İşlem ekledikçe verimlilik ve kâr faktörünüz otomatik hesaplanır.',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricBox({
    required String title,
    required String value,
    String? prefix,
    required String sub,
    required Color valColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface2.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            '${prefix ?? ''}$value',
            style: AppTextStyles.labelNumericMd.copyWith(
              color: valColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
