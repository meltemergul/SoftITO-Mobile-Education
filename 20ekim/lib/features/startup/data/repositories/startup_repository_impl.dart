// Girişim360 — Girişim Repository Uygulaması (Data Layer Implementation)

import '../../domain/entities/startup_entity.dart';
import '../../domain/repositories/i_startup_repository.dart';
import '../datasources/startup_local_datasource.dart';
import '../dto/startup_dto.dart';

class StartupRepositoryImpl implements IStartupRepository {
  final IStartupLocalDataSource _localDataSource;

  StartupRepositoryImpl(this._localDataSource);

  @override
  Future<List<StartupEntity>> getStartups({bool includeArchived = false}) async {
    final dtos = await _localDataSource.getAll();
    final entities = dtos.map((d) => d.toEntity()).toList();

    if (includeArchived) {
      return entities;
    }
    return entities.where((e) => !e.isArchived).toList();
  }

  @override
  Future<StartupEntity?> getActiveStartup() async {
    final startups = await getStartups();
    if (startups.isEmpty) return null;
    return startups.first;
  }

  @override
  Future<StartupEntity> saveStartup(StartupEntity startup) async {
    final dto = StartupDto.fromEntity(startup);
    final saved = await _localDataSource.save(dto);
    return saved.toEntity();
  }

  @override
  Future<StartupEntity> updateStage(String startupId, StartupStage newStage) async {
    final dto = await _localDataSource.getById(startupId);
    if (dto == null) {
      throw Exception('Girişim bulunamadı: $startupId');
    }

    final entity = dto.toEntity();
    final updated = entity.copyWith(
      currentStage: newStage,
      updatedAt: DateTime.now(),
    );

    return saveStartup(updated);
  }

  @override
  Future<StartupEntity> addTask(String startupId, StartupTask task) async {
    final dto = await _localDataSource.getById(startupId);
    if (dto == null) {
      throw Exception('Girişim bulunamadı: $startupId');
    }

    final entity = dto.toEntity();
    final updatedTasks = List<StartupTask>.from(entity.tasks)..add(task);
    final updated = entity.copyWith(
      tasks: updatedTasks,
      updatedAt: DateTime.now(),
    );

    return saveStartup(updated);
  }

  @override
  Future<StartupEntity> toggleTaskStatus(String startupId, String taskId) async {
    final dto = await _localDataSource.getById(startupId);
    if (dto == null) {
      throw Exception('Girişim bulunamadı: $startupId');
    }

    final entity = dto.toEntity();
    final updatedTasks = entity.tasks.map((task) {
      if (task.id == taskId) {
        final nextStatus = task.isCompleted ? TaskStatus.inProgress : TaskStatus.completed;
        return task.copyWith(status: nextStatus);
      }
      return task;
    }).toList();

    final updated = entity.copyWith(
      tasks: updatedTasks,
      updatedAt: DateTime.now(),
    );

    return saveStartup(updated);
  }

  @override
  Future<StartupEntity> deleteTask(String startupId, String taskId) async {
    final dto = await _localDataSource.getById(startupId);
    if (dto == null) {
      throw Exception('Girişim bulunamadı: $startupId');
    }

    final entity = dto.toEntity();
    final updatedTasks = entity.tasks.where((t) => t.id != taskId).toList();
    final updated = entity.copyWith(
      tasks: updatedTasks,
      updatedAt: DateTime.now(),
    );

    return saveStartup(updated);
  }

  @override
  Future<void> archiveStartup(String startupId) async {
    final dto = await _localDataSource.getById(startupId);
    if (dto != null) {
      final updated = dto.toEntity().copyWith(
        isArchived: true,
        updatedAt: DateTime.now(),
      );
      await saveStartup(updated);
    }
  }
}
