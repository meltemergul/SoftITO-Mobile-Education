import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_pill_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toggle.dart';
import '../../domain/entities/habit_entity.dart';
import '../providers/habit_notifier.dart';
import '../../../home/presentation/providers/today_notifier.dart';
import '../../../statistics/presentation/providers/stats_notifier.dart';
import '../../../calendar/presentation/providers/calendar_notifier.dart';

const List<String> kAvailableIcons = [
  'water_drop',
  'menu_book',
  'directions_run',
  'bedtime',
  'self_improvement',
  'directions_walk',
  'fitness_center',
  'psychology',
  'local_fire_department',
  'spa',
  'code',
  'favorite',
];

IconData getHabitIconData(String name) {
  switch (name) {
    case 'water_drop':
      return Icons.water_drop_rounded;
    case 'menu_book':
      return Icons.menu_book_rounded;
    case 'directions_run':
      return Icons.directions_run_rounded;
    case 'bedtime':
      return Icons.bedtime_rounded;
    case 'self_improvement':
      return Icons.self_improvement_rounded;
    case 'directions_walk':
      return Icons.directions_walk_rounded;
    case 'fitness_center':
      return Icons.fitness_center_rounded;
    case 'psychology':
      return Icons.psychology_rounded;
    case 'local_fire_department':
      return Icons.local_fire_department_rounded;
    case 'spa':
      return Icons.spa_rounded;
    case 'code':
      return Icons.code_rounded;
    case 'favorite':
      return Icons.favorite_rounded;
    default:
      return Icons.star_rounded;
  }
}

class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({
    super.key,
    this.initialHabit,
  });

  final HabitEntity? initialHabit;

  bool get isEditing => initialHabit != null;

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _dailyGoalController;
  late TextEditingController _stepController;
  late TextEditingController _unitController;

  late String _selectedCategory;
  late String _selectedIcon;
  late Set<int> _selectedDays;
  late bool _reminderEnabled;
  late TimeOfDay _reminderTime;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final habit = widget.initialHabit;

    _nameController = TextEditingController(text: habit?.name ?? '');
    _dailyGoalController = TextEditingController(
      text: habit != null ? _formatNumber(habit.dailyGoal) : '20',
    );
    _stepController = TextEditingController(
      text: habit != null ? _formatNumber(habit.step) : '1',
    );
    _unitController = TextEditingController(text: habit?.unit ?? '');

    _selectedCategory = habit?.category ?? 'water';
    _selectedIcon = habit?.icon ?? 'water_drop';
    _selectedDays = habit != null ? habit.repeatDays.toSet() : {1, 2, 3, 4, 5, 6, 7};

    if (habit?.reminderTime != null && habit!.reminderTime!.isNotEmpty) {
      _reminderEnabled = true;
      final parts = habit.reminderTime!.split(':');
      _reminderTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 21,
        minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
      );
    } else {
      _reminderEnabled = false;
      _reminderTime = const TimeOfDay(hour: 21, minute: 0);
    }
  }

  String _formatNumber(double n) {
    return n == n.roundToDouble() ? n.toInt().toString() : n.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dailyGoalController.dispose();
    _stepController.dispose();
    _unitController.dispose();
    super.dispose();
  }

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

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'water':
        return 'Su';
      case 'book':
        return 'Kitap';
      case 'sport':
        return 'Spor';
      case 'mind':
        return 'Zihin';
      case 'custom':
      default:
        return 'Özel';
    }
  }

  void _applyTemplate(HabitTemplateEntity template) {
    setState(() {
      _nameController.text = template.name;
      _selectedCategory = template.category;
      _selectedIcon = template.icon;
      _dailyGoalController.text = _formatNumber(template.dailyGoal);
      _stepController.text = _formatNumber(template.step);
      _unitController.text = template.unit ?? '';
      _selectedDays = template.repeatDays.toSet();

      if (template.reminderTime != null && template.reminderTime!.isNotEmpty) {
        _reminderEnabled = true;
        final parts = template.reminderTime!.split(':');
        _reminderTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 21,
          minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
        );
      } else {
        _reminderEnabled = false;
      }
    });
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  String _formattedTime() {
    final h = _reminderTime.hour.toString().padLeft(2, '0');
    final m = _reminderTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedDays.isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen en az bir tekrar günü seçin.';
      });
      return;
    }

    final dailyGoal = double.tryParse(_dailyGoalController.text.replaceAll(',', '.'));
    if (dailyGoal == null || dailyGoal <= 0) {
      setState(() {
        _errorMessage = 'Günlük hedef 0\'dan büyük bir sayı olmalıdır.';
      });
      return;
    }

    final step = double.tryParse(_stepController.text.replaceAll(',', '.')) ?? 1.0;
    if (step <= 0) {
      setState(() {
        _errorMessage = 'Adım miktarı 0\'dan büyük olmalıdır.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final sortedDays = _selectedDays.toList()..sort();
    final reminderStr = _reminderEnabled ? _formattedTime() : null;

    try {
      final notifier = ref.read(habitNotifierProvider.notifier);

      if (widget.isEditing) {
        await notifier.updateHabit(
          widget.initialHabit!.id,
          name: _nameController.text.trim(),
          icon: _selectedIcon,
          category: _selectedCategory,
          unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
          dailyGoal: dailyGoal,
          step: step,
          repeatDays: sortedDays,
          reminderTime: reminderStr,
        );
      } else {
        await notifier.createHabit(
          name: _nameController.text.trim(),
          icon: _selectedIcon,
          category: _selectedCategory,
          unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
          dailyGoal: dailyGoal,
          step: step,
          repeatDays: sortedDays,
          reminderTime: reminderStr,
        );
      }

      // Alışkanlık kaydedildiğinde Bugün, İstatistik ve Takvim sağlayıcılarını güncelle
      ref.read(todayNotifierProvider.notifier).loadToday(force: true);
      ref.invalidate(statsNotifierProvider);
      ref.invalidate(calendarNotifierProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _confirmDelete() async {
    final colors = context.colors;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.cardRadius,
          ),
          backgroundColor: colors.surface,
          title: Text(
            'Alışkanlığı Sil',
            style: AppTypography.heading.copyWith(color: colors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bu alışkanlığı silmek istediğinize emin misiniz?',
                style: AppTypography.body.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.s12),
              Container(
                padding: const EdgeInsets.all(AppSpacing.s8),
                decoration: BoxDecoration(
                  color: colors.backgroundAlt,
                  borderRadius: AppRadius.cardRadius,
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 20, color: colors.primary),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Text(
                        'Alışkanlık arşivlenir; geçmiş loglarınız ve başarılarınız korunur.',
                        style: AppTypography.caption.copyWith(color: colors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(88, AppSpacing.minTouchTarget),
              ),
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'Vazgeç',
                style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.streakStrong,
                minimumSize: const Size(88, AppSpacing.minTouchTarget),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.pillRadius,
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'Evet, Sil',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isLoading = true;
      });
      try {
        await ref.read(habitNotifierProvider.notifier).deleteHabit(widget.initialHabit!.id);

        // Alışkanlık silindiğinde ilgili ekranları güncelle
        ref.read(todayNotifierProvider.notifier).loadToday(force: true);
        ref.invalidate(statsNotifierProvider);
        ref.invalidate(calendarNotifierProvider);

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = e.toString();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final categoryColor = _getCategoryColor(_selectedCategory, colors);
    final templatesAsync = ref.watch(habitTemplatesProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Geri Dön',
          constraints: const BoxConstraints(
            minWidth: AppSpacing.minTouchTarget,
            minHeight: AppSpacing.minTouchTarget,
          ),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isEditing ? 'Alışkanlığı Düzenle' : 'Yeni Alışkanlık',
          style: AppTypography.heading.copyWith(color: colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.s16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hazır Şablonlar (Yalnızca yeni oluştururken göster)
                if (!widget.isEditing) ...[
                  Text(
                    'Hazır Şablonlar',
                    style: AppTypography.heading.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  templatesAsync.when(
                    data: (templates) => SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: templates.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s8),
                        itemBuilder: (context, index) {
                          final template = templates[index];
                          final tmplColor = _getCategoryColor(template.category, colors);
                          return InkWell(
                            onTap: () => _applyTemplate(template),
                            borderRadius: AppRadius.pillRadius,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s16,
                                vertical: AppSpacing.s8,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: AppRadius.pillRadius,
                                border: Border.all(color: colors.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(getHabitIconData(template.icon), size: 18, color: tmplColor),
                                  const SizedBox(width: AppSpacing.s8),
                                  Text(
                                    template.name,
                                    style: AppTypography.caption.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    loading: () => const SizedBox(
                      height: 48,
                      child: Center(child: CircularProgressIndicator.adaptive()),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                ],

                // 2. Alışkanlık Adı & İkon Önizleme
                Text(
                  'Alışkanlık Adı',
                  style: AppTypography.heading.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.s8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.15),
                        borderRadius: AppRadius.cardRadius,
                        border: Border.all(color: categoryColor, width: 1.5),
                      ),
                      child: Icon(
                        getHabitIconData(_selectedIcon),
                        color: categoryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: AppTextField(
                        controller: _nameController,
                        hintText: 'Örn: Kitap Okuma, Su İçme',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Alışkanlık adı boş bırakılamaz.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s24),

                // 3. Kategori Seçimi (Kategori rengini belirler)
                Text(
                  'Kategori',
                  style: AppTypography.heading.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.s8),
                Wrap(
                  spacing: AppSpacing.s8,
                  runSpacing: AppSpacing.s8,
                  children: ['water', 'book', 'sport', 'mind', 'custom'].map((cat) {
                    final isSelected = _selectedCategory == cat;
                    final catColor = _getCategoryColor(cat, colors);
                    return ChoiceChip(
                      label: Text(_getCategoryTitle(cat)),
                      selected: isSelected,
                      selectedColor: catColor.withValues(alpha: 0.2),
                      backgroundColor: colors.surface,
                      labelStyle: AppTypography.caption.copyWith(
                        color: isSelected ? catColor : colors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? catColor : colors.border,
                        width: isSelected ? 1.8 : 1,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.s24),

                // 4. İkon Seçici Izgarası
                Text(
                  'İkon Seç',
                  style: AppTypography.heading.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.s8),
                AppCard(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: kAvailableIcons.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final iconName = kAvailableIcons[index];
                      final isSelected = _selectedIcon == iconName;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIcon = iconName;
                          });
                        },
                        borderRadius: AppRadius.cardRadius,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? categoryColor.withValues(alpha: 0.2)
                                : colors.backgroundAlt,
                            borderRadius: AppRadius.cardRadius,
                            border: Border.all(
                              color: isSelected ? categoryColor : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            getHabitIconData(iconName),
                            color: isSelected ? categoryColor : colors.textSecondary,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // 5. Günlük Hedef, Ölçü Birimi ve Adım Miktarı
                Text(
                  'Hedef ve Miktar',
                  style: AppTypography.heading.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.s8),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Günlük Hedef', style: AppTypography.caption.copyWith(color: colors.textSecondary)),
                          const SizedBox(height: 4),
                          AppTextField(
                            controller: _dailyGoalController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            hintText: 'Örn: 20',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Birim', style: AppTypography.caption.copyWith(color: colors.textSecondary)),
                          const SizedBox(height: 4),
                          AppTextField(
                            controller: _unitController,
                            hintText: 'sayfa, ml...',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Adım (+)', style: AppTypography.caption.copyWith(color: colors.textSecondary)),
                          const SizedBox(height: 4),
                          AppTextField(
                            controller: _stepController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            hintText: 'Örn: 1',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s24),

                // 6. Tekrar Günleri (7 Hap Buton)
                Text(
                  'Tekrar Günleri',
                  style: AppTypography.heading.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.s8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDayPill(1, 'Pzt', colors, categoryColor),
                    _buildDayPill(2, 'Sal', colors, categoryColor),
                    _buildDayPill(3, 'Çar', colors, categoryColor),
                    _buildDayPill(4, 'Per', colors, categoryColor),
                    _buildDayPill(5, 'Cum', colors, categoryColor),
                    _buildDayPill(6, 'Cmt', colors, categoryColor),
                    _buildDayPill(7, 'Paz', colors, categoryColor),
                  ],
                ),
                const SizedBox(height: AppSpacing.s24),

                // 7. Hatırlatıcı Saati
                AppCard(
                  child: Column(
                    children: [
                      AppToggle(
                        title: 'Günlük Hatırlatıcı',
                        value: _reminderEnabled,
                        onChanged: (val) {
                          setState(() {
                            _reminderEnabled = val;
                          });
                        },
                      ),
                      if (_reminderEnabled) ...[
                        const Divider(height: AppSpacing.s24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hatırlatma Saati',
                              style: AppTypography.body.copyWith(color: colors.textPrimary),
                            ),
                            InkWell(
                              onTap: _selectTime,
                              borderRadius: AppRadius.pillRadius,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.backgroundAlt,
                                  borderRadius: AppRadius.pillRadius,
                                  border: Border.all(color: colors.border),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 18, color: colors.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formattedTime(),
                                      style: AppTypography.body.copyWith(
                                        color: colors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // Hata mesajı
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.s8),
                    decoration: BoxDecoration(
                      color: colors.streakStrong.withValues(alpha: 0.1),
                      borderRadius: AppRadius.cardRadius,
                      border: Border.all(color: colors.streakStrong.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.caption.copyWith(color: colors.streakStrong),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                ],

                // 8. Kaydet Butonu
                AppPillButton(
                  label: widget.isEditing ? 'Değişiklikleri Kaydet' : 'Alışkanlığı Kaydet',
                  isFullWidth: true,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _submit,
                ),

                // 9. Düzenleme modunda Sil Butonu
                if (widget.isEditing) ...[
                  const SizedBox(height: AppSpacing.s12),
                  SizedBox(
                    width: double.infinity,
                    height: AppSpacing.minTouchTarget,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.streakStrong),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: _isLoading ? null : _confirmDelete,
                      child: Text(
                        'Alışkanlığı Sil',
                        style: AppTypography.heading.copyWith(
                          color: colors.streakStrong,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.s32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayPill(
    int dayNumber,
    String label,
    AppColorsExtension colors,
    Color activeColor,
  ) {
    final isSelected = _selectedDays.contains(dayNumber);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedDays.remove(dayNumber);
          } else {
            _selectedDays.add(dayNumber);
          }
        });
      },
      borderRadius: AppRadius.pillRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : colors.surface,
          borderRadius: AppRadius.pillRadius,
          border: Border.all(
            color: isSelected ? activeColor : colors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? Colors.white : colors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
