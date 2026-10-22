import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpgradeGuestUseCase {
  const UpgradeGuestUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _repository.upgradeGuest(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
