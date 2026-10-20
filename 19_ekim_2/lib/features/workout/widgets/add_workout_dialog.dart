import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/workout_model.dart';

/// Yeni antrenman ekleme alt sayfası (Bottom Sheet).
class AddWorkoutSheet extends StatefulWidget {
  final void Function({
    required String title,
    required WorkoutType type,
    required int durationMinutes,
  }) onSave;

  const AddWorkoutSheet({super.key, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    required void Function({
      required String title,
      required WorkoutType type,
      required int durationMinutes,
    }) onSave,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AddWorkoutSheet(onSave: onSave),
    );
  }

  @override
  State<AddWorkoutSheet> createState() => _AddWorkoutSheetState();
}

class _AddWorkoutSheetState extends State<AddWorkoutSheet> {
  WorkoutType _selectedType = WorkoutType.weightLifting;
  int _duration = 30;
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waterNeed = WorkoutModel.calculateWaterNeed(_selectedType, _duration);
    final calories = WorkoutModel.calculateCalories(_selectedType, _duration);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildTypeSelector(context),
          const SizedBox(height: 20),
          _buildDurationSlider(context),
          const SizedBox(height: 16),
          _buildPreviewCard(context, waterNeed, calories),
          const SizedBox(height: 20),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Yeni Egzersiz Ekle',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: subTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.neonCyan : AppColors.lightPrimary;
    final surfaceLight = isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceLight;
    final borderColor = isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: WorkoutType.values.map((type) {
        final isSelected = type == _selectedType;
        return ChoiceChip(
          label: Text(type.label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _selectedType = type);
          },
          selectedColor: primaryColor.withAlpha(50),
          backgroundColor: surfaceLight,
          labelStyle: TextStyle(
            color: isSelected ? primaryColor : subTextColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
          side: BorderSide(
            color: isSelected ? primaryColor : borderColor,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationSlider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.neonCyan : AppColors.lightPrimary;
    final borderColor = isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Antrenman Süresi',
              style: TextStyle(fontSize: 14, color: subTextColor),
            ),
            Text(
              '$_duration Dakika',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ],
        ),
        Slider(
          value: _duration.toDouble(),
          min: 10,
          max: 120,
          divisions: 22,
          activeColor: primaryColor,
          inactiveColor: borderColor,
          onChanged: (val) => setState(() => _duration = val.toInt()),
        ),
      ],
    );
  }

  Widget _buildPreviewCard(BuildContext context, int waterNeed, int calories) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.neonCyan : AppColors.lightPrimary;
    final surfaceLight = isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceLight;
    final borderColor = isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_rounded, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                '+$waterNeed ml Su',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          Container(width: 1, height: 20, color: borderColor),
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  color: AppColors.neonOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                '~$calories kcal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neonOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          widget.onSave(
            title: _selectedType.label,
            type: _selectedType,
            durationMinutes: _duration,
          );
          Navigator.pop(context);
        },
        child: const Text('Antrenmanı Kaydet & Su Ekle'),
      ),
    );
  }
}
