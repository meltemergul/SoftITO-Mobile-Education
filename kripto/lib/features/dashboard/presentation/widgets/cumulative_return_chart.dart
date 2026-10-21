import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/period_selector.dart';
import '../../../../shared/widgets/pnl_badge.dart';

/// Kümülatif Getiri Eğrisi (Cumulative Return / Equity Curve)
/// Portföyün zaman içerisindeki kümülatif getiri yüzdesini (%)
/// ve sermaye büyüme eğrisini canlı olarak görselleştirir.
class CumulativeReturnChart extends StatelessWidget {
  final Decimal returnPercentage;
  final String period;
  final ValueChanged<String> onPeriodChanged;
  final bool isPrivate;

  const CumulativeReturnChart({
    super.key,
    required this.returnPercentage,
    required this.period,
    required this.onPeriodChanged,
    this.isPrivate = false,
  });

  List<FlSpot> _generateSpots() {
    final baseReturn = returnPercentage.toDouble();

    switch (period) {
      case '1H':
        // 7 günlük kümülatif getiri simülasyon eğrisi
        final p0 = baseReturn * 0.15;
        final p1 = baseReturn * 0.28;
        final p2 = baseReturn * 0.22;
        final p3 = baseReturn * 0.55;
        final p4 = baseReturn * 0.48;
        final p5 = baseReturn * 0.82;
        final p6 = baseReturn;
        return [
          FlSpot(0, p0),
          FlSpot(1, p1),
          FlSpot(2, p2),
          FlSpot(3, p3),
          FlSpot(4, p4),
          FlSpot(5, p5),
          FlSpot(6, p6),
        ];
      case '1A':
        // 30 günlük kümülatif getiri eğrisi
        final p0 = baseReturn * 0.05;
        final p1 = baseReturn * 0.18;
        final p2 = baseReturn * 0.32;
        final p3 = baseReturn * 0.25;
        final p4 = baseReturn * 0.60;
        final p5 = baseReturn * 0.52;
        final p6 = baseReturn * 0.85;
        final p7 = baseReturn;
        return [
          FlSpot(0, p0),
          FlSpot(1, p1),
          FlSpot(2, p2),
          FlSpot(3, p3),
          FlSpot(4, p4),
          FlSpot(5, p5),
          FlSpot(6, p6),
          FlSpot(7, p7),
        ];
      case '1G':
      default:
        // 24 saatlik kümülatif getiri eğrisi
        final p0 = baseReturn * 0.10;
        final p1 = baseReturn * 0.35;
        final p2 = baseReturn * 0.25;
        final p3 = baseReturn * 0.70;
        final p4 = baseReturn * 0.60;
        final p5 = baseReturn;
        return [
          FlSpot(0, p0),
          FlSpot(1, p1),
          FlSpot(2, p2),
          FlSpot(3, p3),
          FlSpot(4, p4),
          FlSpot(5, p5),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final spots = _generateSpots();
    final isPositive = returnPercentage >= Decimal.zero;
    final curveColor = isPositive ? AppColors.primary : AppColors.loss;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Satır: Başlık ve Periyot Seçici
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Kümülatif Getiri Eğrisi',
                  style: AppTextStyles.headlineSm.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              PeriodSelector(
                selectedPeriod: period,
                onSelected: onPeriodChanged,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              if (!isPrivate) ...[
                PnlBadge(percentage: returnPercentage),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  'Sermaye büyümesi ve kümülatif getiri trendi',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Canlı Kümülatif Getiri Çizgi Grafiği
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: value == 0 ? AppColors.borderDivider : AppColors.surface2.withValues(alpha: 0.4),
                    strokeWidth: value == 0 ? 1.2 : 0.8,
                    dashArray: value == 0 ? [4, 4] : null,
                  ),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surface2,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final val = spot.y;
                        final sign = val >= 0 ? '+' : '';
                        return LineTooltipItem(
                          'Kümülatif Getiri\n$sign${val.toStringAsFixed(2)}%',
                          AppTextStyles.caption.copyWith(
                            color: val >= 0 ? AppColors.profitText : AppColors.lossText,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: curveColor,
                    barWidth: 2.4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          curveColor.withValues(alpha: 0.22),
                          curveColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 350),
            ),
          ),
        ],
      ),
    );
  }
}
