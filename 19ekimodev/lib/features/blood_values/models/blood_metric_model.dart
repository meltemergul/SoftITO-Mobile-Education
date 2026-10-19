import '../../../core/constants/blood_value_ranges.dart';

enum MetricStatus { eligible, warning, ineligible }

class BloodMetricModel {
  final String id;
  final String title;
  final double currentValue;
  final double minThreshold;
  final double maxThreshold;
  final String unit;

  const BloodMetricModel({
    required this.id,
    required this.title,
    required this.currentValue,
    required this.minThreshold,
    required this.maxThreshold,
    required this.unit,
  });

  factory BloodMetricModel.fromRange({
    required String id,
    required String title,
    required double value,
    required ValueRange range,
  }) {
    return BloodMetricModel(
      id: id,
      title: title,
      currentValue: value,
      minThreshold: range.min,
      maxThreshold: range.max,
      unit: range.unit,
    );
  }

  MetricStatus get status {
    if (currentValue >= minThreshold && currentValue <= maxThreshold) {
      return MetricStatus.eligible;
    }
    const tolerance = BloodValueRanges.warningTolerance;
    final nearMin =
        currentValue < minThreshold && currentValue >= minThreshold * tolerance;
    final nearMax =
        currentValue > maxThreshold && currentValue <= maxThreshold / tolerance;
    return nearMin || nearMax ? MetricStatus.warning : MetricStatus.ineligible;
  }

  /// Slider aralığı: eşiklerin %30 dışına kadar.
  double get sliderMin => minThreshold * 0.7;
  double get sliderMax => maxThreshold * 1.3;

  BloodMetricModel copyWith({
    String? id,
    String? title,
    double? currentValue,
    double? minThreshold,
    double? maxThreshold,
    String? unit,
  }) {
    return BloodMetricModel(
      id: id ?? this.id,
      title: title ?? this.title,
      currentValue: currentValue ?? this.currentValue,
      minThreshold: minThreshold ?? this.minThreshold,
      maxThreshold: maxThreshold ?? this.maxThreshold,
      unit: unit ?? this.unit,
    );
  }

  factory BloodMetricModel.fromJson(Map<String, dynamic> json) {
    return BloodMetricModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      minThreshold: (json['minThreshold'] as num?)?.toDouble() ?? 0.0,
      maxThreshold: (json['maxThreshold'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'currentValue': currentValue,
      'minThreshold': minThreshold,
      'maxThreshold': maxThreshold,
      'unit': unit,
    };
  }
}
