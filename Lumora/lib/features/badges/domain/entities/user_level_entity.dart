import 'package:flutter/foundation.dart';

@immutable
class UserLevelEntity {
  const UserLevelEntity({
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLevelEntity &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          title == other.title &&
          totalXp == other.totalXp &&
          currentLevelXp == other.currentLevelXp &&
          nextLevelXp == other.nextLevelXp &&
          progressPercent == other.progressPercent;

  @override
  int get hashCode =>
      level.hashCode ^
      title.hashCode ^
      totalXp.hashCode ^
      currentLevelXp.hashCode ^
      nextLevelXp.hashCode ^
      progressPercent.hashCode;
}
