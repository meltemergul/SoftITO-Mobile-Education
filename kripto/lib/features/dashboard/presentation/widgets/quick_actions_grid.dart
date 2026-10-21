import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  const QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });
}

/// Hızlı Aksiyonlar: 4'lü buton ızgarası (SKILL.md §4.1)
class QuickActionsGrid extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionsGrid({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(child: _QuickActionButton(action: actions[i])),
        ],
      ],
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  final QuickAction action;

  const _QuickActionButton({required this.action});

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.action;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: a.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface1,
            borderRadius: AppSpacing.roundedCard,
            border: Border.all(
              color: a.highlighted ? AppColors.borderCyanFocus : AppColors.borderCard,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: a.highlighted
                      ? AppColors.primaryBright
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: AppSpacing.roundedButton,
                  boxShadow: a.highlighted
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  a.icon,
                  size: 20,
                  color: a.highlighted ? AppColors.canvas : AppColors.primaryBright,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                a.label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
