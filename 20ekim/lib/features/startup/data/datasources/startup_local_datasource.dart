// Girişim360 — Girişim Yerel Veri Kaynağı (Data Source)
// İlk aşamada güvenli yerel demo verilerini ve kalıcı bellek işlemlerini yönetir.

import '../dto/startup_dto.dart';

abstract interface class IStartupLocalDataSource {
  Future<List<StartupDto>> getAll();
  Future<StartupDto?> getById(String id);
  Future<StartupDto> save(StartupDto dto);
  Future<void> delete(String id);
}

class StartupLocalDataSource implements IStartupLocalDataSource {
  final Map<String, StartupDto> _storage = {};

  StartupLocalDataSource() {
    _seedInitialData();
  }

  void _seedInitialData() {
    final now = DateTime.now();

    final bioLoop = StartupDto(
      id: 'startup-bioloop',
      name: 'BioLoop Tarım Teknolojileri',
      description: 'Sensör destekli akıllı sulama ve toprak mikrobiyomu optimizasyonu sağlayan yapay zekâ tabanlı tarım platformu.',
      sector: 'Akıllı Tarım & Biyoteknoloji',
      targetAudience: 'Endüstriyel tarım üreticileri, kooperatifler ve seralar.',
      businessModel: 'Donanım satışı + Yıllık SaaS yazılım lisansı.',
      teamSize: 4,
      currentStage: 'mvp',
      isArchived: false,
      createdAtIso: now.subtract(const Duration(days: 90)).toIso8601String(),
      updatedAtIso: now.toIso8601String(),
      isDemoData: true,
      tasks: [
        StartupTaskDto(
          id: 'task-1',
          title: 'Toprak analiz sensörleri için pilot saha testi',
          status: 'completed',
          dueDateIso: now.subtract(const Duration(days: 5)).toIso8601String(),
          isMilestone: true,
          assignedTo: 'Ahmet Yılmaz',
        ),
        StartupTaskDto(
          id: 'task-2',
          title: 'Mobil veri toplama uygulamasının Material 3 arayüzü',
          status: 'completed',
          dueDateIso: now.subtract(const Duration(days: 2)).toIso8601String(),
          isMilestone: false,
          assignedTo: 'Merve Kaya',
        ),
        StartupTaskDto(
          id: 'task-3',
          title: 'KVKK ve Açık Rıza Sözleşmesi avukat incelemesi',
          status: 'inProgress',
          dueDateIso: now.add(const Duration(days: 3)).toIso8601String(),
          isMilestone: true,
          assignedTo: 'Av. Mehmet Demir',
        ),
        StartupTaskDto(
          id: 'task-4',
          title: 'TÜBİTAK 1507 Ar-Ge Başvuru Dosyasının Hazırlanması',
          status: 'pending',
          dueDateIso: now.add(const Duration(days: 10)).toIso8601String(),
          isMilestone: false,
          assignedTo: 'Ahmet Yılmaz',
        ),
      ],
    );

    _storage[bioLoop.id] = bioLoop;
  }

  @override
  Future<List<StartupDto>> getAll() async {
    return _storage.values.toList();
  }

  @override
  Future<StartupDto?> getById(String id) async {
    return _storage[id];
  }

  @override
  Future<StartupDto> save(StartupDto dto) async {
    _storage[dto.id] = dto;
    return dto;
  }

  @override
  Future<void> delete(String id) async {
    _storage.remove(id);
  }
}
