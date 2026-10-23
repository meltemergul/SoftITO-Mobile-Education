enum CalendarDayStatus {
  completed,
  partial,
  empty,
  rest,
  future;

  static CalendarDayStatus fromString(String val) {
    switch (val) {
      case 'completed':
        return CalendarDayStatus.completed;
      case 'partial':
        return CalendarDayStatus.partial;
      case 'empty':
        return CalendarDayStatus.empty;
      case 'rest':
        return CalendarDayStatus.rest;
      case 'future':
      default:
        return CalendarDayStatus.future;
    }
  }

  String get value => name;
}

class CalendarDayEntity {
  const CalendarDayEntity({
    required this.date,
    required this.status,
    required this.totalPlanned,
    required this.completedCount,
    required this.isToday,
  });

  final String date;
  final CalendarDayStatus status;
  final int totalPlanned;
  final int completedCount;
  final bool isToday;

  int get dayNumber {
    final parts = date.split('-');
    if (parts.length == 3) {
      return int.tryParse(parts[2]) ?? 1;
    }
    return 1;
  }
}

class HabitMicroDayEntity {
  const HabitMicroDayEntity({
    required this.date,
    required this.isPlanned,
    required this.isCompleted,
  });

  final String date;
  final bool isPlanned;
  final bool isCompleted;
}

class ActiveHabitChainEntity {
  const ActiveHabitChainEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.completionRate,
    required this.currentStreak,
    required this.last7Days,
  });

  final String id;
  final String name;
  final String icon;
  final String category;
  final int completionRate;
  final int currentStreak;
  final List<HabitMicroDayEntity> last7Days;
}

class CalendarMonthEntity {
  const CalendarMonthEntity({
    required this.month,
    required this.unbrokenDays,
    required this.longestStreak,
    required this.days,
    required this.activeHabits,
  });

  final String month;
  final int unbrokenDays;
  final int longestStreak;
  final List<CalendarDayEntity> days;
  final List<ActiveHabitChainEntity> activeHabits;
}
