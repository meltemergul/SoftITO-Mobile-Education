// Girişim360 — Girişim Yönetimi Varlıkları (PROJECT.md Madde 2.1)
// 7 Girişim Aşaması, Kilometre Taşları, İlerleme Kuralları

import 'package:flutter/foundation.dart';

/// 7 Girişim Aşaması (PROJECT.md Bölüm 2.1)
enum StartupStage {
  idea(
    order: 1,
    label: 'Fikir',
    description: 'İş fikrinin tanımlanması, değer önerisi ve problem tespiti.',
    requiredMilestoneCount: 1,
  ),
  validation(
    order: 2,
    label: 'Doğrulama',
    description: 'Pazar araştırması, hedef kitle mülakatları ve problem-çözüm uyumu.',
    requiredMilestoneCount: 2,
  ),
  businessPlan(
    order: 3,
    label: 'İş Planı',
    description: 'İş modeli kanvası, gelir modeli, rakip analizi ve finansal tahminler.',
    requiredMilestoneCount: 2,
  ),
  mvp(
    order: 4,
    label: 'MVP / Prototip',
    description: 'Çekirdek özelliklere sahip ilk çalışan ürünün geliştirilmesi ve pilot testler.',
    requiredMilestoneCount: 2,
  ),
  incorporation(
    order: 5,
    label: 'Şirketleşme',
    description: 'Resmi şirket kuruluşu, kurucu sözleşmeleri, fikrî mülkiyet ve KVKK adımları.',
    requiredMilestoneCount: 2,
  ),
  goMarket(
    order: 6,
    label: 'Pazara Çıkış',
    description: 'Lansman, ilk ödeyen müşteriler, satış kanalları ve pazarlama stratejisi.',
    requiredMilestoneCount: 2,
  ),
  growth(
    order: 7,
    label: 'Büyüme',
    description: 'Ölçeklenme, ekip genişletme, yatırım turları ve pazar payı artışı.',
    requiredMilestoneCount: 3,
  );

  final int order;
  final String label;
  final String description;
  final int requiredMilestoneCount;

  const StartupStage({
    required this.order,
    required this.label,
    required this.description,
    required this.requiredMilestoneCount,
  });

  /// Sonraki aşamayı getirir (Varsa)
  StartupStage? get nextStage {
    if (order >= StartupStage.values.length) return null;
    return StartupStage.values.firstWhere((s) => s.order == order + 1);
  }

  /// Önceki aşamayı getirir (Varsa)
  StartupStage? get previousStage {
    if (order <= 1) return null;
    return StartupStage.values.firstWhere((s) => s.order == order - 1);
  }
}

/// Görev Durumu
enum TaskStatus { pending, inProgress, completed }

/// Görev ve Kilometre Taşı Varlığı
@immutable
class StartupTask {
  final String id;
  final String title;
  final TaskStatus status;
  final DateTime dueDate;
  final bool isMilestone;
  final String? assignedTo;

  const StartupTask({
    required this.id,
    required this.title,
    required this.status,
    required this.dueDate,
    this.isMilestone = false,
    this.assignedTo,
  });

  StartupTask copyWith({
    String? id,
    String? title,
    TaskStatus? status,
    DateTime? dueDate,
    bool? isMilestone,
    String? assignedTo,
  }) {
    return StartupTask(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      isMilestone: isMilestone ?? this.isMilestone,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }

  bool get isCompleted => status == TaskStatus.completed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartupTask && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Girişim Varlığı
@immutable
class StartupEntity {
  final String id;
  final String name;
  final String description;
  final String sector;
  final String targetAudience;
  final String businessModel;
  final int teamSize;
  final StartupStage currentStage;
  final List<StartupTask> tasks;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDemoData;

  const StartupEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.sector,
    required this.targetAudience,
    required this.businessModel,
    required this.teamSize,
    required this.currentStage,
    required this.tasks,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.isDemoData = true,
  });

  /// İlerleme yüzdesi hesaplama (Ağırlıklı formül: Görevler %60, Kilometre Taşları %40)
  double get calculatedProgress {
    if (tasks.isEmpty) return 0.0;

    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.isCompleted).length;

    final milestones = tasks.where((t) => t.isMilestone).toList();
    final completedMilestones = milestones.where((t) => t.isCompleted).length;

    final taskRatio = completedTasks / totalTasks;
    final milestoneRatio = milestones.isEmpty ? taskRatio : (completedMilestones / milestones.length);

    final weighted = (taskRatio * 0.6) + (milestoneRatio * 0.4);
    return (weighted * 100).clamp(0.0, 100.0);
  }

  /// Bir sonraki aşamaya geçiş kural kontrolü (İş Kuralı)
  bool canAdvanceStage() {
    if (currentStage.nextStage == null) return false;
    // Kural: Mevcut aşamada en az bir kilometre taşı tamamlanmış olmalı ve genel ilerleme %50'nin üzerinde olmalı
    final completedMilestones = tasks.where((t) => t.isMilestone && t.isCompleted).length;
    return completedMilestones >= 1 && calculatedProgress >= 50.0;
  }

  StartupEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? sector,
    String? targetAudience,
    String? businessModel,
    int? teamSize,
    StartupStage? currentStage,
    List<StartupTask>? tasks,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDemoData,
  }) {
    return StartupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sector: sector ?? this.sector,
      targetAudience: targetAudience ?? this.targetAudience,
      businessModel: businessModel ?? this.businessModel,
      teamSize: teamSize ?? this.teamSize,
      currentStage: currentStage ?? this.currentStage,
      tasks: tasks ?? this.tasks,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDemoData: isDemoData ?? this.isDemoData,
    );
  }
}
