import 'package:flutter/foundation.dart';

@immutable
class BadgeEntity {
  const BadgeEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.xpReward,
    required this.targetValue,
    required this.unit,
    required this.isUnlocked,
    required this.unlockedAt,
    required this.progress,
    required this.maxProgress,
    required this.progressPercent,
  });

  final String id;
  final String name;
  final String description;
  final String category; // 'streak' | 'sport' | 'mind'
  final String icon;
  final int xpReward;
  final int targetValue;
  final String unit;
  final bool isUnlocked;
  final String? unlockedAt;
  final int progress;
  final int maxProgress;
  final int progressPercent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          category == other.category &&
          icon == other.icon &&
          xpReward == other.xpReward &&
          targetValue == other.targetValue &&
          unit == other.unit &&
          isUnlocked == other.isUnlocked &&
          unlockedAt == other.unlockedAt &&
          progress == other.progress &&
          maxProgress == other.maxProgress &&
          progressPercent == other.progressPercent;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      category.hashCode ^
      icon.hashCode ^
      xpReward.hashCode ^
      targetValue.hashCode ^
      unit.hashCode ^
      isUnlocked.hashCode ^
      unlockedAt.hashCode ^
      progress.hashCode ^
      maxProgress.hashCode ^
      progressPercent.hashCode;
}
