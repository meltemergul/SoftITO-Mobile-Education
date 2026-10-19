import 'package:flutter/material.dart';

import '../../../core/extensions/date_extension.dart';
import '../models/donation_statistics_model.dart';

/// Paket bağımlılığı olmayan, dokunarak ay seçilebilen çubuk grafik.
class MonthlyBarChart extends StatelessWidget {
  final List<MonthlyDonationModel> data;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  const MonthlyBarChart({
    super.key,
    required this.data,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final maxCount = data.fold<int>(1, (m, e) => e.count > m ? e.count : m);

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < data.length; i++)
            Expanded(
              child: _Bar(
                label: data[i].month.shortMonthTr,
                ratio: data[i].count / maxCount,
                isSelected: i == selectedIndex,
                onTap: () => onSelect(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double ratio;
  final bool isSelected;
  final VoidCallback onTap;

  const _Bar({
    required this.label,
    required this.ratio,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = isSelected ? colors.primary : colors.primary.withAlpha(90);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: 160 * ratio,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [color.withAlpha(140), color],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
