import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/donation_center_model.dart';

class DonationCenterCard extends StatelessWidget {
  final DonationCenterModel center;

  const DonationCenterCard({super.key, required this.center});

  Color get _occupancyColor {
    if (center.occupancy >= 0.8) return AppColors.critical;
    if (center.occupancy >= 0.5) return AppColors.warning;
    return AppColors.eligible;
  }

  IconData get _typeIcon {
    switch (center.type) {
      case CenterType.kizilay:
        return Icons.local_hospital;
      case CenterType.hospital:
        return Icons.apartment;
      case CenterType.mobile:
        return Icons.airport_shuttle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _occupancyColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_typeIcon, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    center.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _OpenBadge(isOpen: center.isOpen),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${center.address} • ${center.distanceKm.toStringAsFixed(1)} km',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              'Çalışma saatleri: ${center.workingHours}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            _OccupancyBar(
              value: center.occupancy,
              color: color,
              wait: center.estimatedWaitMinutes,
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  final bool isOpen;

  const _OpenBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? AppColors.eligible : AppColors.ineligible;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOpen ? 'Açık' : 'Kapalı',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _OccupancyBar extends StatelessWidget {
  final double value;
  final Color color;
  final int wait;

  const _OccupancyBar({
    required this.value,
    required this.color,
    required this.wait,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Doluluk %${(value * 100).round()}',
              style: textTheme.labelMedium,
            ),
            Text(
              '~$wait dk bekleme',
              style: textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            color: color,
            backgroundColor: color.withAlpha(38),
          ),
        ),
      ],
    );
  }
}
