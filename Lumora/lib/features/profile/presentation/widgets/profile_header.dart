import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onEditPressed,
  });

  final UserProfileEntity profile;
  final VoidCallback onEditPressed;

  String _formatJoinDate(String createdAt) {
    if (createdAt.length < 7) return '';
    try {
      final parts = createdAt.slice(0, 10).split('-');
      final year = parts[0];
      final monthIndex = int.tryParse(parts[1]) ?? 0;
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
      final monthName = monthIndex > 0 && monthIndex <= 12 ? months[monthIndex] : '';
      return '$monthName $year\'den beri üye';
    } catch (_) {
      return '';
    }
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final joinText = _formatJoinDate(profile.createdAt);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primary,
                  colors.primaryStrong,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _getInitials(profile.displayName),
              style: AppTypography.title.copyWith(
                color: colors.textOnPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          // Kullanıcı Bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.displayName,
                        style: AppTypography.title.copyWith(
                          color: colors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (profile.isGuest)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.streak.withValues(alpha: 0.15),
                          borderRadius: AppRadius.pillRadius,
                        ),
                        child: Text(
                          'Misafir',
                          style: AppTypography.caption.copyWith(
                            color: colors.streakStrong,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  profile.username != null && profile.username!.isNotEmpty
                      ? '@${profile.username}'
                      : (profile.email ?? ''),
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (joinText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: colors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Text(
                        joinText,
                        style: AppTypography.caption.copyWith(
                          color: colors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: colors.textSecondary,
            tooltip: 'Profili Düzenle',
            onPressed: onEditPressed,
          ),
        ],
      ),
    );
  }
}

extension on String {
  String slice(int start, [int? end]) {
    final actualEnd = end != null && end < length ? end : length;
    return substring(start, actualEnd);
  }
}
