import '../../domain/entities/calendar_month_entity.dart';

class HabitMicroDayModel extends HabitMicroDayEntity {
  const HabitMicroDayModel({
    required super.date,
    required super.isPlanned,
    required super.isCompleted,
  });

  factory HabitMicroDayModel.fromJson(Map<String, dynamic> json) {
    return HabitMicroDayModel(
      date: json['date'] as String,
      isPlanned: json['isPlanned'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'isPlanned': isPlanned,
      'isCompleted': isCompleted,
    };
  }
}

class ActiveHabitChainModel extends ActiveHabitChainEntity {
  const ActiveHabitChainModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.category,
    required super.completionRate,
    required super.currentStreak,
    required super.last7Days,
  });

  factory ActiveHabitChainModel.fromJson(Map<String, dynamic> json) {
    final rawDays = (json['last7Days'] as List<dynamic>?) ?? [];
    return ActiveHabitChainModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      category: (json['category'] as String?) ?? 'custom',
      completionRate: (json['completionRate'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      last7Days: rawDays
          .map((d) => HabitMicroDayModel.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'category': category,
      'completionRate': completionRate,
      'currentStreak': currentStreak,
      'last7Days': last7Days.map((d) => (d as HabitMicroDayModel).toJson()).toList(),
    };
  }
}

class CalendarDayModel extends CalendarDayEntity {
  const CalendarDayModel({
    required super.date,
    required super.status,
    required super.totalPlanned,
    required super.completedCount,
    required super.isToday,
  });

  factory CalendarDayModel.fromJson(Map<String, dynamic> json) {
    return CalendarDayModel(
      date: json['date'] as String,
      status: CalendarDayStatus.fromString(json['status'] as String? ?? 'empty'),
      totalPlanned: (json['totalPlanned'] as num?)?.toInt() ?? 0,
      completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
      isToday: json['isToday'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'status': status.value,
      'totalPlanned': totalPlanned,
      'completedCount': completedCount,
      'isToday': isToday,
    };
  }
}

class CalendarMonthModel extends CalendarMonthEntity {
  const CalendarMonthModel({
    required super.month,
    required super.unbrokenDays,
    required super.longestStreak,
    required super.days,
    required super.activeHabits,
  });

  factory CalendarMonthModel.fromJson(Map<String, dynamic> json) {
    final rawDays = (json['days'] as List<dynamic>?) ?? [];
    final rawHabits = (json['activeHabits'] as List<dynamic>?) ?? [];

    return CalendarMonthModel(
      month: json['month'] as String,
      unbrokenDays: (json['unbrokenDays'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      days: rawDays
          .map((d) => CalendarDayModel.fromJson(d as Map<String, dynamic>))
          .toList(),
      activeHabits: rawHabits
          .map((h) => ActiveHabitChainModel.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'unbrokenDays': unbrokenDays,
      'longestStreak': longestStreak,
      'days': days.map((d) => (d as CalendarDayModel).toJson()).toList(),
      'activeHabits': activeHabits.map((h) => (h as ActiveHabitChainModel).toJson()).toList(),
    };
  }
}
