import '../../domain/entities/today_entity.dart';

class DailyProgressModel {
  const DailyProgressModel({
    required this.completed,
    required this.total,
    required this.percentage,
    required this.isAllCompleted,
  });

  factory DailyProgressModel.fromJson(Map<String, dynamic> json) {
    return DailyProgressModel(
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
      isAllCompleted: json['isAllCompleted'] as bool? ?? false,
    );
  }

  final int completed;
  final int total;
  final int percentage;
  final bool isAllCompleted;

  Map<String, dynamic> toJson() => {
        'completed': completed,
        'total': total,
        'percentage': percentage,
        'isAllCompleted': isAllCompleted,
      };

  DailyProgressEntity toEntity() => DailyProgressEntity(
        completed: completed,
        total: total,
        percentage: percentage,
        isAllCompleted: isAllCompleted,
      );
}

class UserXpModel {
  const UserXpModel({
    required this.totalXp,
    required this.level,
    required this.title,
    required this.currentLevelXp,
    required this.nextLevelXp,
    required this.progressPercent,
  });

  factory UserXpModel.fromJson(Map<String, dynamic> json) {
    return UserXpModel(
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? 'Çırak',
      currentLevelXp: (json['currentLevelXp'] as num?)?.toInt() ?? 0,
      nextLevelXp: (json['nextLevelXp'] as num?)?.toInt() ?? 100,
      progressPercent: (json['progressPercent'] as num?)?.toInt() ?? 0,
    );
  }

  final int totalXp;
  final int level;
  final String title;
  final int currentLevelXp;
  final int nextLevelXp;
  final int progressPercent;

  Map<String, dynamic> toJson() => {
        'totalXp': totalXp,
        'level': level,
        'title': title,
        'currentLevelXp': currentLevelXp,
        'nextLevelXp': nextLevelXp,
        'progressPercent': progressPercent,
      };

  UserXpEntity toEntity() => UserXpEntity(
        totalXp: totalXp,
        level: level,
        title: title,
        currentLevelXp: currentLevelXp,
        nextLevelXp: nextLevelXp,
        progressPercent: progressPercent,
      );
}

class TodayHabitItemModel {
  const TodayHabitItemModel({
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

  factory TodayHabitItemModel.fromJson(Map<String, dynamic> json) {
    return TodayHabitItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      category: json['category'] as String,
      unit: json['unit'] as String?,
      dailyGoal: (json['dailyGoal'] as num).toDouble(),
      step: (json['step'] as num?)?.toDouble() ?? 1.0,
      reminderTime: json['reminderTime'] as String?,
      repeatDays: (json['repeatDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1, 2, 3, 4, 5, 6, 7],
      isPlannedToday: json['isPlannedToday'] as bool? ?? true,
      isCompletedToday: json['isCompletedToday'] as bool? ?? false,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
    );
  }

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'category': category,
        'unit': unit,
        'dailyGoal': dailyGoal,
        'step': step,
        'reminderTime': reminderTime,
        'repeatDays': repeatDays,
        'isPlannedToday': isPlannedToday,
        'isCompletedToday': isCompletedToday,
        'currentAmount': currentAmount,
        'currentStreak': currentStreak,
      };

  TodayHabitItemEntity toEntity() => TodayHabitItemEntity(
        id: id,
        name: name,
        icon: icon,
        category: category,
        unit: unit,
        dailyGoal: dailyGoal,
        step: step,
        reminderTime: reminderTime,
        repeatDays: repeatDays,
        isPlannedToday: isPlannedToday,
        isCompletedToday: isCompletedToday,
        currentAmount: currentAmount,
        currentStreak: currentStreak,
      );
}

class TodayModel {
  const TodayModel({
    required this.date,
    required this.timezone,
    required this.progress,
    required this.xp,
    required this.overallStreak,
    required this.streakFreezeCount,
    required this.habits,
  });

  factory TodayModel.fromJson(Map<String, dynamic> json) {
    return TodayModel(
      date: json['date'] as String,
      timezone: json['timezone'] as String? ?? 'Europe/Istanbul',
      progress: DailyProgressModel.fromJson(json['progress'] as Map<String, dynamic>),
      xp: UserXpModel.fromJson(json['xp'] as Map<String, dynamic>),
      overallStreak: (json['overallStreak'] as num?)?.toInt() ?? 0,
      streakFreezeCount: (json['streakFreezeCount'] as num?)?.toInt() ?? 2,
      habits: (json['habits'] as List<dynamic>?)
              ?.map((e) => TodayHabitItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  final String date;
  final String timezone;
  final DailyProgressModel progress;
  final UserXpModel xp;
  final int overallStreak;
  final int streakFreezeCount;
  final List<TodayHabitItemModel> habits;

  Map<String, dynamic> toJson() => {
        'date': date,
        'timezone': timezone,
        'progress': progress.toJson(),
        'xp': xp.toJson(),
        'overallStreak': overallStreak,
        'streakFreezeCount': streakFreezeCount,
        'habits': habits.map((e) => e.toJson()).toList(),
      };

  TodayEntity toEntity() => TodayEntity(
        date: date,
        timezone: timezone,
        progress: progress.toEntity(),
        xp: xp.toEntity(),
        overallStreak: overallStreak,
        streakFreezeCount: streakFreezeCount,
        habits: habits.map((e) => e.toEntity()).toList(),
      );
}
