import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../domain/entities/user_profile_entity.dart';

class QuickMetricsCard extends StatelessWidget {
  const QuickMetricsCard({
    super.key,
    required this.profile,
  });

  final UserProfileEntity profile;

  Widget _buildMetricItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    final colors = context.colors;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s12,
          horizontal: AppSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              value,
              style: AppTypography.heading.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: colors.textTertiary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          _buildMetricItem(
            context: context,
            icon: Icons.local_fire_department_rounded,
            iconColor: colors.streak,
            value: '${profile.bestStreak} Gün',
            label: 'En İyi Seri',
          ),
          const SizedBox(width: AppSpacing.s8),
          _buildMetricItem(
            context: context,
            icon: Icons.track_changes_rounded,
            iconColor: colors.primary,
            value: '${profile.totalGoals}',
            label: 'Toplam Hedef',
          ),
          const SizedBox(width: AppSpacing.s8),
          _buildMetricItem(
            context: context,
            icon: Icons.shield_rounded,
            iconColor: colors.primaryStrong,
            value: 'Seviye ${profile.level}',
            label: 'Mevcut Seviye',
          ),
        ],
      ),
    );
  }
}
