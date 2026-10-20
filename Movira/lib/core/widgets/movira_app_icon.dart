import 'package:flutter/material.dart';

/// Movira Özel App İkonu ve Logo Bileşeni (PROJECT.md & design/SKILL.md)
/// Material 3 uyumlu, kırmızı monogram ve aerodinamik hareket hissini yansıtır.
class MoviraAppIcon extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool showBorder;
  final bool showShadow;

  const MoviraAppIcon({
    super.key,
    this.size = 36,
    this.borderRadius = 10,
    this.showBorder = true,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C0A0A) : const Color(0xFF800000),
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                width: 1.5,
              )
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: Image.asset(
          'assets/images/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Görsel yüklenemezse zarif yedek logo çizimi
            return Container(
              color: const Color(0xFFDC2626),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.directions_car_filled,
                    size: size * 0.55,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  Text(
                    'M',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.55,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
