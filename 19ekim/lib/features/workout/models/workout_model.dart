class WorkoutItem {
  final String id;
  final String title;
  final String category;
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime timestamp;

  const WorkoutItem({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.timestamp,
  });

  /// Egzersiz yoğunluğu ve kaloriye bağlı önerilen ek hidrasyon ihtiyacı (ml)
  int get recommendedWaterMl {
    final fromDuration = durationMinutes * 5;
    final fromCalories = (caloriesBurned * 0.4).round();
    return fromDuration + fromCalories;
  }

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
