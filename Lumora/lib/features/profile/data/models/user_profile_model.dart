import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel {
  const UserProfileModel({
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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>? ?? json;
    final metricsMap = json['quickMetrics'] as Map<String, dynamic>? ?? {};

    return UserProfileModel(
      id: userMap['id'] as String,
      email: userMap['email'] as String?,
      displayName: userMap['displayName'] as String? ?? 'Kullanıcı',
      username: userMap['username'] as String?,
      avatarUrl: userMap['avatarUrl'] as String?,
      isGuest: userMap['isGuest'] as bool? ?? false,
      createdAt: userMap['createdAt'] as String? ?? '',
      bestStreak: (metricsMap['bestStreak'] as num?)?.toInt() ?? 0,
      totalGoals: (metricsMap['totalGoals'] as num?)?.toInt() ?? 0,
      level: (metricsMap['level'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'username': username,
      'avatarUrl': avatarUrl,
      'isGuest': isGuest,
      'createdAt': createdAt,
      'quickMetrics': {
        'bestStreak': bestStreak,
        'totalGoals': totalGoals,
        'level': level,
      },
    };
  }

  UserProfileEntity toEntity() {
    return UserProfileEntity(
      id: id,
      email: email,
      displayName: displayName,
      username: username,
      avatarUrl: avatarUrl,
      isGuest: isGuest,
      createdAt: createdAt,
      bestStreak: bestStreak,
      totalGoals: totalGoals,
      level: level,
    );
  }
}
