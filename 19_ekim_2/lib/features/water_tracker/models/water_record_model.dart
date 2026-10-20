/// Su tüketim kaydını temsil eden değişmez (immutable) veri modeli.
class WaterRecordModel {
  final String id;
  final int amountMl;
  final DateTime timestamp;
  final String source;

  const WaterRecordModel({
    required this.id,
    required this.amountMl,
    required this.timestamp,
    required this.source,
  });

  WaterRecordModel copyWith({
    String? id,
    int? amountMl,
    DateTime? timestamp,
    String? source,
  }) {
    return WaterRecordModel(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
    );
  }

  factory WaterRecordModel.fromJson(Map<String, dynamic> json) {
    return WaterRecordModel(
      id: json['id'] as String,
      amountMl: json['amountMl'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: json['source'] as String? ?? 'Manuel',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountMl': amountMl,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
    };
  }
}
