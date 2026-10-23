class DailyChartEntity {
  const DailyChartEntity({
    required this.date,
    required this.dayLabel,
    required this.rate,
    required this.completed,
    required this.total,
    required this.isPeak,
  });

  final String date;
  final String dayLabel;
  final int rate;
  final int completed;
  final int total;
  final bool isPeak;
}

class CategoryDistributionEntity {
  const CategoryDistributionEntity({
    required this.category,
    required this.name,
    required this.rate,
    required this.completedCount,
    required this.totalPlanned,
  });

  final String category;
  final String name;
  final int rate;
  final int completedCount;
  final int totalPlanned;
}

class ProductiveHourEntity {
  const ProductiveHourEntity({
    required this.period,
    required this.label,
    required this.percentage,
    required this.count,
  });

  final String period;
  final String label;
  final int percentage;
  final int count;
}

class BestHabitEntity {
  const BestHabitEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.rate,
    required this.currentStreak,
  });

  final String id;
  final String name;
  final String icon;
  final String category;
  final int rate;
  final int currentStreak;
}

class HabitProgressDetailEntity {
  const HabitProgressDetailEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.rate,
    required this.completedDays,
    required this.totalPlannedDays,
    required this.currentStreak,
    required this.longestStreak,
  });

  final String id;
  final String name;
  final String icon;
  final String category;
  final int rate;
  final int completedDays;
  final int totalPlannedDays;
  final int currentStreak;
  final int longestStreak;
}

class StatsEntity {
  const StatsEntity({
    required this.range,
    required this.hasEnoughData,
    required this.overallScore,
    this.trend,
    required this.dailyChart,
    required this.categoryDistribution,
    required this.productiveHours,
    this.bestHabit,
    required this.overallStreak,
    required this.longestStreak,
    required this.totalCompletedDays,
    required this.habitProgress,
  });

  final String range;
  final bool hasEnoughData;
  final int overallScore;
  final int? trend;
  final List<DailyChartEntity> dailyChart;
  final List<CategoryDistributionEntity> categoryDistribution;
  final List<ProductiveHourEntity> productiveHours;
  final BestHabitEntity? bestHabit;
  final int overallStreak;
  final int longestStreak;
  final int totalCompletedDays;
  final List<HabitProgressDetailEntity> habitProgress;
}
