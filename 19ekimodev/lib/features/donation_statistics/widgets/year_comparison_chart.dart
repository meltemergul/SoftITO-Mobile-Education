import 'package:flutter/material.dart';

import '../models/donation_statistics_model.dart';

/// Bu yıl / geçen yıl karşılaştırmalı hafif çizgi grafik (CustomPainter).
class YearComparisonChart extends StatelessWidget {
  final List<MonthlyDonationModel> data;

  const YearComparisonChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          height: 160,
          width: double.infinity,
          child: CustomPaint(
            painter: _LinePainter(
              current: [for (final m in data) m.count.toDouble()],
              previous: [for (final m in data) m.previousYearCount.toDouble()],
              currentColor: colors.primary,
              previousColor: colors.secondary,
              gridColor: colors.onSurface.withAlpha(25),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Legend(color: colors.primary, label: 'Bu yıl'),
            const SizedBox(width: 20),
            _Legend(color: colors.secondary, label: 'Geçen yıl'),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> current;
  final List<double> previous;
  final Color currentColor;
  final Color previousColor;
  final Color gridColor;

  _LinePainter({
    required this.current,
    required this.previous,
    required this.currentColor,
    required this.previousColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (current.length < 2) return;
    final all = [...current, ...previous];
    final minV = all.reduce((a, b) => a < b ? a : b) * 0.95;
    final maxV = all.reduce((a, b) => a > b ? a : b) * 1.02;

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    Offset point(int i, double v) => Offset(
      size.width * i / (current.length - 1),
      size.height - (v - minV) / (maxV - minV) * size.height,
    );

    _drawLine(canvas, previous, point, previousColor, dashed: true);
    _drawLine(canvas, current, point, currentColor);
  }

  void _drawLine(
    Canvas canvas,
    List<double> values,
    Offset Function(int, double) point,
    Color color, {
    bool dashed = false,
  }) {
    final path = Path()..moveTo(point(0, values[0]).dx, point(0, values[0]).dy);
    for (var i = 1; i < values.length; i++) {
      final p = point(i, values[i]);
      path.lineTo(p.dx, p.dy);
    }
    final paint = Paint()
      ..color = dashed ? color.withAlpha(170) : color
      ..strokeWidth = dashed ? 2 : 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
    if (!dashed) {
      final dot = Paint()..color = color;
      for (var i = 0; i < values.length; i++) {
        canvas.drawCircle(point(i, values[i]), 3, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.current != current ||
      old.previous != previous ||
      old.currentColor != currentColor;
}
