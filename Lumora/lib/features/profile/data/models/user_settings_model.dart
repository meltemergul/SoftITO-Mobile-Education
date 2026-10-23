import '../../domain/entities/user_settings_entity.dart';

class UserSettingsModel {
  const UserSettingsModel({
    required this.userId,
    required this.theme,
    required this.weekStartsOn,
    required this.timezone,
    required this.notifications,
    required this.streakFreezeCount,
  });

  final String userId;
  final String theme;
  final int weekStartsOn;
  final String timezone;
  final NotificationPreferences notifications;
  final int streakFreezeCount;

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    final notifJson = json['notifications'] as Map<String, dynamic>? ?? {};
    final morningJson = notifJson['morningMotivation'] as Map<String, dynamic>? ?? {};
    final eveningJson = notifJson['eveningChainCheck'] as Map<String, dynamic>? ?? {};

    return UserSettingsModel(
      userId: json['userId'] as String? ?? '',
      theme: json['theme'] as String? ?? 'system',
      weekStartsOn: (json['weekStartsOn'] as num?)?.toInt() ?? 1,
      timezone: json['timezone'] as String? ?? 'Europe/Istanbul',
      notifications: NotificationPreferences(
        smart: notifJson['smart'] as bool? ?? true,
        morningMotivation: NotificationScheduleItem(
          enabled: morningJson['enabled'] as bool? ?? true,
          time: morningJson['time'] as String? ?? '08:00',
        ),
        eveningChainCheck: NotificationScheduleItem(
          enabled: eveningJson['enabled'] as bool? ?? true,
          time: eveningJson['time'] as String? ?? '21:30',
        ),
        soundAndHaptics: notifJson['soundAndHaptics'] as bool? ?? true,
      ),
      streakFreezeCount: (json['streakFreezeCount'] as num?)?.toInt() ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'theme': theme,
      'weekStartsOn': weekStartsOn,
      'timezone': timezone,
      'notifications': {
        'smart': notifications.smart,
        'morningMotivation': {
          'enabled': notifications.morningMotivation.enabled,
          'time': notifications.morningMotivation.time,
        },
        'eveningChainCheck': {
          'enabled': notifications.eveningChainCheck.enabled,
          'time': notifications.eveningChainCheck.time,
        },
        'soundAndHaptics': notifications.soundAndHaptics,
      },
      'streakFreezeCount': streakFreezeCount,
    };
  }

  UserSettingsEntity toEntity() {
    return UserSettingsEntity(
      userId: userId,
      theme: theme,
      weekStartsOn: weekStartsOn,
      timezone: timezone,
      notifications: notifications,
      streakFreezeCount: streakFreezeCount,
    );
  }
}
