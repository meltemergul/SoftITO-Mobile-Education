import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/badge_entity.dart';
import 'badge_detail_sheet.dart';

class BadgeItemCard extends StatelessWidget {
  const BadgeItemCard({
    super.key,
    required this.badge,
  });

  final BadgeEntity badge;

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'whatshot':
        return Icons.whatshot_rounded;
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'directions_run':
        return Icons.directions_run_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'self_improvement':
        return Icons.self_improvement_rounded;
      case 'military_tech':
        return Icons.military_tech_rounded;
      case 'flag_circle':
        return Icons.flag_circle_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  Color _getCategoryColor(BuildContext context, String category) {
    final colors = context.colors;
    switch (category) {
      case 'streak':
        return colors.streak;
      case 'sport':
        return colors.sport;
      case 'mind':
        return colors.mind;
      default:
        return colors.primary;
    }
  }

  String _formatDateShort(String? dateStr) {
    if (dateStr == null || dateStr.length < 10) return '';
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final months = ['', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
        final monthIdx = int.tryParse(parts[1]) ?? 0;
        final monthName = monthIdx > 0 && monthIdx <= 12 ? months[monthIdx] : parts[1];
        return '${int.tryParse(parts[2]) ?? parts[2]} $monthName ${parts[0]}';
      }
    } catch (_) {}
    return dateStr;
  }

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BadgeDetailSheet(badge: badge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final catColor = _getCategoryColor(context, badge.category);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s8),
      backgroundColor: colors.surface,
      borderColor: badge.isUnlocked
          ? catColor.withValues(alpha: 0.3)
          : colors.border,
      onTap: () => _showDetailSheet(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rozet İkonu
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badge.isUnlocked
                      ? catColor.withValues(alpha: 0.15)
                      : colors.border.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: badge.isUnlocked
                        ? catColor
                        : colors.border,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _getIconData(badge.icon),
                  color: badge.isUnlocked
                      ? catColor
                      : colors.textTertiary,
                  size: 26,
                ),
              ),
              if (!badge.isUnlocked)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border),
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 12,
                      color: colors.textTertiary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          // Rozet Adı
          Text(
            badge.name,
            style: AppTypography.caption.copyWith(
              color: badge.isUnlocked ? colors.textPrimary : colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.s4),
          // Durum / İlerleme / XP
          if (badge.isUnlocked) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: AppRadius.pillRadius,
              ),
              child: Text(
                '+${badge.xpReward} XP',
                style: AppTypography.caption.copyWith(
                  color: colors.primaryStrong,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
            if (badge.unlockedAt != null) ...[
              const SizedBox(height: 2),
              Text(
                _formatDateShort(badge.unlockedAt),
                style: AppTypography.caption.copyWith(
                  color: colors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ] else ...[
            Text(
              badge.progress > 0
                  ? (badge.targetValue > 15
                      ? '${badge.progress}/${badge.maxProgress}'
                      : '%${badge.progressPercent}')
                  : 'Kilitli',
              style: AppTypography.caption.copyWith(
                color: badge.progress > 0 ? catColor : colors.textTertiary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            ClipRRect(
              borderRadius: AppRadius.pillRadius,
              child: SizedBox(
                width: 60,
                height: 4,
                child: LinearProgressIndicator(
                  value: (badge.progressPercent / 100).clamp(0.0, 1.0),
                  backgroundColor: colors.border.withValues(alpha: 0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(catColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
