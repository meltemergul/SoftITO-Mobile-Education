// Girişim360 — Girişim Repository ve Veri Katmanı Testi

import 'package:flutter_test/flutter_test.dart';
import 'package:girisim360/features/startup/data/datasources/startup_local_datasource.dart';
import 'package:girisim360/features/startup/data/repositories/startup_repository_impl.dart';
import 'package:girisim360/features/startup/domain/entities/startup_entity.dart';

void main() {
  late StartupLocalDataSource dataSource;
  late StartupRepositoryImpl repository;

  setUp(() {
    dataSource = StartupLocalDataSource();
    repository = StartupRepositoryImpl(dataSource);
  });

  group('StartupRepository Testleri', () {
    test('Başlangıçta demo girişim başarıyla listelenmelidir', () async {
      final startups = await repository.getStartups();
      expect(startups.isNotEmpty, isTrue);
      expect(startups.first.name, contains('BioLoop'));
    });

    test('Yeni görev eklenebilmeli ve doğrulanmalıdır', () async {
      final startup = (await repository.getStartups()).first;
      final newTask = StartupTask(
        id: 'new-task-1',
        title: 'Yatırımcı Sunumu',
        status: TaskStatus.pending,
        dueDate: DateTime.now(),
        isMilestone: true,
      );

      final updated = await repository.addTask(startup.id, newTask);
      expect(updated.tasks.any((t) => t.id == 'new-task-1'), isTrue);
    });

    test('Görev durumu toggle edilebilmelidir (pending <-> completed)', () async {
      final startup = (await repository.getStartups()).first;
      final task = startup.tasks.firstWhere((t) => !t.isCompleted);

      final updated = await repository.toggleTaskStatus(startup.id, task.id);
      final updatedTask = updated.tasks.firstWhere((t) => t.id == task.id);
      expect(updatedTask.isCompleted, isTrue);
    });

    test('Aşama güncellenebilmelidir', () async {
      final startup = (await repository.getStartups()).first;
      final updated = await repository.updateStage(startup.id, StartupStage.incorporation);
      expect(updated.currentStage, StartupStage.incorporation);
    });
  });
}
