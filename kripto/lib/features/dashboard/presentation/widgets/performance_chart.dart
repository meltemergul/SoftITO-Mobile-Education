import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

class PerformanceChart extends StatelessWidget {
  final String period;

  const PerformanceChart({
    super.key,
    this.period = '1G',
  });

  List<FlSpot> get _spots {
    switch (period) {
      case '1H':
        return const [
          FlSpot(0, 1.0),
          FlSpot(1, 1.08),
          FlSpot(2, 1.05),
          FlSpot(3, 1.20),
          FlSpot(4, 1.15),
          FlSpot(5, 1.35),
          FlSpot(6, 1.42),
        ];
      case '1A':
        return const [
          FlSpot(0, 1.0),
          FlSpot(1, 1.25),
          FlSpot(2, 1.18),
          FlSpot(3, 1.45),
          FlSpot(4, 1.60),
          FlSpot(5, 1.52),
          FlSpot(6, 1.85),
          FlSpot(7, 2.10),
        ];
      case '1G':
      default:
        return const [
          FlSpot(0, 1.0),
          FlSpot(1, 1.15),
          FlSpot(2, 1.08),
          FlSpot(3, 1.30),
          FlSpot(4, 1.22),
          FlSpot(5, 1.40),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPaddingCompact,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.borderCard),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.surface2,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: _spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 2.2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.22),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
