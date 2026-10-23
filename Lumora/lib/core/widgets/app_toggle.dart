import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/dimensions.dart';
import '../theme/typography.dart';

class AppToggle extends StatelessWidget {
  const AppToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.time,
    this.onTimeTap,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? title;
  final String? subtitle;
  final String? time;
  final VoidCallback? onTimeTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget switchWidget = Semantics(
      toggled: value,
      label: title ?? 'Aç/Kapa anahtarı',
      child: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: colors.textOnPrimary,
        activeTrackColor: colors.primaryStrong,
        inactiveThumbColor: colors.textSecondary,
        inactiveTrackColor: colors.inactive,
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => Colors.transparent,
        ),
      ),
    );

    if (title == null) {
      return switchWidget;
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title!,
                style: AppTypography.body.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.s4),
                Text(
                  subtitle!,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (time != null) ...[
          Semantics(
            button: true,
            label: '$title hatırlatma saati: $time. Değiştirmek için dokunun.',
            child: InkWell(
              onTap: onTimeTap,
              borderRadius: AppRadius.pillRadius,
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: AppSpacing.minTouchTarget,
                  minWidth: AppSpacing.minTouchTarget,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12,
                  vertical: AppSpacing.s8,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.inactive,
                  borderRadius: AppRadius.pillRadius,
                ),
                child: Text(
                  time!,
                  style: AppTypography.caption.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
        ],
        switchWidget,
      ],
    );
  }
}
