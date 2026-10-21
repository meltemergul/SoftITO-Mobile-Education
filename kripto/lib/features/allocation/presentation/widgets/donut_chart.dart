import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/formatters.dart';
import '../../../portfolio/domain/position.dart';

class DonutChart extends StatefulWidget {
  final List<Position> positions;
  final Decimal totalValue;
  final String currency;
  final ValueChanged<Position>? onPositionSelected;

  const DonutChart({
    super.key,
    required this.positions,
    required this.totalValue,
    required this.currency,
    this.onPositionSelected,
  });

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> {
  int _touchedIndex = -1;

  static const List<Color> _sliceColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.profit,
    Color(0xFFA78BFA), // Mor
    Color(0xFFF59E0B), // Amber
    Color(0xFFF472B6), // Pembe
    Color(0xFF38BDF8), // Açık mavi
    AppColors.surface3,
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.positions.isEmpty || widget.totalValue <= Decimal.zero) {
      return SizedBox(
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 65,
                sections: [
                  PieChartSectionData(
                    color: AppColors.surface3,
                    value: 100,
                    title: '',
                    radius: 18,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('0.00', style: AppTextStyles.labelNumericLg),
                Text('Toplam Varlık', style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
      );
    }

    final totalD = widget.totalValue.toDouble();
    final sections = <PieChartSectionData>[];

    for (int i = 0; i < widget.positions.length; i++) {
      final pos = widget.positions[i];
      final isTouched = i == _touchedIndex;
      final valD = pos.currentValue.toDouble();
      final percentage = totalD > 0 ? (valD / totalD) * 100 : 0.0;
      final color = _sliceColors[i % _sliceColors.length];

      sections.add(
        PieChartSectionData(
          color: color,
          value: valD > 0 ? valD : 1,
          title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
          radius: isTouched ? 26 : 20,
          titleStyle: AppTextStyles.labelSm.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    if (_touchedIndex >= 0 && _touchedIndex < widget.positions.length) {
                      widget.onPositionSelected?.call(widget.positions[_touchedIndex]);
                    }
                  });
                },
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 65,
              sections: sections,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      AppFormatters.formatCurrency(widget.totalValue, widget.currency),
                      style: AppTextStyles.labelNumericLg.copyWith(fontSize: 20),
                      maxLines: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'TOPLAM DEĞER',
                  style: AppTextStyles.caption.copyWith(letterSpacing: 1, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
