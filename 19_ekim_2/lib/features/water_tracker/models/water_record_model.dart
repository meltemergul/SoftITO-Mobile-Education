/// Su tüketim kaydını temsil eden değişmez (immutable) veri modeli.
class WaterRecordModel {
  //su kayıt modeli oluşturuldu.
  final String id;
  final int amountMl; //miktar
  final DateTime timestamp;
  final String source;

  const WaterRecordModel({
    //kurucu metot
    required this.id,
    required this.amountMl,
    required this.timestamp,
    required this.source,
  });

  WaterRecordModel copyWith({
    //copyWith ile
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
