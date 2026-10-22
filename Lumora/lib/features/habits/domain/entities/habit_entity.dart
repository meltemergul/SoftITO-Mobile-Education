import 'package:flutter/foundation.dart';

@immutable
class HabitEntity {
  const HabitEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.category,
    this.unit,
    required this.dailyGoal,
    required this.step,
    required this.repeatDays,
    this.reminderTime,
    required this.archived,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String name;
  final String icon;
  final String category; // 'water' | 'book' | 'sport' | 'mind' | 'custom'
  final String? unit;
  final double dailyGoal;
  final double step;
  final List<int> repeatDays; // 1: Pazartesi ... 7: Pazar
  final String? reminderTime; // "HH:mm"
  final bool archived;
  final String createdAt;

  HabitEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    String? category,
    String? unit,
    double? dailyGoal,
    double? step,
    List<int>? repeatDays,
    String? reminderTime,
    bool? archived,
    String? createdAt,
  }) {
    return HabitEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      step: step ?? this.step,
      repeatDays: repeatDays ?? this.repeatDays,
      reminderTime: reminderTime ?? this.reminderTime,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          name == other.name &&
          icon == other.icon &&
          category == other.category &&
          unit == other.unit &&
          dailyGoal == other.dailyGoal &&
          step == other.step &&
          listEquals(repeatDays, other.repeatDays) &&
          reminderTime == other.reminderTime &&
          archived == other.archived &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      icon.hashCode ^
      category.hashCode ^
      unit.hashCode ^
      dailyGoal.hashCode ^
      step.hashCode ^
      repeatDays.hashCode ^
      reminderTime.hashCode ^
      archived.hashCode ^
      createdAt.hashCode;
}

@immutable
class HabitTemplateEntity {
  const HabitTemplateEntity({
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitTemplateEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          icon == other.icon &&
          category == other.category &&
          unit == other.unit &&
          dailyGoal == other.dailyGoal &&
          step == other.step &&
          listEquals(repeatDays, other.repeatDays) &&
          reminderTime == other.reminderTime &&
          description == other.description;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      icon.hashCode ^
      category.hashCode ^
      unit.hashCode ^
      dailyGoal.hashCode ^
      step.hashCode ^
      repeatDays.hashCode ^
      reminderTime.hashCode ^
      description.hashCode;
}
