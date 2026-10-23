import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_settings_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<UserProfileEntity> getProfile() async {
    final model = await _remoteDataSource.getProfile();
    return model.toEntity();
  }

  @override
  Future<UserProfileEntity> updateProfile({
    String? displayName,
    String? username,
    String? avatarUrl,
  }) async {
    final model = await _remoteDataSource.updateProfile(
      displayName: displayName,
      username: username,
      avatarUrl: avatarUrl,
    );
    return model.toEntity();
  }

  @override
  Future<UserSettingsEntity> getSettings() async {
    final model = await _remoteDataSource.getSettings();
    return model.toEntity();
  }

  @override
  Future<UserSettingsEntity> updateSettings(UserSettingsEntity settings) async {
    final inputModel = UserSettingsModel(
      userId: settings.userId,
      theme: settings.theme,
      weekStartsOn: settings.weekStartsOn,
      timezone: settings.timezone,
      notifications: settings.notifications,
      streakFreezeCount: settings.streakFreezeCount,
    );

    final updatedModel = await _remoteDataSource.updateSettings(inputModel);
    return updatedModel.toEntity();
  }

  @override
  Future<String> exportData(String format) {
    return _remoteDataSource.exportData(format);
  }

  @override
  Future<void> deleteAccount() {
    return _remoteDataSource.deleteAccount();
  }

  @override
  Future<void> updateHabitGoal({
    required String habitId,
    required double dailyGoal,
  }) {
    return _remoteDataSource.updateHabitGoal(
      habitId: habitId,
      dailyGoal: dailyGoal,
    );
  }
}
