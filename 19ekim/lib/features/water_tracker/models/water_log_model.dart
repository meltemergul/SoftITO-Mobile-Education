class WaterLog {
  final String id;
  final int amountMl;
  final DateTime timestamp;

  const WaterLog({
    required this.id,
    required this.amountMl,
    required this.timestamp,
  });

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
