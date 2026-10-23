import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../domain/entities/calendar_day_detail_entity.dart';
import '../../domain/entities/calendar_month_entity.dart';
import 'active_habit_chains_widget.dart';

class DayDetailBottomSheet extends StatelessWidget {
  const DayDetailBottomSheet({
    super.key,
    required this.detail,
  });

  final CalendarDayDetailEntity detail;

  static void show(BuildContext context, CalendarDayDetailEntity detail) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DayDetailBottomSheet(detail: detail),
    );
  }

  String _formatDateTitle(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        const months = [
          'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
          'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
        ];
        return '$day ${months[month - 1]} $year';
      }
    } catch (_) {}
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.s12,
        left: AppSpacing.s20,
        right: AppSpacing.s20,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tutamaç (Handle)
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // Başlık ve Durum Rozeti
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDateTitle(detail.date),
                style: AppTypography.heading.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              _buildStatusChip(detail.status, colors),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            detail.totalPlanned > 0
                ? '${detail.totalPlanned} planlı alışkanlıktan ${detail.completedCount} tanesi tamamlandı'
                : 'Bu günde planlı bir alışkanlık bulunmuyor (Dinlenme Günü)',
            style: AppTypography.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.s20),

          // Alışkanlıklar Listesi
          if (detail.habits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s24),
              child: Center(
                child: Text(
                  'Bu gün için kayıtlı alışkanlık yok.',
                  style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: detail.habits.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s8),
                itemBuilder: (context, index) {
                  final habit = detail.habits[index];
                  final categoryColor = ActiveHabitChainsWidget.getCategoryColor(habit.category, colors);

                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: colors.backgroundAlt,
                      borderRadius: AppRadius.cardRadius,
                      border: Border.all(
                        color: habit.isCompleted
                            ? colors.primary.withValues(alpha: 0.3)
                            : colors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Kategori ikonu
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s8),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            ActiveHabitChainsWidget.getIconData(habit.icon),
                            color: categoryColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s12),

                        // Alışkanlık adı ve plan durumu
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.name,
                                style: AppTypography.body.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                habit.isPlanned ? 'Planlı gün' : 'Plan dışı',
                                style: AppTypography.caption.copyWith(
                                  color: colors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tamamlanma miktarı / durum
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (habit.unit != null && habit.unit!.isNotEmpty)
                              Text(
                                '${habit.currentAmount.toInt()} / ${habit.targetAmount.toInt()} ${habit.unit}',
                                style: AppTypography.caption.copyWith(
                                  color: habit.isCompleted ? colors.primaryStrong : colors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (habit.isCompleted) ...[
                                  Icon(Icons.check_circle_rounded, size: 16, color: colors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Tamamlandı',
                                    style: AppTypography.caption.copyWith(
                                      color: colors.primaryStrong,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ] else ...[
                                  Icon(Icons.radio_button_unchecked_rounded, size: 16, color: colors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Tamamlanmadı',
                                    style: AppTypography.caption.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(CalendarDayStatus status, AppColorsExtension colors) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status) {
      case CalendarDayStatus.completed:
        bg = colors.primary.withValues(alpha: 0.15);
        fg = colors.primaryStrong;
        label = 'Tamamlandı';
        icon = Icons.check_circle_rounded;
        break;
      case CalendarDayStatus.partial:
        bg = colors.streak.withValues(alpha: 0.15);
        fg = colors.streakStrong;
        label = 'Kısmi';
        icon = Icons.square_rounded;
        break;
      case CalendarDayStatus.rest:
        bg = colors.inactive;
        fg = colors.textSecondary;
        label = 'Dinlenme';
        icon = Icons.spa_rounded;
        break;
      case CalendarDayStatus.future:
        bg = colors.inactive.withValues(alpha: 0.5);
        fg = colors.textSecondary.withValues(alpha: 0.6);
        label = 'Gelecek';
        icon = Icons.schedule_rounded;
        break;
      case CalendarDayStatus.empty:
        bg = Colors.redAccent.withValues(alpha: 0.1);
        fg = Colors.redAccent;
        label = 'Boş Gün';
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
