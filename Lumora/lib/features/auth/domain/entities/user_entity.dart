class UserEntity {
  const UserEntity({
    required this.id,
    this.email,
    required this.displayName,
    this.username,
    this.avatarUrl,
    required this.isGuest,
    required this.createdAt,
  });

  final String id;
  final String? email;
  final String displayName;
  final String? username;
  final String? avatarUrl;
  final bool isGuest;
  final String createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ (email?.hashCode ?? 0);
}
