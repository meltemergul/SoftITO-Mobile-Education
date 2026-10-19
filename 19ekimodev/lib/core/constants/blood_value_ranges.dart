/// Bağış uygunluğu için tıbbi referans aralıkları (project.md §3).
/// Modeller eşikleri doğrudan yazmak yerine bu sınıftan okur (SKILL.md Kural 5).
enum Gender { female, male }

class ValueRange {
  final double min;
  final double max;
  final String unit;

  const ValueRange({required this.min, required this.max, required this.unit});
}

abstract final class BloodValueRanges {
  static const ValueRange hemoglobinFemale = ValueRange(
    min: 12.5,
    max: 16.5,
    unit: 'g/dL',
  );
  static const ValueRange hemoglobinMale = ValueRange(
    min: 13.5,
    max: 18.0,
    unit: 'g/dL',
  );
  static const ValueRange weight = ValueRange(min: 50, max: 200, unit: 'kg');
  static const ValueRange pulse = ValueRange(min: 50, max: 100, unit: 'bpm');
  static const ValueRange systolic = ValueRange(
    min: 90,
    max: 180,
    unit: 'mmHg',
  );
  static const ValueRange diastolic = ValueRange(
    min: 50,
    max: 100,
    unit: 'mmHg',
  );

  /// Eşiğin altında ama bu oran içindeyse "uyarı" kabul edilir.
  static const double warningTolerance = 0.9;

  static ValueRange hemoglobinFor(Gender gender) =>
      gender == Gender.female ? hemoglobinFemale : hemoglobinMale;
}
