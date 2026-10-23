import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../habits/presentation/screens/habit_form_screen.dart' show getHabitIconData;
import '../../domain/entities/today_entity.dart';

class TodayHabitCard extends StatelessWidget {
  const TodayHabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onAdjust,
    this.onTapEdit,
  });

  final TodayHabitItemEntity habit;
  final VoidCallback onToggle;
  final ValueChanged<double> onAdjust;
  final VoidCallback? onTapEdit;

  Color _getCategoryColor(String category, AppColorsExtension colors) {
    switch (category) {
      case 'water':
        return colors.water;
      case 'book':
        return colors.book;
      case 'sport':
        return colors.sport;
      case 'mind':
        return colors.mind;
      case 'custom':
      default:
        return colors.customCategory;
    }
  }

  String _formatNumber(double n) {
    return n == n.roundToDouble() ? n.toInt().toString() : n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final catColor = _getCategoryColor(habit.category, colors);

    if (habit.isCounterHabit) {
      return _buildCounterCard(context, colors, catColor);
    } else if (habit.isTimedHabit) {
      return _buildTimedCard(context, colors, catColor);
    } else {
      return _buildCheckmarkCard(context, colors, catColor);
    }
  }

  // 1. İşaretleme Türü Kartı
  Widget _buildCheckmarkCard(
    BuildContext context,
    AppColorsExtension colors,
    Color catColor,
  ) {
    final isDone = habit.isCompletedToday;

    return AppCard(
      onTap: onToggle,
      child: Row(
        children: [
          // İkon Rozeti
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDone
                  ? colors.primary.withValues(alpha: 0.15)
                  : catColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.cardRadius,
            ),
            child: Icon(
              getHabitIconData(habit.icon),
              color: isDone ? colors.primary : catColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),

          // Başlık ve Etiketler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: AppTypography.heading.copyWith(
                    color: isDone ? colors.textSecondary : colors.textPrimary,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // +15 XP Çipi
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: AppRadius.pillRadius,
                      ),
                      child: Text(
                        '+15 XP',
                        style: AppTypography.caption.copyWith(
                          color: colors.accessibleGreenText,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (habit.currentStreak > 0) ...[
                      const SizedBox(width: 6),
                      // Zincir Rozeti
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            size: 14,
                            color: colors.streakStrong,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${habit.currentStreak} Gün Zincir',
                            style: AppTypography.caption.copyWith(
                              color: colors.streakStrong,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Tamamla / Geri Al Onay Butonu
          Semantics(
            button: true,
            label: '${habit.name} alışkanlığını ${isDone ? "tamamlanmadı olarak işaretle" : "tamamla"}',
            child: InkWell(
              onTap: onToggle,
              borderRadius: AppRadius.pillRadius,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: AppSpacing.minTouchTarget,
                  minHeight: AppSpacing.minTouchTarget,
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? colors.primaryStrong : colors.backgroundAlt,
                    border: Border.all(
                      color: isDone ? colors.primaryStrong : colors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: isDone ? Colors.white : colors.textTertiary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Sayaç Türü Kartı (+250ml ve − Hızlı Butonlar)
  Widget _buildCounterCard(
    BuildContext context,
    AppColorsExtension colors,
    Color catColor,
  ) {
    final progressFraction = (habit.currentAmount / habit.dailyGoal).clamp(0.0, 1.0);
    final isDone = habit.isCompletedToday;
    final stepText = '+${_formatNumber(habit.step)}${habit.unit ?? ''}';

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.cardRadius,
                ),
                child: Icon(
                  getHabitIconData(habit.icon),
                  color: catColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: AppTypography.heading.copyWith(
                        color: colors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatNumber(habit.currentAmount)} / ${_formatNumber(habit.dailyGoal)} ${habit.unit ?? ''}',
                      style: AppTypography.caption.copyWith(
                        color: isDone ? colors.accessibleGreenText : colors.textSecondary,
                        fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Hızlı − Butonu
              IconButton(
                tooltip: '${_formatNumber(habit.step)} ${habit.unit ?? ""} azalt',
                constraints: const BoxConstraints(
                  minWidth: AppSpacing.minTouchTarget,
                  minHeight: AppSpacing.minTouchTarget,
                ),
                icon: Icon(Icons.remove_circle_outline_rounded, color: colors.textSecondary),
                onPressed: () => onAdjust(-habit.step),
              ),

              // Hızlı + Butonu
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDone ? colors.primaryStrong : catColor,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  minimumSize: const Size(48, AppSpacing.minTouchTarget),
                ),
                onPressed: () => onAdjust(habit.step),
                child: Text(
                  stepText,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          // İlerleme Çubuğu
          ClipRRect(
            borderRadius: AppRadius.pillRadius,
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 6,
              backgroundColor: colors.backgroundAlt,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? colors.primary : catColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Zamanlı Hatırlatıcılı Kart
  Widget _buildTimedCard(
    BuildContext context,
    AppColorsExtension colors,
    Color catColor,
  ) {
    final isDone = habit.isCompletedToday;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.cardRadius,
            ),
            child: Icon(
              getHabitIconData(habit.icon),
              color: catColor,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: AppTypography.heading.copyWith(
                    color: colors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: colors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      habit.reminderTime ?? '',
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Başla / Tamamla Butonu
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDone ? colors.surface : colors.primaryStrong,
              side: isDone ? BorderSide(color: colors.primaryStrong) : BorderSide.none,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(88, AppSpacing.minTouchTarget),
            ),
            onPressed: onToggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDone ? Icons.check_rounded : Icons.play_arrow_rounded,
                  size: 16,
                  color: isDone ? colors.accessibleGreenText : Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  isDone ? 'Tamamlandı' : 'Başla',
                  style: AppTypography.caption.copyWith(
                    color: isDone ? colors.accessibleGreenText : Colors.white,
                    fontWeight: FontWeight.bold,
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
