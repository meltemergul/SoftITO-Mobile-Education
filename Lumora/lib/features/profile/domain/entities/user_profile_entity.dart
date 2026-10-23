import 'package:flutter/foundation.dart';

@immutable
class UserProfileEntity {
  const UserProfileEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.username,
    required this.avatarUrl,
    required this.isGuest,
    required this.createdAt,
    required this.bestStreak,
    required this.totalGoals,
    required this.level,
  });

  final String id;
  final String? email;
  final String displayName;
  final String? username;
  final String? avatarUrl;
  final bool isGuest;
  final String createdAt;
  final int bestStreak;
  final int totalGoals;
  final int level;

  UserProfileEntity copyWith({
    String? displayName,
    String? username,
    String? avatarUrl,
  }) {
    return UserProfileEntity(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGuest: isGuest,
      createdAt: createdAt,
      bestStreak: bestStreak,
      totalGoals: totalGoals,
      level: level,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName &&
          username == other.username &&
          avatarUrl == other.avatarUrl &&
          isGuest == other.isGuest &&
          createdAt == other.createdAt &&
          bestStreak == other.bestStreak &&
          totalGoals == other.totalGoals &&
          level == other.level;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      username.hashCode ^
      avatarUrl.hashCode ^
      isGuest.hashCode ^
      createdAt.hashCode ^
      bestStreak.hashCode ^
      totalGoals.hashCode ^
      level.hashCode;
}
