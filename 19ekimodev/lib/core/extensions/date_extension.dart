const List<String> _monthsShort = [
  'Oca',
  'Şub',
  'Mar',
  'Nis',
  'May',
  'Haz',
  'Tem',
  'Ağu',
  'Eyl',
  'Eki',
  'Kas',
  'Ara',
];

extension DateExtension on DateTime {
  /// Örn: "Eki"
  String get shortMonthTr => _monthsShort[month - 1];

  /// Örn: "19.10.2026"
  String get formattedTr =>
      '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.$year';

  /// Son bağıştan bu yana geçen gün (erkek 90, kadın 120 gün kuralı için).
  int daysSince(DateTime now) => now.difference(this).inDays;
}
