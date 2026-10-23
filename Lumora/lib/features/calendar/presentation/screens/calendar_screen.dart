import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../domain/entities/calendar_month_entity.dart';
import '../providers/calendar_notifier.dart';
import '../widgets/active_habit_chains_widget.dart';
import '../widgets/calendar_skeleton.dart';
import '../widgets/chain_matrix_widget.dart';
import '../widgets/chain_quote_card.dart';
import '../widgets/day_detail_bottom_sheet.dart';
import '../widgets/month_picker_header.dart';
import '../widgets/monthly_consistency_card.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(calendarNotifierProvider.notifier).loadCalendar();
    });
  }

  void _onDayTapped(String date) async {
    final notifier = ref.read(calendarNotifierProvider.notifier);
    final detail = await notifier.loadDayDetail(date);
    if (detail != null && mounted) {
      DayDetailBottomSheet.show(context, detail);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(calendarNotifierProvider);
    final notifier = ref.read(calendarNotifierProvider.notifier);
    final weekStartsOn = ref.watch(weekStartsOnProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: () => notifier.loadCalendar(force: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.s16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Ay Seçici Başlığı
                MonthPickerHeader(
                  currentMonth: state.currentMonth,
                  onPreviousMonth: () => notifier.previousMonth(),
                  onNextMonth: () => notifier.nextMonth(),
                ),
                const SizedBox(height: AppSpacing.s16),

                // Hata Durumu
                if (state.errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.s12),
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
                        TextButton(
                          onPressed: () => notifier.loadCalendar(force: true),
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                ],

                // Yükleme Durumu
                if (state.isLoading && state.calendarData == null)
                  const CalendarSkeleton()
                else if (state.calendarData != null)
                  ..._buildCalendarContent(state.calendarData!, colors, weekStartsOn),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCalendarContent(
    CalendarMonthEntity calendar,
    AppColorsExtension colors,
    int weekStartsOn,
  ) {
    return [
      // 2. Aylık İstikrar Özeti
      MonthlyConsistencyCard(
        unbrokenDays: calendar.unbrokenDays,
        longestStreak: calendar.longestStreak,
      ),
      const SizedBox(height: AppSpacing.s16),

      // 3. Zincir Matrisi (Isı Haritası)
      if (calendar.days.isEmpty)
        _buildEmptyMonthCard(colors)
      else
        ChainMatrixWidget(
          days: calendar.days,
          weekStartsOn: weekStartsOn,
          onDaySelected: _onDayTapped,
        ),
      const SizedBox(height: AppSpacing.s20),

      // 4. Aktif Hedef Zincirleri
      ActiveHabitChainsWidget(
        habits: calendar.activeHabits,
      ),
      const SizedBox(height: AppSpacing.s20),

      // 5. Günün Zincir Sözü Kartı
      const ChainQuoteCard(),
      const SizedBox(height: AppSpacing.s32),
    ];
  }

  Widget _buildEmptyMonthCard(AppColorsExtension colors) {
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
          Icon(Icons.calendar_today_rounded, size: 40, color: colors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Bu ayda henüz kayıt yok',
            style: AppTypography.body.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Alışkanlıklarını tamamladıkça zincirin burada parlayacak.',
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
