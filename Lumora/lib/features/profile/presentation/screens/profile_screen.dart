import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../providers/profile_notifier.dart';
import '../widgets/account_system_section.dart';
import '../widgets/goal_management_section.dart';
import '../widgets/invite_friend_card.dart';
import '../widgets/preferences_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/quick_metrics_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileNotifierProvider.notifier).loadData();
    });
  }

  void _showEditProfileDialog() {
    final colors = context.colors;
    final state = ref.read(profileNotifierProvider);
    final notifier = ref.read(profileNotifierProvider.notifier);

    final nameController = TextEditingController(text: state.profile?.displayName ?? '');
    final usernameController = TextEditingController(text: state.profile?.username ?? '');

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
          title: Text(
            'Profili Düzenle',
            style: AppTypography.heading.copyWith(color: colors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Görünen Ad',
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Kullanıcı Adı',
                  prefixText: '@',
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'İptal',
                style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryStrong,
                foregroundColor: colors.textOnPrimary,
                shape: const StadiumBorder(),
                minimumSize: const Size(88, AppSpacing.minTouchTarget),
              ),
              onPressed: () {
                final newName = nameController.text.trim();
                final newUsername = usernameController.text.trim();
                if (newName.isNotEmpty) {
                  notifier.updateProfile(
                    displayName: newName,
                    username: newUsername.isNotEmpty ? newUsername : null,
                  );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _showExportResultDialog(String format, String data) {
    final colors = context.colors;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: colors.primary),
              const SizedBox(width: AppSpacing.s8),
              Text(
                '${format.toUpperCase()} Dışa Aktarıldı',
                style: AppTypography.heading.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verileriniz başarıyla hazırlandı. Aşağıdaki metni kopyalayabilir veya kaydedebilirsiniz:',
                  style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.s12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      data,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Kopyala'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: data));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veriler panoya kopyalandı.')),
                );
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryStrong,
                foregroundColor: colors.textOnPrimary,
                shape: const StadiumBorder(),
                minimumSize: const Size(88, AppSpacing.minTouchTarget),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(profileNotifierProvider);
    final notifier = ref.read(profileNotifierProvider.notifier);

    // Dışa aktarma sonucu geldiğinde popup aç
    ref.listen<ProfileState>(profileNotifierProvider, (previous, next) {
      if (next.exportedData != null && next.exportedData != previous?.exportedData) {
        _showExportResultDialog(next.exportedFormat ?? 'veri', next.exportedData!);
      }
      if (next.infoMessage != null && next.infoMessage != previous?.infoMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.infoMessage!)),
        );
      }
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colors.streakStrong,
            content: Text(next.errorMessage!),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: () => notifier.loadData(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Başlık
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16,
                    AppSpacing.s16,
                    AppSpacing.s16,
                    AppSpacing.s8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil & Ayarlar',
                        style: AppTypography.title.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        'Kişisel bilgiler, bildirimler ve uygulama tercihleri',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Yükleniyor Durumu
              if (state.isLoading && state.profile == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: colors.primary),
                  ),
                )
              // Hata Durumu
              else if (state.errorMessage != null && state.profile == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded, size: 48, color: colors.streak),
                          const SizedBox(height: AppSpacing.s16),
                          Text(
                            state.errorMessage!,
                            style: AppTypography.body.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.s16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primaryStrong,
                              foregroundColor: colors.textOnPrimary,
                              shape: const StadiumBorder(),
                              minimumSize: const Size(120, AppSpacing.minTouchTarget),
                            ),
                            onPressed: () => notifier.loadData(),
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              // Başarılı Veri Durumu
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.s12),

                        // 1. Profil Başlığı
                        if (state.profile != null) ...[
                          ProfileHeader(
                            profile: state.profile!,
                            onEditPressed: _showEditProfileDialog,
                          ),
                          const SizedBox(height: AppSpacing.s16),
                        ],

                        // 2. Hızlı Metrikler
                        if (state.profile != null) ...[
                          QuickMetricsCard(profile: state.profile!),
                          const SizedBox(height: AppSpacing.s16),
                        ],

                        // 3. Tercihler & Hatırlatıcılar
                        if (state.settings != null) ...[
                          PreferencesSection(
                            settings: state.settings!,
                            onNotificationChanged: notifier.updateNotificationSettings,
                            onWeekStartsOnChanged: notifier.updateWeekStartsOn,
                          ),
                          const SizedBox(height: AppSpacing.s16),
                        ],

                        // 4. Hedef Yönetimi
                        GoalManagementSection(
                          waterHabit: state.waterHabit,
                          bookHabit: state.bookHabit,
                          onGoalUpdated: (category, newGoal) => notifier.updateGoal(
                            category: category,
                            newGoal: newGoal,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s16),

                        // 5. Birlikte Güçlüyüz (Arkadaşını Davet Et - Görsel Yer Tutucu)
                        const InviteFriendCard(),
                        const SizedBox(height: AppSpacing.s16),

                        // 6. Hesap & Sistem (Tema, Bulut Senk., Dışa Aktarma, Çıkış, Hesabı Sil)
                        if (state.settings != null) ...[
                          AccountSystemSection(
                            settings: state.settings!,
                            onThemeChanged: notifier.updateTheme,
                            onExportData: notifier.exportData,
                            onLogout: () {
                              ref.read(authStateProvider.notifier).setAuthenticated(false);
                            },
                            onDeleteAccount: () async {
                              await notifier.deleteAccount();
                            },
                          ),
                        ],

                        const SizedBox(height: AppSpacing.s32),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
