import 'calendar_month_entity.dart';

class CalendarDayHabitEntity {
  const CalendarDayHabitEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    this.unit,
    required this.dailyGoal,
    required this.step,
    required this.isPlanned,
    required this.isCompleted,
    required this.currentAmount,
    required this.targetAmount,
  });

  final String id;
  final String name;
  final String icon;
  final String category;
  final String? unit;
  final double dailyGoal;
  final double step;
  final bool isPlanned;
  final bool isCompleted;
  final double currentAmount;
  final double targetAmount;
}

class CalendarDayDetailEntity {
  const CalendarDayDetailEntity({
    required this.date,
    required this.status,
    required this.totalPlanned,
    required this.completedCount,
    required this.habits,
  });

  final String date;
  final CalendarDayStatus status;
  final int totalPlanned;
  final int completedCount;
  final List<CalendarDayHabitEntity> habits;
}
