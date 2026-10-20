// Girişim360 — Girişim DTO (Data Transfer Object)
// JSON serileştirme ve Domain Entity mappers

import '../../domain/entities/startup_entity.dart';

class StartupTaskDto {
  final String id;
  final String title;
  final String status;
  final String dueDateIso;
  final bool isMilestone;
  final String? assignedTo;

  const StartupTaskDto({
    required this.id,
    required this.title,
    required this.status,
    required this.dueDateIso,
    this.isMilestone = false,
    this.assignedTo,
  });

  factory StartupTaskDto.fromJson(Map<String, dynamic> json) {
    return StartupTaskDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      dueDateIso: json['due_date'] as String? ?? DateTime.now().toIso8601String(),
      isMilestone: json['is_milestone'] as bool? ?? false,
      assignedTo: json['assigned_to'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'due_date': dueDateIso,
      'is_milestone': isMilestone,
      'assigned_to': assignedTo,
    };
  }

  StartupTask toEntity() {
    TaskStatus taskStatus;
    switch (status) {
      case 'completed':
        taskStatus = TaskStatus.completed;
        break;
      case 'inProgress':
        taskStatus = TaskStatus.inProgress;
        break;
      default:
        taskStatus = TaskStatus.pending;
    }

    return StartupTask(
      id: id,
      title: title,
      status: taskStatus,
      dueDate: DateTime.tryParse(dueDateIso) ?? DateTime.now(),
      isMilestone: isMilestone,
      assignedTo: assignedTo,
    );
  }

  factory StartupTaskDto.fromEntity(StartupTask entity) {
    return StartupTaskDto(
      id: entity.id,
      title: entity.title,
      status: entity.status.name,
      dueDateIso: entity.dueDate.toIso8601String(),
      isMilestone: entity.isMilestone,
      assignedTo: entity.assignedTo,
    );
  }
}

class StartupDto {
  final String id;
  final String name;
  final String description;
  final String sector;
  final String targetAudience;
  final String businessModel;
  final int teamSize;
  final String currentStage;
  final List<StartupTaskDto> tasks;
  final bool isArchived;
  final String createdAtIso;
  final String updatedAtIso;
  final bool isDemoData;

  const StartupDto({
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
    required this.createdAtIso,
    required this.updatedAtIso,
    this.isDemoData = true,
  });

  factory StartupDto.fromJson(Map<String, dynamic> json) {
    return StartupDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      sector: json['sector'] as String? ?? '',
      targetAudience: json['target_audience'] as String? ?? '',
      businessModel: json['business_model'] as String? ?? '',
      teamSize: json['team_size'] as int? ?? 1,
      currentStage: json['current_stage'] as String? ?? 'idea',
      tasks: (json['tasks'] as List<dynamic>? ?? [])
          .map((t) => StartupTaskDto.fromJson(t as Map<String, dynamic>))
          .toList(),
      isArchived: json['is_archived'] as bool? ?? false,
      createdAtIso: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAtIso: json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      isDemoData: json['is_demo_data'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sector': sector,
      'target_audience': targetAudience,
      'business_model': businessModel,
      'team_size': teamSize,
      'current_stage': currentStage,
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'is_archived': isArchived,
      'created_at': createdAtIso,
      'updated_at': updatedAtIso,
      'is_demo_data': isDemoData,
    };
  }

  StartupEntity toEntity() {
    final stage = StartupStage.values.firstWhere(
      (s) => s.name == currentStage,
      orElse: () => StartupStage.idea,
    );

    return StartupEntity(
      id: id,
      name: name,
      description: description,
      sector: sector,
      targetAudience: targetAudience,
      businessModel: businessModel,
      teamSize: teamSize,
      currentStage: stage,
      tasks: tasks.map((t) => t.toEntity()).toList(),
      isArchived: isArchived,
      createdAt: DateTime.tryParse(createdAtIso) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedAtIso) ?? DateTime.now(),
      isDemoData: isDemoData,
    );
  }

  factory StartupDto.fromEntity(StartupEntity entity) {
    return StartupDto(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      sector: entity.sector,
      targetAudience: entity.targetAudience,
      businessModel: entity.businessModel,
      teamSize: entity.teamSize,
      currentStage: entity.currentStage.name,
      tasks: entity.tasks.map((t) => StartupTaskDto.fromEntity(t)).toList(),
      isArchived: entity.isArchived,
      createdAtIso: entity.createdAt.toIso8601String(),
      updatedAtIso: entity.updatedAt.toIso8601String(),
      isDemoData: entity.isDemoData,
    );
  }
}
