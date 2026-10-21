import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

class GlassSheet extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusSheet)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.surface2.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusSheet)),
            border: const Border(
              top: BorderSide(color: AppColors.borderSheet, width: 1),
              left: BorderSide(color: AppColors.borderSheet, width: 1),
              right: BorderSide(color: AppColors.borderSheet, width: 1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
