// Girişim360 — Girişim Yönetimi ve Aşama Takip Sayfası (PROJECT.md Bölüm 2.1)
// 7 Aşama Geçişi, Görevler, Kilometre Taşları, Bilgi Düzenleme ve Arşivleme

import 'package:flutter/material.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/startup_entity.dart';
import '../controllers/startup_controller.dart';

class StartupDetailPage extends StatefulWidget {
  final StartupController controller;

  const StartupDetailPage({
    super.key,
    required this.controller,
  });

  @override
  State<StartupDetailPage> createState() => _StartupDetailPageState();
}

class _StartupDetailPageState extends State<StartupDetailPage> {
  String _taskFilter = 'Tümü'; // 'Tümü', 'Kilometre Taşları', 'Tamamlananlar'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;

        return switch (state) {
          StartupLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          StartupEmpty(message: final msg) => Scaffold(
              body: AppEmptyView(
                title: 'Girişim Bulunamadı',
                message: msg,
                actionLabel: 'Yeni Girişim Oluştur',
                onAction: () => _showEditStartupDialog(context, null),
              ),
            ),
          StartupError(message: final err) => Scaffold(
              body: AppErrorView(
                errorMessage: err,
                onRetry: () => widget.controller.loadStartups(),
              ),
            ),
          StartupLoaded(activeStartup: final startup, allStartups: _) => Scaffold(
              appBar: AppBar(
                title: const Text('Girişim Yönetimi'),
                actions: [
                  IconButton(
                    tooltip: 'Girişim Bilgilerini Düzenle',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditStartupDialog(context, startup),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Daha Fazla İşlem',
                    icon: const Icon(Icons.more_vert),
                    onSelected: (val) {
                      if (val == 'archive') {
                        _showArchiveConfirmation(context, startup);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(Icons.archive_outlined, size: 20, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Girişimi Arşivle'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Girişim Başlık Kartı
                  _StartupInfoCard(startup: startup),
                  const SizedBox(height: 16),

                  // 2. 7 Girişim Aşaması Zaman Çizelgesi
                  _StageTimelineCard(
                    startup: startup,
                    onSelectStage: (stage) => widget.controller.setStage(stage),
                    onAdvanceStage: () => _handleAdvanceStage(context, startup),
                  ),
                  const SizedBox(height: 16),

                  // 3. Ağırlıklı İlerleme Kartı
                  _ProgressOverviewCard(startup: startup),
                  const SizedBox(height: 20),

                  // 4. Görev ve Kilometre Taşları Başlığı ve Filtre
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aşama Görevleri',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'Tümü', label: Text('Tümü', style: TextStyle(fontSize: 12))),
                            ButtonSegment(value: 'Kilometre Taşları', label: Text('Milestones', style: TextStyle(fontSize: 12))),
                            ButtonSegment(value: 'Tamamlananlar', label: Text('Bitti', style: TextStyle(fontSize: 12))),
                          ],
                          selected: {_taskFilter},
                          onSelectionChanged: (val) {
                            setState(() => _taskFilter = val.first);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Görev Listesi
                  ..._buildFilteredTasks(startup),
                  const SizedBox(height: 80), // FAB alanı
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => _showAddTaskBottomSheet(context),
                icon: const Icon(Icons.add_task),
                label: const Text('Yeni Görev / Milestone'),
              ),
            ),
        };
      },
    );
  }

  List<Widget> _buildFilteredTasks(StartupEntity startup) {
    var tasks = startup.tasks;
    if (_taskFilter == 'Kilometre Taşları') {
      tasks = tasks.where((t) => t.isMilestone).toList();
    } else if (_taskFilter == 'Tamamlananlar') {
      tasks = tasks.where((t) => t.isCompleted).toList();
    }

    if (tasks.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Center(
            child: Text(
              'Bu filtrede görüntülenecek görev bulunamadı.',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
        ),
      ];
    }

    return tasks.map((task) {
      return _TaskCard(
        task: task,
        onToggle: () => widget.controller.toggleTask(task.id),
        onDelete: () => widget.controller.deleteTask(task.id),
      );
    }).toList();
  }

  void _handleAdvanceStage(BuildContext context, StartupEntity startup) async {
    final next = startup.currentStage.nextStage;
    if (next == null) return;

    if (!startup.canAdvanceStage()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber),
              SizedBox(width: 8),
              Text('Aşama Geçiş Kuralı'),
            ],
          ),
          content: Text(
            '${next.label} aşamasına geçebilmek için mevcut aşamada en az 1 kilometre taşının tamamlanmış ve genel ilerlemenin en az %50 olması gerekmektedir.\n\nMevcut İlerleme: %${startup.calculatedProgress.toStringAsFixed(0)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Anladım'),
            ),
          ],
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final success = await widget.controller.advanceStage();
    if (success && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Tebrikler! ${next.label} aşamasına geçildi.'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final titleController = TextEditingController();
    final assigneeController = TextEditingController();
    bool isMilestone = false;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yeni Görev veya Kilometre Taşı',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Görev / Kilometre Taşı Başlığı *',
                      hintText: 'Örn: Yatırımcı sunum dosyasının tamamlanması',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: assigneeController,
                    decoration: const InputDecoration(
                      labelText: 'Sorumlu Kişi',
                      hintText: 'Örn: Ahmet Yılmaz',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Bu bir Kilometre Taşı (Milestone) mı?'),
                    subtitle: const Text('Aşama ilerleme hesabında %40 ağırlığa sahiptir.'),
                    value: isMilestone,
                    onChanged: (val) => setModalState(() => isMilestone = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Son Tarih: ${selectedDate.day}.${selectedDate.month}.${selectedDate.year}'),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: const Text('Tarih Seç'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('İptal'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          if (titleController.text.trim().isNotEmpty) {
                            widget.controller.addTask(
                              title: titleController.text.trim(),
                              isMilestone: isMilestone,
                              dueDate: selectedDate,
                              assignedTo: assigneeController.text.trim().isEmpty ? null : assigneeController.text.trim(),
                            );
                            Navigator.pop(ctx);
                          }
                        },
                        child: const Text('Kaydet'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditStartupDialog(BuildContext context, StartupEntity? startup) {
    final nameController = TextEditingController(text: startup?.name ?? '');
    final descController = TextEditingController(text: startup?.description ?? '');
    final sectorController = TextEditingController(text: startup?.sector ?? '');
    final audienceController = TextEditingController(text: startup?.targetAudience ?? '');
    final modelController = TextEditingController(text: startup?.businessModel ?? '');
    final teamController = TextEditingController(text: (startup?.teamSize ?? 1).toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(startup == null ? 'Yeni Girişim Oluştur' : 'Girişim Bilgilerini Düzenle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Girişim Adı *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: sectorController,
                decoration: const InputDecoration(labelText: 'Sektör *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Açıklama / Değer Önerisi'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: audienceController,
                decoration: const InputDecoration(labelText: 'Hedef Kitle'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'İş ve Gelir Modeli'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: teamController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Ekip Büyüklüğü (Kişi)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                widget.controller.saveStartupInfo(
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                  sector: sectorController.text.trim(),
                  targetAudience: audienceController.text.trim(),
                  businessModel: modelController.text.trim(),
                  teamSize: int.tryParse(teamController.text.trim()) ?? 1,
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showArchiveConfirmation(BuildContext context, StartupEntity startup) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Girişimi Arşivle'),
        content: Text('${startup.name} girişimini arşivlemek istediğinize emin misiniz? Arşivlenen girişimler ana panellerde gizlenir.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              Navigator.pop(ctx);
              widget.controller.archiveActiveStartup();
            },
            child: const Text('Arşivle'),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// ALT BİLEŞENLER
// ==============================================================================

class _StartupInfoCard extends StatelessWidget {
  final StartupEntity startup;

  const _StartupInfoCard({required this.startup});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppAvatar(
                  name: startup.name,
                  size: 48,
                  isVerified: true,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              startup.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge.demo(),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${startup.sector} • ${startup.teamSize} Kişilik Ekip',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              startup.description,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hedef Kitle', style: TextStyle(fontSize: 11, color: colorScheme.outline)),
                      Text(startup.targetAudience, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('İş Modeli', style: TextStyle(fontSize: 11, color: colorScheme.outline)),
                      Text(startup.businessModel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StageTimelineCard extends StatelessWidget {
  final StartupEntity startup;
  final void Function(StartupStage stage) onSelectStage;
  final VoidCallback onAdvanceStage;

  const _StageTimelineCard({
    required this.startup,
    required this.onSelectStage,
    required this.onAdvanceStage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final current = startup.currentStage;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Girişim Aşaması', style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.outline)),
                      const SizedBox(height: 2),
                      Text(
                        'Adım ${current.order}/7: ${current.label}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (current.nextStage != null) ...[
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: onAdvanceStage,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: Text('${current.nextStage!.label}\'a Geç'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              current.description,
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            // Yatay 7 Aşama Barı
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: StartupStage.values.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final stage = StartupStage.values[index];
                  final isCurrent = stage == current;
                  final isPassed = stage.order < current.order;

                  return FilterChip(
                    label: Text(stage.label),
                    selected: isCurrent,
                    onSelected: (_) => onSelectStage(stage),
                    avatar: isPassed ? const Icon(Icons.check, size: 14) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressOverviewCard extends StatelessWidget {
  final StartupEntity startup;

  const _ProgressOverviewCard({required this.startup});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = startup.calculatedProgress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aşama İlerlemesi',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '%${progress.toStringAsFixed(0)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 10,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Formül: Tamamlanan görevler (%60) + Kilometre taşları (%40).',
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final StartupTask task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDone = task.isCompleted;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDone ? colorScheme.primary.withValues(alpha: 0.3) : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: isDone,
                onChanged: (_) => onToggle(),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (task.isMilestone) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Milestone',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              decoration: isDone ? TextDecoration.lineThrough : null,
                              color: isDone ? colorScheme.outline : null,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Son Tarih: ${task.dueDate.day}.${task.dueDate.month}.${task.dueDate.year}'
                      '${task.assignedTo != null ? ' • ${task.assignedTo}' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: colorScheme.outline,
                onPressed: onDelete,
                tooltip: 'Görevi Sil',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
