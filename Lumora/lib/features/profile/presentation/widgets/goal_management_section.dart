import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../habits/domain/entities/habit_entity.dart';

class GoalManagementSection extends StatelessWidget {
  const GoalManagementSection({
    super.key,
    required this.waterHabit,
    required this.bookHabit,
    required this.onGoalUpdated,
  });

  final HabitEntity? waterHabit;
  final HabitEntity? bookHabit;
  final void Function(String category, double newGoal) onGoalUpdated;

  void _showEditGoalDialog({
    required BuildContext context,
    required String title,
    required String category,
    required double currentGoal,
    required String unit,
    required List<double> quickSuggestions,
  }) {
    final colors = context.colors;
    final controller = TextEditingController(text: currentGoal.toInt().toString());

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
          title: Text(
            title,
            style: AppTypography.heading.copyWith(color: colors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Günlük hedef miktarını belirleyin ($unit):',
                style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: AppTypography.body.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  suffixText: unit,
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              Wrap(
                spacing: AppSpacing.s8,
                children: quickSuggestions.map((suggestion) {
                  return ActionChip(
                    label: Text('${suggestion.toInt()} $unit'),
                    backgroundColor: colors.background,
                    labelStyle: AppTypography.caption.copyWith(color: colors.textPrimary),
                    onPressed: () {
                      controller.text = suggestion.toInt().toString();
                    },
                  );
                }).toList(),
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
                final value = double.tryParse(controller.text.trim());
                if (value != null && value > 0) {
                  onGoalUpdated(category, value);
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

  Widget _buildGoalItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required String category,
    required HabitEntity? habit,
    required double defaultGoal,
    required String unit,
    required List<double> quickSuggestions,
  }) {
    final colors = context.colors;
    final currentGoal = habit?.dailyGoal ?? defaultGoal;
    final goalText = '${currentGoal.toInt()} $unit';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.caption.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  goalText,
                  style: AppTypography.heading.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
              side: BorderSide(color: colors.border),
              shape: const StadiumBorder(),
            ),
            icon: Icon(Icons.edit_outlined, size: 14, color: colors.textPrimary),
            label: Text(
              'Düzenle',
              style: AppTypography.caption.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () => _showEditGoalDialog(
              context: context,
              title: title,
              category: category,
              currentGoal: currentGoal,
              unit: unit,
              quickSuggestions: quickSuggestions,
            ),
          ),
        ],
      ),
    );
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
              Icon(Icons.tune_rounded, color: colors.primary, size: 20),
              const SizedBox(width: AppSpacing.s8),
              Text(
                'Hedef Yönetimi',
                style: AppTypography.heading.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          _buildGoalItem(
            context: context,
            title: 'Günlük Su Hedefi',
            icon: Icons.water_drop_rounded,
            iconColor: colors.water,
            category: 'water',
            habit: waterHabit,
            defaultGoal: 2500,
            unit: 'ml',
            quickSuggestions: const [2000, 2500, 3000, 3500],
          ),
          const SizedBox(height: AppSpacing.s8),
          _buildGoalItem(
            context: context,
            title: 'Günlük Kitap Hedefi',
            icon: Icons.menu_book_rounded,
            iconColor: colors.book,
            category: 'book',
            habit: bookHabit,
            defaultGoal: 20,
            unit: 'sayfa',
            quickSuggestions: const [10, 20, 30, 50],
          ),
        ],
      ),
    );
  }
}
