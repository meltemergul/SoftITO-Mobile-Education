// Girişim360 — Girişim Yönetimi Kontrolcüsü (Presentation Layer)
// PROJECT.md ve state_flow.md kurallarına tam uyumlu StateNotifier/ChangeNotifier

import 'package:flutter/material.dart';
import '../../domain/entities/startup_entity.dart';
import '../../domain/repositories/i_startup_repository.dart';

@immutable
sealed class StartupState {
  const StartupState();
}

final class StartupLoading extends StartupState {
  const StartupLoading();
}

final class StartupLoaded extends StartupState {
  final StartupEntity activeStartup;
  final List<StartupEntity> allStartups;
  final bool isActionInProgress;

  const StartupLoaded({
    required this.activeStartup,
    required this.allStartups,
    this.isActionInProgress = false,
  });

  StartupLoaded copyWith({
    StartupEntity? activeStartup,
    List<StartupEntity>? allStartups,
    bool? isActionInProgress,
  }) {
    return StartupLoaded(
      activeStartup: activeStartup ?? this.activeStartup,
      allStartups: allStartups ?? this.allStartups,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
    );
  }
}

final class StartupEmpty extends StartupState {
  final String message;
  const StartupEmpty({
    this.message = 'Henüz kayıtlı bir girişiminiz bulunmuyor.',
  });
}

final class StartupError extends StartupState {
  final String message;
  const StartupError({required this.message});
}

class StartupController extends ChangeNotifier {
  final IStartupRepository _repository;

  StartupState _state = const StartupLoading();
  StartupState get state => _state;

  StartupController(this._repository) {
    loadStartups();
  }

  Future<void> loadStartups() async {
    _state = const StartupLoading();
    notifyListeners();

    try {
      final startups = await _repository.getStartups();
      if (startups.isEmpty) {
        _state = const StartupEmpty();
      } else {
        _state = StartupLoaded(
          activeStartup: startups.first,
          allStartups: startups,
        );
      }
    } catch (e) {
      _state = StartupError(
        message: 'Girişim bilgileri yüklenirken bir sorun oluştu: $e',
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> selectStartup(String id) async {
    if (_state is! StartupLoaded) return;
    final current = _state as StartupLoaded;
    final target = current.allStartups.firstWhere((s) => s.id == id, orElse: () => current.activeStartup);

    _state = current.copyWith(activeStartup: target);
    notifyListeners();
  }

  Future<void> toggleTask(String taskId) async {
    if (_state is! StartupLoaded) return;
    final current = _state as StartupLoaded;

    try {
      final updated = await _repository.toggleTaskStatus(current.activeStartup.id, taskId);
      final updatedList = current.allStartups.map((s) => s.id == updated.id ? updated : s).toList();

      _state = current.copyWith(
        activeStartup: updated,
        allStartups: updatedList,
      );
      notifyListeners();
    } catch (e) {
      _state = StartupError(message: 'Görev güncellenirken hata oluştu: $e');
      notifyListeners();
    }
  }

  Future<void> addTask({
    required String title,
    required bool isMilestone,
    required DateTime dueDate,
    String? assignedTo,
  }) async {
    if (_state is! StartupLoaded) return;
    final current = _state as StartupLoaded;

    final newTask = StartupTask(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      status: TaskStatus.pending,
      dueDate: dueDate,
      isMilestone: isMilestone,
      assignedTo: assignedTo,
    );

    try {
      final updated = await _repository.addTask(current.activeStartup.id, newTask);
      final updatedList = current.allStartups.map((s) => s.id == updated.id ? updated : s).toList();

      _state = current.copyWith(
        activeStartup: updated,
        allStartups: updatedList,
      );
      notifyListeners();
    } catch (e) {
      _state = StartupError(message: 'Görev eklenirken hata oluştu: $e');
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    if (_state is! StartupLoaded) return;
    final current = _state as StartupLoaded;

    try {
      final updated = await _repository.deleteTask(current.activeStartup.id, taskId);
      final updatedList = current.allStartups.map((s) => s.id == updated.id ? updated : s).toList();

      _state = current.copyWith(
        activeStartup: updated,
        allStartups: updatedList,
      );
      notifyListeners();
    } catch (e) {
      _state = StartupError(message: 'Görev silinirken hata oluştu: $e');
      notifyListeners();
    }
  }

  Future<bool> advanceStage() async {
    if (_state is! StartupLoaded) return false;
    final current = _state as StartupLoaded;
    final startup = current.activeStartup;

    final next = startup.currentStage.nextStage;
    if (next == null) return false;

    // İş Kuralı: Aşama atlama koşullarını kontrol et
    if (!startup.canAdvanceStage()) {
      return false; // Koşullar sağlanmadı
    }

    try {
      final updated = await _repository.updateStage(startup.id, next);
      final updatedList = current.allStartups.map((s) => s.id == updated.id ? updated : s).toList();

      _state = current.copyWith(
        activeStartup: updated,
        allStartups: updatedList,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = StartupError(message: 'Aşama güncellenirken hata oluştu: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> setStage(StartupStage stage) async {
    if (_state is! StartupLoaded) return;
    final current = _state as StartupLoaded;

    try {
      final updated = await _repository.updateStage(current.activeStartup.id, stage);
      final updatedList = current.allStartups.map((s) => s.id == updated.id ? updated : s).toList();

      _state = current.copyWith(
        activeStartup: updated,
        allStartups: updatedList,
      );
      notifyListeners();
    } catch (e) {
      _state = StartupError(message: 'Aşama değiştirilirken hata oluştu: $e');
      notifyListeners();
    }
  }

  Future<void> saveStartupInfo({
    required String name,
    required String description,
    required String sector,
    required String targetAudience,
    required String businessModel,
    required int teamSize,
  }) async {
    if (_state is! StartupLoaded) return;
    final current = _state as StartupLoaded;

    final updated = current.activeStartup.copyWith(
      name: name,
      description: description,
      sector: sector,
      targetAudience: targetAudience,
      businessModel: businessModel,
      teamSize: teamSize,
      updatedAt: DateTime.now(),
    );

    try {
      final saved = await _repository.saveStartup(updated);
      final updatedList = current.allStartups.map((s) => s.id == saved.id ? saved : s).toList();

      _state = current.copyWith(
        activeStartup: saved,
        allStartups: updatedList,
      );
      notifyListeners();
    } catch (e) {
      _state = StartupError(message: 'Girişim güncellenirken hata oluştu: $e');
      notifyListeners();
    }
  }

  Future<void> archiveActiveStartup() async {
    if (_state is! StartupLoaded) return;
    final current = _state as StartupLoaded;

    try {
      await _repository.archiveStartup(current.activeStartup.id);
      await loadStartups();
    } catch (e) {
      _state = StartupError(message: 'Girişim arşivlenirken hata oluştu: $e');
      notifyListeners();
    }
  }
}
