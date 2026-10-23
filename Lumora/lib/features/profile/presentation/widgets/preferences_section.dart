import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_segmented_control.dart';
import '../../../../core/widgets/app_toggle.dart';
import '../../domain/entities/user_settings_entity.dart';

class PreferencesSection extends StatelessWidget {
  const PreferencesSection({
    super.key,
    required this.settings,
    required this.onNotificationChanged,
    required this.onWeekStartsOnChanged,
  });

  final UserSettingsEntity settings;
  final Function({
    bool? smart,
    bool? morningEnabled,
    String? morningTime,
    bool? eveningEnabled,
    String? eveningTime,
    bool? soundAndHaptics,
  }) onNotificationChanged;
  final ValueChanged<int> onWeekStartsOnChanged;

  Future<void> _pickTime(BuildContext context, String initialTime, ValueChanged<String> onPicked) async {
    final parts = initialTime.split(':');
    final initialHour = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 8) : 8;
    final initialMinute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      onPicked('$hourStr:$minuteStr');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final notif = settings.notifications;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active_outlined, color: colors.primary, size: 20),
              const SizedBox(width: AppSpacing.s8),
              Text(
                'Tercihler & Hatırlatıcılar',
                style: AppTypography.heading.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),

          // 1. Akıllı Bildirimler
          AppToggle(
            title: 'Akıllı Bildirimler',
            subtitle: 'Alışkanlık rutinlerine göre optimize bildirimler',
            value: notif.smart,
            onChanged: (val) => onNotificationChanged(smart: val),
          ),
          const Divider(height: AppSpacing.s24),

          // 2. Sabah Motivasyonu
          AppToggle(
            title: 'Sabah Motivasyonu',
            subtitle: 'Güne ilham veren sözlerle başla',
            time: notif.morningMotivation.time,
            value: notif.morningMotivation.enabled,
            onChanged: (val) => onNotificationChanged(morningEnabled: val),
            onTimeTap: () => _pickTime(
              context,
              notif.morningMotivation.time,
              (time) => onNotificationChanged(morningTime: time),
            ),
          ),
          const Divider(height: AppSpacing.s24),

          // 3. Akşam Zincir Kontrolü
          AppToggle(
            title: 'Akşam Zincir Kontrolü',
            subtitle: 'Tamamlanmamış planlı alışkanlık varsa uyarır',
            time: notif.eveningChainCheck.time,
            value: notif.eveningChainCheck.enabled,
            onChanged: (val) => onNotificationChanged(eveningEnabled: val),
            onTimeTap: () => _pickTime(
              context,
              notif.eveningChainCheck.time,
              (time) => onNotificationChanged(eveningTime: time),
            ),
          ),
          const Divider(height: AppSpacing.s24),

          // 4. Titreşim & Ses Efektleri
          AppToggle(
            title: 'Titreşim & Ses Efektleri',
            subtitle: 'Tamamlamalarda dokunsal geri bildirim',
            value: notif.soundAndHaptics,
            onChanged: (val) => onNotificationChanged(soundAndHaptics: val),
          ),
          const Divider(height: AppSpacing.s24),

          // 5. Haftanın İlk Günü
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Haftanın İlk Günü',
                style: AppTypography.body.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                'Takvim ve haftalık istatistik görünümleri için başlangıç',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              AppSegmentedControl(
                options: const ['Pazartesi', 'Pazar'],
                selectedIndex: settings.weekStartsOn == 7 ? 1 : 0,
                onSelected: (idx) {
                  final day = idx == 1 ? 7 : 1;
                  onWeekStartsOnChanged(day);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
