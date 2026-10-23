import '../../domain/entities/stats_entity.dart';

class DailyChartModel extends DailyChartEntity {
  const DailyChartModel({
    required super.date,
    required super.dayLabel,
    required super.rate,
    required super.completed,
    required super.total,
    required super.isPeak,
  });

  factory DailyChartModel.fromJson(Map<String, dynamic> json) {
    return DailyChartModel(
      date: json['date'] as String,
      dayLabel: json['dayLabel'] as String,
      rate: (json['rate'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      isPeak: json['isPeak'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'dayLabel': dayLabel,
      'rate': rate,
      'completed': completed,
      'total': total,
      'isPeak': isPeak,
    };
  }
}

class CategoryDistributionModel extends CategoryDistributionEntity {
  const CategoryDistributionModel({
    required super.category,
    required super.name,
    required super.rate,
    required super.completedCount,
    required super.totalPlanned,
  });

  factory CategoryDistributionModel.fromJson(Map<String, dynamic> json) {
    return CategoryDistributionModel(
      category: json['category'] as String,
      name: json['name'] as String,
      rate: (json['rate'] as num?)?.toInt() ?? 0,
      completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
      totalPlanned: (json['totalPlanned'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'name': name,
      'rate': rate,
      'completedCount': completedCount,
      'totalPlanned': totalPlanned,
    };
  }
}

class ProductiveHourModel extends ProductiveHourEntity {
  const ProductiveHourModel({
    required super.period,
    required super.label,
    required super.percentage,
    required super.count,
  });

  factory ProductiveHourModel.fromJson(Map<String, dynamic> json) {
    return ProductiveHourModel(
      period: json['period'] as String,
      label: json['label'] as String,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'label': label,
      'percentage': percentage,
      'count': count,
    };
  }
}

class BestHabitModel extends BestHabitEntity {
  const BestHabitModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.category,
    required super.rate,
    required super.currentStreak,
  });

  factory BestHabitModel.fromJson(Map<String, dynamic> json) {
    return BestHabitModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      category: (json['category'] as String?) ?? 'custom',
      rate: (json['rate'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'category': category,
      'rate': rate,
      'currentStreak': currentStreak,
    };
  }
}

class HabitProgressDetailModel extends HabitProgressDetailEntity {
  const HabitProgressDetailModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.category,
    required super.rate,
    required super.completedDays,
    required super.totalPlannedDays,
    required super.currentStreak,
    required super.longestStreak,
  });

  factory HabitProgressDetailModel.fromJson(Map<String, dynamic> json) {
    return HabitProgressDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      category: (json['category'] as String?) ?? 'custom',
      rate: (json['rate'] as num?)?.toInt() ?? 0,
      completedDays: (json['completedDays'] as num?)?.toInt() ?? 0,
      totalPlannedDays: (json['totalPlannedDays'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'category': category,
      'rate': rate,
      'completedDays': completedDays,
      'totalPlannedDays': totalPlannedDays,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }
}

class StatsModel extends StatsEntity {
  const StatsModel({
    required super.range,
    required super.hasEnoughData,
    required super.overallScore,
    super.trend,
    required super.dailyChart,
    required super.categoryDistribution,
    required super.productiveHours,
    super.bestHabit,
    required super.overallStreak,
    required super.longestStreak,
    required super.totalCompletedDays,
    required super.habitProgress,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    final rawChart = (json['dailyChart'] as List<dynamic>?) ?? [];
    final rawCategories = (json['categoryDistribution'] as List<dynamic>?) ?? [];
    final rawHours = (json['productiveHours'] as List<dynamic>?) ?? [];
    final rawProgress = (json['habitProgress'] as List<dynamic>?) ?? [];

    return StatsModel(
      range: json['range'] as String? ?? 'weekly',
      hasEnoughData: json['hasEnoughData'] as bool? ?? false,
      overallScore: (json['overallScore'] as num?)?.toInt() ?? 0,
      trend: (json['trend'] as num?)?.toInt(),
      dailyChart: rawChart
          .map((c) => DailyChartModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      categoryDistribution: rawCategories
          .map((c) => CategoryDistributionModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      productiveHours: rawHours
          .map((h) => ProductiveHourModel.fromJson(h as Map<String, dynamic>))
          .toList(),
      bestHabit: json['bestHabit'] != null
          ? BestHabitModel.fromJson(json['bestHabit'] as Map<String, dynamic>)
          : null,
      overallStreak: (json['overallStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      totalCompletedDays: (json['totalCompletedDays'] as num?)?.toInt() ?? 0,
      habitProgress: rawProgress
          .map((p) => HabitProgressDetailModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'range': range,
      'hasEnoughData': hasEnoughData,
      'overallScore': overallScore,
      'trend': trend,
      'dailyChart': dailyChart.map((c) => (c as DailyChartModel).toJson()).toList(),
      'categoryDistribution':
          categoryDistribution.map((c) => (c as CategoryDistributionModel).toJson()).toList(),
      'productiveHours':
          productiveHours.map((h) => (h as ProductiveHourModel).toJson()).toList(),
      'bestHabit': (bestHabit as BestHabitModel?)?.toJson(),
      'overallStreak': overallStreak,
      'longestStreak': longestStreak,
      'totalCompletedDays': totalCompletedDays,
      'habitProgress':
          habitProgress.map((p) => (p as HabitProgressDetailModel).toJson()).toList(),
    };
  }
}
