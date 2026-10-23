import 'package:flutter/foundation.dart';

@immutable
class NotificationScheduleItem {
  const NotificationScheduleItem({
    required this.enabled,
    required this.time,
  });

  final bool enabled;
  final String time; // '08:00', '21:30'

  NotificationScheduleItem copyWith({
    bool? enabled,
    String? time,
  }) {
    return NotificationScheduleItem(
      enabled: enabled ?? this.enabled,
      time: time ?? this.time,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationScheduleItem &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          time == other.time;

  @override
  int get hashCode => enabled.hashCode ^ time.hashCode;
}

@immutable
class NotificationPreferences {
  const NotificationPreferences({
    required this.smart,
    required this.morningMotivation,
    required this.eveningChainCheck,
    required this.soundAndHaptics,
  });

  final bool smart;
  final NotificationScheduleItem morningMotivation;
  final NotificationScheduleItem eveningChainCheck;
  final bool soundAndHaptics;

  NotificationPreferences copyWith({
    bool? smart,
    NotificationScheduleItem? morningMotivation,
    NotificationScheduleItem? eveningChainCheck,
    bool? soundAndHaptics,
  }) {
    return NotificationPreferences(
      smart: smart ?? this.smart,
      morningMotivation: morningMotivation ?? this.morningMotivation,
      eveningChainCheck: eveningChainCheck ?? this.eveningChainCheck,
      soundAndHaptics: soundAndHaptics ?? this.soundAndHaptics,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferences &&
          runtimeType == other.runtimeType &&
          smart == other.smart &&
          morningMotivation == other.morningMotivation &&
          eveningChainCheck == other.eveningChainCheck &&
          soundAndHaptics == other.soundAndHaptics;

  @override
  int get hashCode =>
      smart.hashCode ^
      morningMotivation.hashCode ^
      eveningChainCheck.hashCode ^
      soundAndHaptics.hashCode;
}

@immutable
class UserSettingsEntity {
  const UserSettingsEntity({
    required this.userId,
    required this.theme,
    required this.weekStartsOn,
    required this.timezone,
    required this.notifications,
    required this.streakFreezeCount,
  });

  final String userId;
  final String theme; // 'system' | 'light' | 'dark'
  final int weekStartsOn; // 1 (Pazartesi) ... 7 (Pazar)
  final String timezone;
  final NotificationPreferences notifications;
  final int streakFreezeCount;

  UserSettingsEntity copyWith({
    String? theme,
    int? weekStartsOn,
    String? timezone,
    NotificationPreferences? notifications,
    int? streakFreezeCount,
  }) {
    return UserSettingsEntity(
      userId: userId,
      theme: theme ?? this.theme,
      weekStartsOn: weekStartsOn ?? this.weekStartsOn,
      timezone: timezone ?? this.timezone,
      notifications: notifications ?? this.notifications,
      streakFreezeCount: streakFreezeCount ?? this.streakFreezeCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsEntity &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          theme == other.theme &&
          weekStartsOn == other.weekStartsOn &&
          timezone == other.timezone &&
          notifications == other.notifications &&
          streakFreezeCount == other.streakFreezeCount;

  @override
  int get hashCode =>
      userId.hashCode ^
      theme.hashCode ^
      weekStartsOn.hashCode ^
      timezone.hashCode ^
      notifications.hashCode ^
      streakFreezeCount.hashCode;
}
