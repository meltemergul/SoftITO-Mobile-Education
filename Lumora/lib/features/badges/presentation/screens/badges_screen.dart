import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../providers/badges_notifier.dart';
import '../widgets/user_level_card.dart';
import '../widgets/new_achievement_banner.dart';
import '../widgets/badge_category_filter.dart';
import '../widgets/next_threshold_card.dart';
import '../widgets/badge_grid.dart';

class BadgesScreen extends ConsumerStatefulWidget {
  const BadgesScreen({super.key});

  @override
  ConsumerState<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends ConsumerState<BadgesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(badgesNotifierProvider.notifier).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(badgesNotifierProvider);
    final notifier = ref.read(badgesNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: () => notifier.loadData(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Üst Başlık
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
                        'Rozetler & Seviye',
                        style: AppTypography.title.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        'Kazanımların ve disiplin yolculuğunun kilometre taşları',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Yükleniyor Durumu
              if (state.isLoading && state.level == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: colors.primary,
                    ),
                  ),
                )
              // Hata Durumu
              else if (state.errorMessage != null && state.level == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: colors.streak,
                          ),
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

                        // 1. Yeni Başarım Tebrik Kartı (görüldükten sonra kapatılır)
                        if (state.latestNewAchievement != null) ...[
                          NewAchievementBanner(
                            badge: state.latestNewAchievement!,
                            onDismiss: () => notifier.dismissNewAchievement(
                              state.latestNewAchievement!.id,
                            ),
                          ),
                        ],

                        // 2. Kullanıcı Seviyesi Kalkanı ve XP Çubuğu
                        if (state.level != null) ...[
                          UserLevelCard(level: state.level!),
                          const SizedBox(height: AppSpacing.s16),
                        ],

                        // 3. Sonraki Büyük Eşik İpucu Kutusu
                        NextThresholdCard(
                          nextBadge: state.nextThresholdBadge,
                          hasAnyUnlocked: state.unlockedBadges.isNotEmpty,
                        ),
                        const SizedBox(height: AppSpacing.s24),

                        // 4. Rozetler Başlığı ve İstatistik Özeti
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Başarı Rozetleri',
                              style: AppTypography.title.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s12,
                                vertical: AppSpacing.s4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.12),
                                borderRadius: AppRadius.pillRadius,
                              ),
                              child: Text(
                                '${state.unlockedBadges.length} / ${state.badges.length} Açık',
                                style: AppTypography.caption.copyWith(
                                  color: colors.primaryStrong,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s12),

                        // 5. Kategori Filtresi
                        BadgeCategoryFilter(
                          selectedCategory: state.selectedCategory,
                          onCategorySelected: (category) =>
                              notifier.selectCategory(category),
                        ),
                        const SizedBox(height: AppSpacing.s16),

                        // 6. Rozet Izgarası (Açık, Devam Eden, Kilitli)
                        BadgeGrid(badges: state.filteredBadges),

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
