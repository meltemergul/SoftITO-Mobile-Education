import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_pill_button.dart';
import '../../../habits/presentation/screens/habit_form_screen.dart';
import '../../../quotes/presentation/providers/daily_quote_provider.dart';
import '../../../quotes/presentation/widgets/inspiration_quote_card.dart';
import '../providers/today_notifier.dart';
import '../widgets/celebration_dialog.dart';
import '../widgets/daily_progress_card.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/today_habit_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(todayNotifierProvider.notifier).loadToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(todayNotifierProvider);
    final notifier = ref.read(todayNotifierProvider.notifier);

    // Kutlama diyaloğu dinleyicisi
    ref.listen<TodayState>(todayNotifierProvider, (previous, next) {
      if (next.showCelebration && !(previous?.showCelebration ?? false)) {
        showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (ctx) => CelebrationDialog(
            onDismiss: () {
              Navigator.of(ctx).pop();
              notifier.dismissCelebration();
            },
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.primaryStrong,
        foregroundColor: colors.textOnPrimary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          'Yeni Alışkanlık',
          style: AppTypography.caption.copyWith(
            color: colors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const HabitFormScreen()),
          );
          if (created == true) {
            notifier.loadToday(force: true);
          }
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              notifier.loadToday(force: true),
              ref.read(dailyQuoteNotifierProvider.notifier).loadDailyQuote(force: true),
            ]);
          },
          color: colors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.s16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Çevrimdışı Bilgi Şeridi
                if (state.isOffline) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s12,
                      vertical: AppSpacing.s8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.streak.withValues(alpha: 0.15),
                      borderRadius: AppRadius.cardRadius,
                      border: Border.all(color: colors.streak.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off_rounded, size: 18, color: colors.streakStrong),
                        const SizedBox(width: AppSpacing.s8),
                        Expanded(
                          child: Text(
                            'Çevrimdışı mod: Değişiklikleriniz cihazda saklanıyor, bağlantı gelince eşitlenecektir.',
                            style: AppTypography.caption.copyWith(
                              color: colors.streakStrong,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                ],

                // 2. Hata Şeridi
                if (state.errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s12,
                      vertical: AppSpacing.s8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: AppRadius.cardRadius,
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 18, color: Colors.redAccent),
                        const SizedBox(width: AppSpacing.s8),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: AppTypography.caption.copyWith(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                ],

                // 3. Yükleme ve Hata Durumları
                if (state.isLoading && state.todayData == null)
                  const TodaySkeletonLoading()
                else if (state.errorMessage != null && state.todayData == null)
                  _buildErrorState(context, colors, state.errorMessage!, () => notifier.loadToday(force: true))
                else if (state.todayData != null) ...[
                  // 4. Günün İlhamı Kartı
                  const InspirationQuoteCard(),
                  const SizedBox(height: AppSpacing.s16),

                  // 5. Günün İlerlemesi Kartı
                  DailyProgressCard(
                    progress: state.todayData!.progress,
                    xp: state.todayData!.xp,
                    overallStreak: state.todayData!.overallStreak,
                  ),
                  const SizedBox(height: AppSpacing.s24),

                  // 6. Alışkanlıklar Başlığı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bugünün Alışkanlıkları',
                        style: AppTypography.heading.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${state.todayData!.habits.where((h) => h.isPlannedToday).length} Planlı',
                        style: AppTypography.caption.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),

                  // 7. Alışkanlık Listesi / Boş Durumlar
                  if (state.todayData!.habits.isEmpty)
                    _buildNoHabitsEmptyState(context, colors)
                  else if (state.todayData!.habits.where((h) => h.isPlannedToday).isEmpty)
                    _buildRestDayEmptyState(colors)
                  else
                    ...state.todayData!.habits
                        .where((habit) => habit.isPlannedToday)
                        .map(
                          (habit) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                            child: TodayHabitCard(
                              habit: habit,
                              onToggle: () => notifier.toggleHabit(habit),
                              onAdjust: (delta) => notifier.adjustCounter(habit, delta),
                              onTapEdit: () async {
                                final updated = await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => HabitFormScreen(
                                      initialHabit: null, // edit için form açılabilir
                                    ),
                                  ),
                                );
                                if (updated == true) {
                                  notifier.loadToday(force: true);
                                }
                              },
                            ),
                          ),
                        ),
                  const SizedBox(height: 80), // FAB için alt boşluk
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Boş Durum: Hiç alışkanlık yok
  Widget _buildNoHabitsEmptyState(BuildContext context, AppColorsExtension colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.add_task_rounded, size: 48, color: colors.textSecondary),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Henüz bir alışkanlık eklemediniz',
            style: AppTypography.heading.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Hayatınıza değer katacak ilk alışkanlığı şimdi ekleyerek zinciri başlatın!',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s16),
          AppPillButton(
            label: '+ Yeni Alışkanlık Ekle',
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const HabitFormScreen()),
              );
              if (created == true) {
                ref.read(todayNotifierProvider.notifier).loadToday(force: true);
              }
            },
          ),
        ],
      ),
    );
  }

  // Boş Durum: Bugün dinlenme günü
  Widget _buildRestDayEmptyState(AppColorsExtension colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.spa_rounded, size: 48, color: colors.primary),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Bugün Dinlenme Günü! 🌿',
            style: AppTypography.heading.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Bugün için planlanmış bir alışkanlığınız bulunmuyor. Zihninizi ve bedeninizi dinlendirip enerji toplayın.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  // Hata Durumu: Veri yüklenemediğinde tekrar deneme
  Widget _buildErrorState(
    BuildContext context,
    AppColorsExtension colors,
    String error,
    VoidCallback onRetry,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 48, color: Colors.redAccent.shade200),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Veriler Yüklenemedi',
            style: AppTypography.heading.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s16),
          AppPillButton(
            label: 'Tekrar Dene',
            icon: const Icon(Icons.refresh_rounded, size: 18),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
