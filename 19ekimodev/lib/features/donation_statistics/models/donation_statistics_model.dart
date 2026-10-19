class MonthlyDonationModel {
  final DateTime month;
  final int count;
  final int previousYearCount;

  const MonthlyDonationModel({
    required this.month,
    required this.count,
    required this.previousYearCount,
  });

  /// Geçen yılın aynı ayına göre yüzde değişim.
  double get changePercent => previousYearCount == 0
      ? 0
      : (count - previousYearCount) / previousYearCount * 100;

  MonthlyDonationModel copyWith({
    DateTime? month,
    int? count,
    int? previousYearCount,
  }) {
    return MonthlyDonationModel(
      month: month ?? this.month,
      count: count ?? this.count,
      previousYearCount: previousYearCount ?? this.previousYearCount,
    );
  }

  factory MonthlyDonationModel.fromJson(Map<String, dynamic> json) {
    return MonthlyDonationModel(
      month:
          DateTime.tryParse(json['month'] as String? ?? '') ?? DateTime(2000),
      count: (json['count'] as num?)?.toInt() ?? 0,
      previousYearCount: (json['previousYearCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month.toIso8601String(),
      'count': count,
      'previousYearCount': previousYearCount,
    };
  }
}

class BloodGroupShareModel {
  final String group;
  final double percent;

  const BloodGroupShareModel({required this.group, required this.percent});

  BloodGroupShareModel copyWith({String? group, double? percent}) {
    return BloodGroupShareModel(
      group: group ?? this.group,
      percent: percent ?? this.percent,
    );
  }

  factory BloodGroupShareModel.fromJson(Map<String, dynamic> json) {
    return BloodGroupShareModel(
      group: json['group'] as String? ?? '',
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'group': group, 'percent': percent};
}
