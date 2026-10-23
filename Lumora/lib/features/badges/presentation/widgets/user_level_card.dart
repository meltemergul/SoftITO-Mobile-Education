import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/user_level_entity.dart';

class UserLevelCard extends StatelessWidget {
  const UserLevelCard({
    super.key,
    required this.level,
  });

  final UserLevelEntity level;

  String _formatNumber(int number) {
    if (number >= 1000) {
      final thousands = number ~/ 1000;
      final remainder = (number % 1000).toString().padLeft(3, '0');
      return '$thousands.$remainder';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s20),
      backgroundColor: colors.surface,
      borderColor: colors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Seviye Kalkanı Görseli
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary,
                      colors.primaryStrong,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${level.level}',
                          style: AppTypography.title.copyWith(
                            color: colors.primaryStrong,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              // Seviye ve Başlık
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seviye ${level.level}: ${level.title}',
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 16,
                          color: colors.streak,
                        ),
                        const SizedBox(width: AppSpacing.s4),
                        Text(
                          'Toplam ${_formatNumber(level.totalXp)} XP',
                          style: AppTypography.caption.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          // XP İlerleme Çubuğu ve Metinleri
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sonraki Seviye',
                style: AppTypography.caption.copyWith(
                  color: colors.textTertiary,
                ),
              ),
              Text(
                '${_formatNumber(level.currentLevelXp)} / ${_formatNumber(level.nextLevelXp)} XP (%${level.progressPercent})',
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
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: (level.progressPercent / 100).clamp(0.0, 1.0),
                backgroundColor: colors.border.withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
