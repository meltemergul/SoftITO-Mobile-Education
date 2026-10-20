// Girişim360 — Ortak Profil ve Fotoğraf Bileşeni (design/SKILL.md)
// Bozulmayan en-boy oranı, rozet hizalaması ve zarif geçişler

import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool isVerified;
  final IconData? fallbackIcon;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 48,
    this.isVerified = false,
    this.fallbackIcon,
    this.backgroundColor,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'G';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bg = backgroundColor ?? colorScheme.primaryContainer;
    final fg = colorScheme.onPrimaryContainer;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildFallback(fg),
                  )
                : _buildFallback(fg),
          ),
        ),
        if (isVerified)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified,
                size: (size * 0.35).clamp(14.0, 20.0),
                color: colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallback(Color fg) {
    if (fallbackIcon != null) {
      return Center(
        child: Icon(fallbackIcon, size: size * 0.5, color: fg),
      );
    }
    return Center(
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
