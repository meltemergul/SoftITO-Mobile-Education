import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_pill_button.dart';

class CelebrationDialog extends StatefulWidget {
  const CelebrationDialog({
    super.key,
    required this.onDismiss,
  });

  final VoidCallback onDismiss;

  @override
  State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    Widget content = Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
      ),
      backgroundColor: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [colors.primary, colors.primaryStrong],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Günün Serisi Tamamlandı! 🎉',
              textAlign: TextAlign.center,
              style: AppTypography.heading.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Bugün için planlanan tüm hedefleri tamamladın. Zincirini başarıyla korudun!',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.s16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s8,
              ),
              decoration: BoxDecoration(
                color: colors.streak.withValues(alpha: 0.12),
                borderRadius: AppRadius.pillRadius,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars_rounded, color: colors.streakStrong, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Gün Sonu Serisi Bonusu: +50 XP',
                    style: AppTypography.caption.copyWith(
                      color: colors.streakStrong,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            AppPillButton(
              label: 'Harika!',
              isFullWidth: true,
              onPressed: widget.onDismiss,
            ),
          ],
        ),
      ),
    );

    if (disableAnimations) {
      return content;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: content,
    );
  }
}
