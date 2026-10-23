import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../domain/entities/badge_entity.dart';

class BadgeDetailSheet extends StatelessWidget {
  const BadgeDetailSheet({
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

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.length < 10) return '';
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final months = [
          '',
          'Ocak',
          'Şubat',
          'Mart',
          'Nisan',
          'Mayıs',
          'Haziran',
          'Temmuz',
          'Ağustos',
          'Eylül',
          'Ekim',
          'Kasım',
          'Aralık'
        ];
        final monthIdx = int.tryParse(parts[1]) ?? 0;
        final monthName = monthIdx > 0 && monthIdx <= 12 ? months[monthIdx] : parts[1];
        return '${parts[2]} $monthName ${parts[0]}';
      }
    } catch (_) {}
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final catColor = _getCategoryColor(context, badge.category);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s20),
          // Rozet Büyük İkonu
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: badge.isUnlocked
                  ? catColor.withValues(alpha: 0.15)
                  : colors.border.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: Border.all(
                color: badge.isUnlocked ? catColor : colors.border,
                width: 2,
              ),
            ),
            child: Icon(
              _getIconData(badge.icon),
              color: badge.isUnlocked ? catColor : colors.textTertiary,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          // Başlık
          Text(
            badge.name,
            style: AppTypography.title.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s8),
          // Açıklama
          Text(
            badge.description,
            style: AppTypography.body.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s20),
          // Durum ve İlerleme Kartı
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: AppRadius.cardRadius,
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Durum',
                      style: AppTypography.caption.copyWith(color: colors.textTertiary),
                    ),
                    Text(
                      badge.isUnlocked ? 'Kazanıldı ✓' : 'Kilitli',
                      style: AppTypography.caption.copyWith(
                        color: badge.isUnlocked ? colors.primaryStrong : colors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kazanılacak XP',
                      style: AppTypography.caption.copyWith(color: colors.textTertiary),
                    ),
                    Text(
                      '+${badge.xpReward} XP',
                      style: AppTypography.caption.copyWith(
                        color: colors.streak,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (badge.isUnlocked && badge.unlockedAt != null) ...[
                  const SizedBox(height: AppSpacing.s8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Açılma Tarihi',
                        style: AppTypography.caption.copyWith(color: colors.textTertiary),
                      ),
                      Text(
                        _formatDate(badge.unlockedAt),
                        style: AppTypography.caption.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                if (!badge.isUnlocked) ...[
                  const SizedBox(height: AppSpacing.s12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'İlerleme',
                        style: AppTypography.caption.copyWith(color: colors.textTertiary),
                      ),
                      Text(
                        '${badge.progress} / ${badge.maxProgress} ${badge.unit} (%${badge.progressPercent})',
                        style: AppTypography.caption.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  ClipRRect(
                    borderRadius: AppRadius.pillRadius,
                    child: LinearProgressIndicator(
                      value: (badge.progressPercent / 100).clamp(0.0, 1.0),
                      backgroundColor: colors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(catColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          // Kapat butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryStrong,
                foregroundColor: colors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                shape: const StadiumBorder(),
                minimumSize: const Size(double.infinity, AppSpacing.minTouchTarget),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Kapat',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textOnPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
