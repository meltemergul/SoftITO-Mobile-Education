// Girişim360 — Girişim İlerleme ve Aşama Kuralları Birim Testi
// PROJECT.md Bölüm 2.1 & 8 kurallarına göre test edilmiştir.

import 'package:flutter_test/flutter_test.dart';
import 'package:girisim360/features/startup/domain/entities/startup_entity.dart';

void main() {
  group('Girişim İlerleme ve Aşama Geçiş Testleri', () {
    test('Hiç görev yoksa ilerleme %0 olmalıdır', () {
      final startup = StartupEntity(
        id: 'test-1',
        name: 'Test Startup',
        description: 'Test açıklama',
        sector: 'Teknoloji',
        targetAudience: 'B2B',
        businessModel: 'SaaS',
        teamSize: 2,
        currentStage: StartupStage.idea,
        tasks: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(startup.calculatedProgress, 0.0);
    });

    test('Görevler ve kilometre taşları ağırlıklı formülle hesaplanmalıdır (%60 Görev, %40 Milestone)', () {
      // 2 görev (1'i bitti: %50), 2 kilometre taşı (1'i bitti: %50) -> Toplam %50
      final startup = StartupEntity(
        id: 'test-2',
        name: 'Test Startup',
        description: 'Test açıklama',
        sector: 'Teknoloji',
        targetAudience: 'B2B',
        businessModel: 'SaaS',
        teamSize: 2,
        currentStage: StartupStage.validation,
        tasks: [
          StartupTask(
            id: 't1',
            title: 'Görev 1',
            status: TaskStatus.completed,
            dueDate: DateTime.now(),
            isMilestone: false,
          ),
          StartupTask(
            id: 't2',
            title: 'Görev 2',
            status: TaskStatus.pending,
            dueDate: DateTime.now(),
            isMilestone: false,
          ),
          StartupTask(
            id: 'm1',
            title: 'Milestone 1',
            status: TaskStatus.completed,
            dueDate: DateTime.now(),
            isMilestone: true,
          ),
          StartupTask(
            id: 'm2',
            title: 'Milestone 2',
            status: TaskStatus.pending,
            dueDate: DateTime.now(),
            isMilestone: true,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // (2 bitti / 4 toplam = 0.5 * 0.6 = 0.3) + (1 bitti / 2 milestone = 0.5 * 0.4 = 0.2) = 0.5 (%50)
      expect(startup.calculatedProgress, 50.0);
    });

    test('Aşama atlama kuralı: En az 1 tamamlanmış kilometre taşı ve %50 üzeri ilerleme gereklidir', () {
      final startupReady = StartupEntity(
        id: 'test-3',
        name: 'Hazır Girişim',
        description: 'Test açıklama',
        sector: 'Fintech',
        targetAudience: 'B2C',
        businessModel: 'Freemium',
        teamSize: 3,
        currentStage: StartupStage.idea,
        tasks: [
          StartupTask(
            id: 'm1',
            title: 'Kilometre Taşı 1',
            status: TaskStatus.completed,
            dueDate: DateTime.now(),
            isMilestone: true,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(startupReady.calculatedProgress, 100.0);
      expect(startupReady.canAdvanceStage(), isTrue);
    });

    test('Aşama atlama kuralı: İlerleme %50 altındaysa sonraki aşamaya geçiş reddedilmelidir', () {
      final startupNotReady = StartupEntity(
        id: 'test-4',
        name: 'Eksik Girişim',
        description: 'Test açıklama',
        sector: 'Fintech',
        targetAudience: 'B2C',
        businessModel: 'Freemium',
        teamSize: 3,
        currentStage: StartupStage.idea,
        tasks: [
          StartupTask(
            id: 'm1',
            title: 'Kilometre Taşı 1',
            status: TaskStatus.pending,
            dueDate: DateTime.now(),
            isMilestone: true,
          ),
          StartupTask(
            id: 't1',
            title: 'Görev 1',
            status: TaskStatus.pending,
            dueDate: DateTime.now(),
            isMilestone: false,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(startupNotReady.calculatedProgress, 0.0);
      expect(startupNotReady.canAdvanceStage(), isFalse);
    });
  });
}
