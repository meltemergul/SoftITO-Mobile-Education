import '../entities/user_profile_entity.dart';
import '../entities/user_settings_entity.dart';

abstract class ProfileRepository {
  Future<UserProfileEntity> getProfile();
  Future<UserProfileEntity> updateProfile({
    String? displayName,
    String? username,
    String? avatarUrl,
  });
  Future<UserSettingsEntity> getSettings();
  Future<UserSettingsEntity> updateSettings(UserSettingsEntity settings);
  Future<String> exportData(String format); // 'json' or 'csv'
  Future<void> deleteAccount();
  Future<void> updateHabitGoal({
    required String habitId,
    required double dailyGoal,
  });
}
