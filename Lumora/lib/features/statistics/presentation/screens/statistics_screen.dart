import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/stats_notifier.dart';
import '../widgets/category_distribution_widget.dart';
import '../widgets/habit_details_list_widget.dart';
import '../widgets/overall_score_card.dart';
import '../widgets/productive_hours_widget.dart';
import '../widgets/range_filter_selector.dart';
import '../widgets/routine_bar_chart.dart';
import '../widgets/stats_skeleton.dart';
import '../widgets/weekly_momentum_card.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(statsNotifierProvider.notifier).loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(statsNotifierProvider);
    final notifier = ref.read(statsNotifierProvider.notifier);
    final stats = state.stats;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: () => notifier.loadStats(force: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.s16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Text(
                  'İstatistik',
                  style: AppTypography.display.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Alışkanlık performansı ve odak pencerelerin',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),

                // 1. Zaman Aralığı Filtresi
                RangeFilterSelector(
                  selectedRange: state.range,
                  onRangeChanged: (newRange) => notifier.changeRange(newRange),
                ),
                const SizedBox(height: AppSpacing.s16),

                // Hata Durumu
                if (state.errorMessage != null && stats == null) ...[
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.redAccent,
                          size: 32,
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          state.errorMessage!,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        ElevatedButton(
                          onPressed: () => notifier.loadStats(force: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primaryStrong,
                            foregroundColor: colors.textOnPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.pillRadius,
                            ),
                          ),
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                ] else if (state.isLoading && stats == null) ...[
                  // Yükleme İskeleti
                  const StatsSkeleton(),
                ] else if (stats != null) ...[
                  // Yetersiz Veri Durumu (design-skill.md Bölüm 6.4)
                  if (!stats.hasEnoughData) ...[
                    _buildInsufficientDataBanner(colors),
                    const SizedBox(height: AppSpacing.s16),
                  ],

                  // 2. Genel Başarı Skoru & Trend
                  OverallScoreCard(
                    overallScore: stats.overallScore,
                    trend: stats.trend,
                    totalCompletedDays: stats.totalCompletedDays,
                    longestStreak: stats.longestStreak,
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // 3. Rutin Performansı Çubuk Grafiği
                  if (stats.dailyChart.isNotEmpty) ...[
                    RoutineBarChart(
                      chartItems: stats.dailyChart,
                    ),
                    const SizedBox(height: AppSpacing.s16),
                  ],

                  // 4. Kategori Dağılımı
                  CategoryDistributionWidget(
                    categories: stats.categoryDistribution,
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // 5. Alışkanlık Detayı Listesi (Tasarımda olmayan önerilen bölüm - Bölüm 6.4)
                  HabitDetailsListWidget(
                    habitProgress: stats.habitProgress,
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // 6. En Verimli Saatler
                  ProductiveHoursWidget(
                    productiveHours: stats.productiveHours,
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // 7. Haftalık Özet & Momentum Kartı
                  WeeklyMomentumCard(
                    overallScore: stats.overallScore,
                    bestHabit: stats.bestHabit,
                    overallStreak: stats.overallStreak,
                  ),
                  const SizedBox(height: AppSpacing.s32),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsufficientDataBanner(AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.query_stats_rounded,
              color: colors.primaryStrong,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İstatistikler birkaç günlük veriyle oluşur',
                  style: AppTypography.body.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Grafik ve odak saatlerinin detaylı analiz edilebilmesi için alışkanlıklarını takip etmeye devam et.',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
