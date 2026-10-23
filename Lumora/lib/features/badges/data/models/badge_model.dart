import '../../domain/entities/badge_entity.dart';

class BadgeModel {
  const BadgeModel({
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
  final String category;
  final String icon;
  final int xpReward;
  final int targetValue;
  final String unit;
  final bool isUnlocked;
  final String? unlockedAt;
  final int progress;
  final int maxProgress;
  final int progressPercent;

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      xpReward: (json['xpReward'] as num).toInt(),
      targetValue: (json['targetValue'] as num).toInt(),
      unit: json['unit'] as String,
      isUnlocked: json['isUnlocked'] as bool,
      unlockedAt: json['unlockedAt'] as String?,
      progress: (json['progress'] as num).toInt(),
      maxProgress: (json['maxProgress'] as num).toInt(),
      progressPercent: (json['progressPercent'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'icon': icon,
      'xpReward': xpReward,
      'targetValue': targetValue,
      'unit': unit,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt,
      'progress': progress,
      'maxProgress': maxProgress,
      'progressPercent': progressPercent,
    };
  }

  BadgeEntity toEntity() {
    return BadgeEntity(
      id: id,
      name: name,
      description: description,
      category: category,
      icon: icon,
      xpReward: xpReward,
      targetValue: targetValue,
      unit: unit,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
      progress: progress,
      maxProgress: maxProgress,
      progressPercent: progressPercent,
    );
  }
}
