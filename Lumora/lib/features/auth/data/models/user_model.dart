import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    required super.displayName,
    super.username,
    super.avatarUrl,
    required super.isGuest,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: (json['displayName'] as String?) ?? '',
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isGuest: (json['isGuest'] as bool?) ?? false,
      createdAt: (json['createdAt'] as String?) ?? '',
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
    };
  }
}
