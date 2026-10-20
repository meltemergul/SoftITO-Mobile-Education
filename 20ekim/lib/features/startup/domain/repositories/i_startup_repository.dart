// Girişim360 — Girişim Repository Sözleşmesi (Domain Layer)
// Presentation ve Data katmanları bu sözleşmeye göre haberleşir.

import '../entities/startup_entity.dart';

abstract interface class IStartupRepository {
  /// Sistemdeki girişimleri listeler (isteğe bağlı olarak arşivlenmişleri de içerir)
  Future<List<StartupEntity>> getStartups({bool includeArchived = false});

  /// Şu an aktif olarak seçili olan girişimi getirir
  Future<StartupEntity?> getActiveStartup();

  /// Yeni girişim kaydı ekler veya mevcut olanı günceller
  Future<StartupEntity> saveStartup(StartupEntity startup);

  /// Girişimin aşamasını günceller
  Future<StartupEntity> updateStage(String startupId, StartupStage newStage);

  /// Girişime yeni bir görev/kilometre taşı ekler
  Future<StartupEntity> addTask(String startupId, StartupTask task);

  /// Görev tamamlama durumunu değiştirir (pending <-> completed)
  Future<StartupEntity> toggleTaskStatus(String startupId, String taskId);

  /// Görevi siler
  Future<StartupEntity> deleteTask(String startupId, String taskId);

  /// Girişimi arşivler
  Future<void> archiveStartup(String startupId);
}
