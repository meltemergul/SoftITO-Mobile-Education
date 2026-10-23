import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/badge_entity.dart';

class NextThresholdCard extends StatelessWidget {
  const NextThresholdCard({
    super.key,
    required this.nextBadge,
    required this.hasAnyUnlocked,
  });

  final BadgeEntity? nextBadge;
  final bool hasAnyUnlocked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (nextBadge == null) {
      if (hasAnyUnlocked) {
        // Tüm rozetler tamamlandı
        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.s16),
          backgroundColor: colors.surface,
          child: Row(
            children: [
              Icon(Icons.workspace_premium_rounded, color: colors.primary, size: 32),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tüm Rozetler Açıldı! 🏆',
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Harika bir disiplin yolculuğu sergiledin.',
                      style: AppTypography.caption.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    final remaining = nextBadge!.maxProgress - nextBadge!.progress;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      backgroundColor: colors.surface,
      borderColor: hasAnyUnlocked ? colors.border : colors.primary.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s8),
                decoration: BoxDecoration(
                  color: (hasAnyUnlocked ? colors.streak : colors.primary).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasAnyUnlocked ? Icons.flag_rounded : Icons.star_rounded,
                  color: hasAnyUnlocked ? colors.streak : colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasAnyUnlocked ? 'Sonraki Büyük Eşik' : 'İlk Büyük Eşik (Başlangıç)',
                      style: AppTypography.caption.copyWith(
                        color: hasAnyUnlocked ? colors.streak : colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nextBadge!.name,
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.pillRadius,
                ),
                child: Text(
                  '+${nextBadge!.xpReward} XP',
                  style: AppTypography.caption.copyWith(
                    color: colors.primaryStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            !hasAnyUnlocked
                ? "'${nextBadge!.name}' rozetini açmak ve ilk XP'ni kazanmak için bugün bir alışkanlığını tamamla!"
                : "'${nextBadge!.name}' rozetini açmak için $remaining ${nextBadge!.unit} daha tamamla!",
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: AppRadius.pillRadius,
                  child: SizedBox(
                    height: 6,
                    child: LinearProgressIndicator(
                      value: (nextBadge!.progressPercent / 100).clamp(0.0, 1.0),
                      backgroundColor: colors.border.withValues(alpha: 0.5),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        hasAnyUnlocked ? colors.streak : colors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Text(
                '${nextBadge!.progress}/${nextBadge!.maxProgress}',
                style: AppTypography.caption.copyWith(
                  color: colors.textTertiary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
