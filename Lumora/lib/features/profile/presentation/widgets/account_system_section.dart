import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_pill_button.dart';
import '../../../../core/widgets/app_segmented_control.dart';
import '../../domain/entities/user_settings_entity.dart';

class AccountSystemSection extends StatelessWidget {
  const AccountSystemSection({
    super.key,
    required this.settings,
    required this.onThemeChanged,
    required this.onExportData,
    required this.onLogout,
    required this.onDeleteAccount,
  });

  final UserSettingsEntity settings;
  final ValueChanged<String> onThemeChanged;
  final ValueChanged<String> onExportData;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  void _showDeleteConfirmation(BuildContext context) {
    final colors = context.colors;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: colors.streakStrong),
              const SizedBox(width: AppSpacing.s8),
              Text(
                'Hesabı Sil',
                style: AppTypography.heading.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
          content: Text(
            'Hesabınızı ve tüm alışkanlık verilerinizi, tamamlama kayıtlarınızı ve ayarlarınızı kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
            style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Vazgeç',
                style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onDeleteAccount();
              },
              child: const Text('Kalıcı Olarak Sil'),
            ),
          ],
        );
      },
    );
  }

  int _themeToIndex(String theme) {
    switch (theme) {
      case 'light':
        return 1;
      case 'dark':
        return 2;
      case 'system':
      default:
        return 0;
    }
  }

  String _indexToTheme(int index) {
    switch (index) {
      case 1:
        return 'light';
      case 2:
        return 'dark';
      case 0:
      default:
        return 'system';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_outlined, color: colors.primary, size: 20),
              const SizedBox(width: AppSpacing.s8),
              Text(
                'Hesap & Sistem',
                style: AppTypography.heading.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),

          // 1. Tema Ayarı
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Uygulama Teması',
                style: AppTypography.body.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              AppSegmentedControl(
                options: const ['Sistem', 'Açık', 'Koyu'],
                selectedIndex: _themeToIndex(settings.theme),
                onSelected: (idx) => onThemeChanged(_indexToTheme(idx)),
              ),
            ],
          ),
          const Divider(height: AppSpacing.s24),

          // 2. Bulut Senkronizasyonu (Görsel Yer Tutucu - "Yakında")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Bulut Senkronizasyonu',
                        style: AppTypography.body.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.streak.withValues(alpha: 0.15),
                          borderRadius: AppRadius.pillRadius,
                        ),
                        child: Text(
                          'Yakında',
                          style: AppTypography.caption.copyWith(
                            color: colors.streakStrong,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cihazlar arası veri eşitleme (Faz 2)',
                    style: AppTypography.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
              Icon(Icons.cloud_off_rounded, color: colors.textTertiary),
            ],
          ),
          const Divider(height: AppSpacing.s24),

          // 3. Veri Dışa Aktarma
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Veri Dışa Aktarma',
                style: AppTypography.body.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tüm alışkanlık ve tamamlama kayıtlarını cihazına indir',
                style: AppTypography.caption.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                        side: BorderSide(color: colors.border),
                        shape: const StadiumBorder(),
                      ),
                      icon: Icon(Icons.table_chart_outlined, size: 18, color: colors.primary),
                      label: Text(
                        'CSV İndir',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => onExportData('csv'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                        side: BorderSide(color: colors.border),
                        shape: const StadiumBorder(),
                      ),
                      icon: Icon(Icons.code_rounded, size: 18, color: colors.streak),
                      label: Text(
                        'JSON İndir',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => onExportData('json'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: AppSpacing.s24),

          // 4. Çıkış Yap
          SizedBox(
            width: double.infinity,
            child: AppPillButton(
              label: 'Çıkış Yap',
              variant: AppButtonVariant.secondary,
              onPressed: onLogout,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // 5. Hesabı Sil
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
              ),
              icon: Icon(Icons.delete_forever_rounded, color: Colors.red.shade600),
              label: Text(
                'Hesabı ve Tüm Verileri Sil',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ),
        ],
      ),
    );
  }
}
