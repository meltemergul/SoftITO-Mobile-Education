// Girişim360 — Durum ve Demo Rozeti Bileşeni

import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  factory StatusBadge.demo({Key? key, String label = 'Demo Veri'}) {
    return StatusBadge(
      key: key,
      label: label,
      icon: Icons.science_outlined,
      backgroundColor: const Color(0xFF0F3D5E),
      textColor: const Color(0xFF7DD3FC),
    );
  }

  factory StatusBadge.success({Key? key, required String label}) {
    return StatusBadge(
      key: key,
      label: label,
      icon: Icons.check_circle_outline,
      backgroundColor: const Color(0xFF064E3B),
      textColor: const Color(0xFF6EE7B7),
    );
  }

  factory StatusBadge.warning({Key? key, required String label}) {
    return StatusBadge(
      key: key,
      label: label,
      icon: Icons.schedule_outlined,
      backgroundColor: const Color(0xFF78350F),
      textColor: const Color(0xFFFDE68A),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bg = backgroundColor ?? colorScheme.secondaryContainer;
    final fg = textColor ?? colorScheme.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
