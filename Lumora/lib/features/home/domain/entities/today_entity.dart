import 'package:flutter/foundation.dart';

@immutable
class DailyProgressEntity {
  const DailyProgressEntity({
    required this.completed,
    required this.total,
    required this.percentage,
    required this.isAllCompleted,
  });

  final int completed;
  final int total;
  final int percentage;
  final bool isAllCompleted;

  DailyProgressEntity copyWith({
    int? completed,
    int? total,
    int? percentage,
    bool? isAllCompleted,
  }) {
    return DailyProgressEntity(
      completed: completed ?? this.completed,
      total: total ?? this.total,
      percentage: percentage ?? this.percentage,
      isAllCompleted: isAllCompleted ?? this.isAllCompleted,
    );
  }
}

@immutable
class UserXpEntity {
  const UserXpEntity({
    required this.totalXp,
    required this.level,
    required this.title,
    required this.currentLevelXp,
    required this.nextLevelXp,
    required this.progressPercent,
  });

  final int totalXp;
  final int level;
  final String title;
  final int currentLevelXp;
  final int nextLevelXp;
  final int progressPercent;

  UserXpEntity copyWith({
    int? totalXp,
    int? level,
    String? title,
    int? currentLevelXp,
    int? nextLevelXp,
    int? progressPercent,
  }) {
    return UserXpEntity(
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      title: title ?? this.title,
      currentLevelXp: currentLevelXp ?? this.currentLevelXp,
      nextLevelXp: nextLevelXp ?? this.nextLevelXp,
      progressPercent: progressPercent ?? this.progressPercent,
    );
  }
}

@immutable
class TodayHabitItemEntity {
  const TodayHabitItemEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    this.unit,
    required this.dailyGoal,
    required this.step,
    this.reminderTime,
    required this.repeatDays,
    required this.isPlannedToday,
    required this.isCompletedToday,
    required this.currentAmount,
    required this.currentStreak,
  });

  final String id;
  final String name;
  final String icon;
  final String category;
  final String? unit;
  final double dailyGoal;
  final double step;
  final String? reminderTime;
  final List<int> repeatDays;
  final bool isPlannedToday;
  final bool isCompletedToday;
  final double currentAmount;
  final int currentStreak;

  // Alışkanlık türü yardımcıları
  bool get isCounterHabit => dailyGoal > 1 && unit != null && unit!.isNotEmpty;
  bool get isTimedHabit => reminderTime != null && reminderTime!.isNotEmpty;

  TodayHabitItemEntity copyWith({
    String? id,
    String? name,
    String? icon,
    String? category,
    String? unit,
    double? dailyGoal,
    double? step,
    String? reminderTime,
    List<int>? repeatDays,
    bool? isPlannedToday,
    bool? isCompletedToday,
    double? currentAmount,
    int? currentStreak,
  }) {
    return TodayHabitItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      step: step ?? this.step,
      reminderTime: reminderTime ?? this.reminderTime,
      repeatDays: repeatDays ?? this.repeatDays,
      isPlannedToday: isPlannedToday ?? this.isPlannedToday,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      currentAmount: currentAmount ?? this.currentAmount,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }
}

@immutable
class TodayEntity {
  const TodayEntity({
    required this.date,
    required this.timezone,
    required this.progress,
    required this.xp,
    required this.overallStreak,
    required this.streakFreezeCount,
    required this.habits,
  });

  final String date;
  final String timezone;
  final DailyProgressEntity progress;
  final UserXpEntity xp;
  final int overallStreak;
  final int streakFreezeCount;
  final List<TodayHabitItemEntity> habits;

  TodayEntity copyWith({
    String? date,
    String? timezone,
    DailyProgressEntity? progress,
    UserXpEntity? xp,
    int? overallStreak,
    int? streakFreezeCount,
    List<TodayHabitItemEntity>? habits,
  }) {
    return TodayEntity(
      date: date ?? this.date,
      timezone: timezone ?? this.timezone,
      progress: progress ?? this.progress,
      xp: xp ?? this.xp,
      overallStreak: overallStreak ?? this.overallStreak,
      streakFreezeCount: streakFreezeCount ?? this.streakFreezeCount,
      habits: habits ?? this.habits,
    );
  }
}
