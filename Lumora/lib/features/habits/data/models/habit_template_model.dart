import '../../domain/entities/habit_entity.dart';

class HabitTemplateModel {
  const HabitTemplateModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    this.unit,
    required this.dailyGoal,
    required this.step,
    required this.repeatDays,
    this.reminderTime,
    required this.description,
  });

  factory HabitTemplateModel.fromJson(Map<String, dynamic> json) {
    return HabitTemplateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      category: json['category'] as String,
      unit: json['unit'] as String?,
      dailyGoal: (json['dailyGoal'] as num).toDouble(),
      step: (json['step'] as num?)?.toDouble() ?? 1.0,
      repeatDays: (json['repeatDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1, 2, 3, 4, 5, 6, 7],
      reminderTime: json['reminderTime'] as String?,
      description: json['description'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final String icon;
  final String category;
  final String? unit;
  final double dailyGoal;
  final double step;
  final List<int> repeatDays;
  final String? reminderTime;
  final String description;

  HabitTemplateEntity toEntity() {
    return HabitTemplateEntity(
      id: id,
      name: name,
      icon: icon,
      category: category,
      unit: unit,
      dailyGoal: dailyGoal,
      step: step,
      repeatDays: repeatDays,
      reminderTime: reminderTime,
      description: description,
    );
  }
}
