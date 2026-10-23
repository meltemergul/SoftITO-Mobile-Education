import '../../domain/entities/user_level_entity.dart';

class UserLevelModel {
  const UserLevelModel({
    required this.level,
    required this.title,
    required this.totalXp,
    required this.currentLevelXp,
    required this.nextLevelXp,
    required this.progressPercent,
  });

  final int level;
  final String title;
  final int totalXp;
  final int currentLevelXp;
  final int nextLevelXp;
  final int progressPercent;

  factory UserLevelModel.fromJson(Map<String, dynamic> json) {
    return UserLevelModel(
      level: (json['level'] as num).toInt(),
      title: json['title'] as String,
      totalXp: (json['totalXp'] as num).toInt(),
      currentLevelXp: (json['currentLevelXp'] as num).toInt(),
      nextLevelXp: (json['nextLevelXp'] as num).toInt(),
      progressPercent: (json['progressPercent'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'title': title,
      'totalXp': totalXp,
      'currentLevelXp': currentLevelXp,
      'nextLevelXp': nextLevelXp,
      'progressPercent': progressPercent,
    };
  }

  UserLevelEntity toEntity() {
    return UserLevelEntity(
      level: level,
      title: title,
      totalXp: totalXp,
      currentLevelXp: currentLevelXp,
      nextLevelXp: nextLevelXp,
      progressPercent: progressPercent,
    );
  }
}
