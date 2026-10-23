import '../../domain/entities/calendar_day_detail_entity.dart';
import '../../domain/entities/calendar_month_entity.dart';

class CalendarDayHabitModel extends CalendarDayHabitEntity {
  const CalendarDayHabitModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.category,
    super.unit,
    required super.dailyGoal,
    required super.step,
    required super.isPlanned,
    required super.isCompleted,
    required super.currentAmount,
    required super.targetAmount,
  });

  factory CalendarDayHabitModel.fromJson(Map<String, dynamic> json) {
    return CalendarDayHabitModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      category: (json['category'] as String?) ?? 'custom',
      unit: json['unit'] as String?,
      dailyGoal: (json['dailyGoal'] as num?)?.toDouble() ?? 1.0,
      step: (json['step'] as num?)?.toDouble() ?? 1.0,
      isPlanned: json['isPlanned'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'category': category,
      'unit': unit,
      'dailyGoal': dailyGoal,
      'step': step,
      'isPlanned': isPlanned,
      'isCompleted': isCompleted,
      'currentAmount': currentAmount,
      'targetAmount': targetAmount,
    };
  }
}

class CalendarDayDetailModel extends CalendarDayDetailEntity {
  const CalendarDayDetailModel({
    required super.date,
    required super.status,
    required super.totalPlanned,
    required super.completedCount,
    required super.habits,
  });

  factory CalendarDayDetailModel.fromJson(Map<String, dynamic> json) {
    final rawHabits = (json['habits'] as List<dynamic>?) ?? [];

    return CalendarDayDetailModel(
      date: json['date'] as String,
      status: CalendarDayStatus.fromString(json['status'] as String? ?? 'empty'),
      totalPlanned: (json['totalPlanned'] as num?)?.toInt() ?? 0,
      completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
      habits: rawHabits
          .map((h) => CalendarDayHabitModel.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'status': status.value,
      'totalPlanned': totalPlanned,
      'completedCount': completedCount,
      'habits': habits.map((h) => (h as CalendarDayHabitModel).toJson()).toList(),
    };
  }
}
