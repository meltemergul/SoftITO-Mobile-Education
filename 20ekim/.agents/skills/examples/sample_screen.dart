// ==============================================================================
// Girişim360 — Örnek Ekran Uygulaması (Sample Screen Showcase)
// Dosya: .agents/skills/examples/sample_screen.dart
// 
// Bu dosya; PROJECT.md, design/SKILL.md ve architecture/SKILL.md kılavuzlarındaki
// tüm mimari ve görsel tasarım prensiplerini eksiksiz sergileyen referans ekrandır.
// 
// Özellikler:
// - Material 3 tasarım sistemi, Dark Navy / Obsidian ve Elektrik Mavisi/Turkuaz renkleri
// - Feature-first katman ayrımı (Presentation - Domain - Data soyutlaması)
// - 5 Temel Durum: Loading, Success, Empty, Error, Initial
// - Girişim360 7 Girişim Aşaması (Fikir -> Büyüme) ve dinamik ilerleme hesaplama
// - Mentor eşleşme kartı, hukuki süreç özeti, iş planı analiz göstergesi
// - Demo verisi açık ayrımı ve eyleme dönük Türkçe kullanıcı geri bildirimleri
// ==============================================================================

import 'package:flutter/material.dart';

// ==============================================================================
// 1. DOMAIN KATMANI (Entities & Enums)
// ==============================================================================

/// Girişim360 7 Temel Girişim Aşaması (PROJECT.md Bölüm 2.1)
enum StartupStage {
  idea('Fikir', 'İş fikrinin tanımlanması ve problem tespiti', 1),
  validation('Doğrulama', 'Müşteri görüşmeleri ve pazar doğrulaması', 2),
  businessPlan('İş Planı', 'İş modeli, rakip ve finansal analiz', 3),
  mvp('MVP / Prototip', 'İlk çalışan ürünün geliştirilmesi', 4),
  incorporation('Şirketleşme', 'Resmi kuruluş, sözleşmeler ve ortaklık yapısı', 5),
  goMarket('Pazara Çıkış', 'Lansman, ilk müşteriler ve satış kanalları', 6),
  growth('Büyüme', 'Ölçeklenme, yatırım turları ve pazar payı artışı', 7);

  final String label;
  final String description;
  final int order;

  const StartupStage(this.label, this.description, this.order);
}

/// Görev ve Kilometre Taşı Durumu
enum TaskStatus { pending, inProgress, completed }

/// Görev Varlığı
@immutable
class StartupTaskEntity {
  final String id;
  final String title;
  final TaskStatus status;
  final DateTime dueDate;
  final bool isMilestone;

  const StartupTaskEntity({
    required this.id,
    required this.title,
    required this.status,
    required this.dueDate,
    this.isMilestone = false,
  });

  StartupTaskEntity copyWith({
    String? id,
    String? title,
    TaskStatus? status,
    DateTime? dueDate,
    bool? isMilestone,
  }) {
    return StartupTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      isMilestone: isMilestone ?? this.isMilestone,
    );
  }
}

/// Girişim Detay Varlığı (PROJECT.md Madde 2.1 - 2.7)
@immutable
class StartupDetailEntity {
  final String id;
  final String name;
  final String sector;
  final String pitchSummary;
  final StartupStage currentStage;
  final List<StartupTaskEntity> tasks;
  final int mentorMatchScore; // Uyum puanı % (0-100)
  final String assignedMentorName;
  final int completedLegalSteps;
  final int totalLegalSteps;
  final int businessPlanProgressScore; // % (0-100)
  final bool isDemoData;

  const StartupDetailEntity({
    required this.id,
    required this.name,
    required this.sector,
    required this.pitchSummary,
    required this.currentStage,
    required this.tasks,
    required this.mentorMatchScore,
    required this.assignedMentorName,
    required this.completedLegalSteps,
    required this.totalLegalSteps,
    required this.businessPlanProgressScore,
    this.isDemoData = true,
  });

  /// İlerleme yüzdesi hesaplama (PROJECT.md kuralı: Kural tabanlı ve test edilebilir)
  double get calculatedProgress {
    if (tasks.isEmpty) return 0.0;
    final total = tasks.length;
    final completed = tasks.where((t) => t.status == TaskStatus.completed).length;
    final milestones = tasks.where((t) => t.isMilestone);
    final completedMilestones = milestones.where((t) => t.status == TaskStatus.completed).length;

    // Görev ağırlığı %60, Kilometre taşı ağırlığı %40
    final taskRatio = completed / total;
    final milestoneRatio = milestones.isEmpty ? taskRatio : (completedMilestones / milestones.length);
    final weighted = (taskRatio * 0.6) + (milestoneRatio * 0.4);
    return (weighted * 100).clamp(0.0, 100.0);
  }
}

// ==============================================================================
// 2. PRESENTATION DURUM MODELİ (Dart 3 Sealed Class)
// ==============================================================================

@immutable
sealed class StartupScreenState {
  const StartupScreenState();
}

final class StartupScreenLoading extends StartupScreenState {
  const StartupScreenLoading();
}

final class StartupScreenSuccess extends StartupScreenState {
  final StartupDetailEntity startup;
  final bool isRefreshing;

  const StartupScreenSuccess({
    required this.startup,
    this.isRefreshing = false,
  });

  StartupScreenSuccess copyWith({
    StartupDetailEntity? startup,
    bool? isRefreshing,
  }) {
    return StartupScreenSuccess(
      startup: startup ?? this.startup,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

final class StartupScreenEmpty extends StartupScreenState {
  final String message;
  const StartupScreenEmpty({
    this.message = 'Henüz aktif bir girişim kaydınız bulunmuyor.',
  });
}

final class StartupScreenError extends StartupScreenState {
  final String errorMessage;
  final bool canRetry;

  const StartupScreenError({
    required this.errorMessage,
    this.canRetry = true,
  });
}

// ==============================================================================
// 3. CONTROLLER & DEMO VERİ KAYNAĞI
// ==============================================================================

class SampleStartupController extends ChangeNotifier {
  StartupScreenState _state = const StartupScreenLoading();
  StartupScreenState get state => _state;

  SampleStartupController() {
    loadStartupDetail();
  }

  /// Verileri asenkron yükleme (Demo veya API)
  Future<void> loadStartupDetail({bool isRefresh = false, bool triggerEmpty = false, bool triggerError = false}) async {
    if (isRefresh && _state is StartupScreenSuccess) {
      _state = (_state as StartupScreenSuccess).copyWith(isRefreshing: true);
      notifyListeners();
    } else {
      _state = const StartupScreenLoading();
      notifyListeners();
    }

    // Ağ gecikmesini simüle et
    await Future.delayed(const Duration(milliseconds: 650));

    if (triggerError) {
      _state = const StartupScreenError(
        errorMessage: 'Girişim verileri sunucudan alınırken bir bağlantı sorunu oluştu. Lütfen internetinizi kontrol edip tekrar deneyiniz.',
      );
      notifyListeners();
      return;
    }

    if (triggerEmpty) {
      _state = const StartupScreenEmpty();
      notifyListeners();
      return;
    }

    // PROJECT.md ilkelerine uygun örnek Girişim360 verisi
    final sampleStartup = StartupDetailEntity(
      id: 'startup-360-ist',
      name: 'BioLoop Tarım Teknolojileri',
      sector: 'Akıllı Tarım ve Biyoteknoloji',
      pitchSummary: 'Sensör destekli akıllı sulama ve toprak mikrobiyomu optimizasyonu sağlayan yapay zekâ tabanlı tarım platformu.',
      currentStage: StartupStage.mvp,
      mentorMatchScore: 92,
      assignedMentorName: 'Dr. Selin Aksoy (AgriTech Uzmanı)',
      completedLegalSteps: 3,
      totalLegalSteps: 5,
      businessPlanProgressScore: 78,
      isDemoData: true,
      tasks: [
        StartupTaskEntity(
          id: 'task-1',
          title: 'Toprak analiz sensörleri için pilot saha testi',
          status: TaskStatus.completed,
          dueDate: DateTime.now().subtract(const Duration(days: 3)),
          isMilestone: true,
        ),
        StartupTaskEntity(
          id: 'task-2',
          title: 'Mobil veri toplama uygulamasının Material 3 arayüzü',
          status: TaskStatus.completed,
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
          isMilestone: false,
        ),
        StartupTaskEntity(
          id: 'task-3',
          title: 'KVKK ve Açık Rıza Sözleşmesi avukat incelemesi',
          status: TaskStatus.inProgress,
          dueDate: DateTime.now().add(const Duration(days: 4)),
          isMilestone: true,
        ),
        StartupTaskEntity(
          id: 'task-4',
          title: 'TÜBİTAK 1507 Ar-Ge Başvuru Dosyasının Hazırlanması',
          status: TaskStatus.pending,
          dueDate: DateTime.now().add(const Duration(days: 10)),
          isMilestone: false,
        ),
      ],
    );

    _state = StartupScreenSuccess(startup: sampleStartup);
    notifyListeners();
  }

  /// Görev durumunu değiştirme ve ilerlemeyi yeniden hesaplama
  void toggleTask(String taskId) {
    if (_state is! StartupScreenSuccess) return;
    final currentState = _state as StartupScreenSuccess;
    final currentTasks = currentState.startup.tasks;

    final updatedTasks = currentTasks.map((task) {
      if (task.id == taskId) {
        final nextStatus = task.status == TaskStatus.completed ? TaskStatus.inProgress : TaskStatus.completed;
        return task.copyWith(status: nextStatus);
      }
      return task;
    }).toList();

    final updatedStartup = StartupDetailEntity(
      id: currentState.startup.id,
      name: currentState.startup.name,
      sector: currentState.startup.sector,
      pitchSummary: currentState.startup.pitchSummary,
      currentStage: currentState.startup.currentStage,
      tasks: updatedTasks,
      mentorMatchScore: currentState.startup.mentorMatchScore,
      assignedMentorName: currentState.startup.assignedMentorName,
      completedLegalSteps: currentState.startup.completedLegalSteps,
      totalLegalSteps: currentState.startup.totalLegalSteps,
      businessPlanProgressScore: currentState.startup.businessPlanProgressScore,
      isDemoData: currentState.startup.isDemoData,
    );

    _state = currentState.copyWith(startup: updatedStartup);
    notifyListeners();
  }

  /// Aşama güncelleme
  void updateStage(StartupStage newStage) {
    if (_state is! StartupScreenSuccess) return;
    final current = (_state as StartupScreenSuccess).startup;
    final updated = StartupDetailEntity(
      id: current.id,
      name: current.name,
      sector: current.sector,
      pitchSummary: current.pitchSummary,
      currentStage: newStage,
      tasks: current.tasks,
      mentorMatchScore: current.mentorMatchScore,
      assignedMentorName: current.assignedMentorName,
      completedLegalSteps: current.completedLegalSteps,
      totalLegalSteps: current.totalLegalSteps,
      businessPlanProgressScore: current.businessPlanProgressScore,
      isDemoData: current.isDemoData,
    );
    _state = StartupScreenSuccess(startup: updated);
    notifyListeners();
  }
}

// ==============================================================================
// 4. PRESENTATION KATMANI (UI WIDGETS)
// ==============================================================================

/// Girişim360 Örnek Ekranı (Showcase Page)
class GirisimDetailSampleScreen extends StatefulWidget {
  const GirisimDetailSampleScreen({super.key});

  @override
  State<GirisimDetailSampleScreen> createState() => _GirisimDetailSampleScreenState();
}

class _GirisimDetailSampleScreenState extends State<GirisimDetailSampleScreen> {
  late final SampleStartupController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SampleStartupController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Girişim360 — Girişim Paneli'),
        elevation: 0,
        actions: [
          // Durum test menüsü (Loading / Empty / Error / Success simülasyonu)
          PopupMenuButton<String>(
            tooltip: 'Durum Test Menüsü',
            icon: const Icon(Icons.tune_outlined),
            onSelected: (value) {
              switch (value) {
                case 'normal':
                  _controller.loadStartupDetail();
                  break;
                case 'empty':
                  _controller.loadStartupDetail(triggerEmpty: true);
                  break;
                case 'error':
                  _controller.loadStartupDetail(triggerError: true);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'normal', child: Text('Normal Durum (Veri Var)')),
              const PopupMenuItem(value: 'empty', child: Text('Boş Durum (Empty State)')),
              const PopupMenuItem(value: 'error', child: Text('Hata Durumu (Error State)')),
            ],
          ),
          IconButton(
            tooltip: 'Yenile',
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.loadStartupDetail(isRefresh: true),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final state = _controller.state;

          return switch (state) {
            StartupScreenLoading() => const _SampleLoadingView(),
            StartupScreenEmpty(message: final msg) => _SampleEmptyView(
                message: msg,
                onAction: () => _controller.loadStartupDetail(),
              ),
            StartupScreenError(errorMessage: final err) => _SampleErrorView(
                errorMessage: err,
                onRetry: () => _controller.loadStartupDetail(),
              ),
            StartupScreenSuccess(startup: final startup, isRefreshing: _) => RefreshIndicator(
                onRefresh: () => _controller.loadStartupDetail(isRefresh: true),
                child: _SampleSuccessContent(
                  startup: startup,
                  onToggleTask: _controller.toggleTask,
                  onStageSelected: _controller.updateStage,
                ),
              ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddTaskBottomSheet(context);
        },
        icon: const Icon(Icons.add_task),
        label: const Text('Yeni Görev'),
      ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yeni Kilometre Taşı veya Görev Ekle',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Görev Başlığı',
                  hintText: 'Örn: Yatırımcı sunum dosyasının tamamlanması',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(bottomSheetContext),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      if (textController.text.trim().isNotEmpty) {
                        Navigator.pop(bottomSheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('"${textController.text.trim()}" görevi eklendi.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
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
  }
}

// ==============================================================================
// 5. YÜKLENİYOR, BOŞ VE HATA DURUM BİLEŞENLERİ
// ==============================================================================

class _SampleLoadingView extends StatelessWidget {
  const _SampleLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Girişim verileri yükleniyor...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _SampleEmptyView extends StatelessWidget {
  final String message;
  final VoidCallback onAction;

  const _SampleEmptyView({required this.message, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lightbulb_outline,
                size: 56,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Girişim Bulunamadı',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: const Text('Girişim Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SampleErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _SampleErrorView({required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Bir Sorun Oluştu',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Yeniden Dene'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// 6. BAŞARI DURUMU ANA İÇERİK BİLEŞENİ
// ==============================================================================

class _SampleSuccessContent extends StatelessWidget {
  final StartupDetailEntity startup;
  final void Function(String id) onToggleTask;
  final void Function(StartupStage stage) onStageSelected;

  const _SampleSuccessContent({
    required this.startup,
    required this.onToggleTask,
    required this.onStageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // 1. Demo Rozeti ve Başlık Kartı
        _StartupHeaderCard(startup: startup),
        const SizedBox(height: 16),

        // 2. 7 Girişim Aşaması Zaman Çizelgesi
        _StartupStageSelector(
          currentStage: startup.currentStage,
          onStageSelected: onStageSelected,
        ),
        const SizedBox(height: 16),

        // 3. İlerleme ve Hızlı Metrik Kartları
        _StartupMetricsOverview(startup: startup),
        const SizedBox(height: 16),

        // 4. Görevler ve Kilometre Taşları Listesi
        _StartupTasksSection(
          tasks: startup.tasks,
          onToggleTask: onToggleTask,
        ),
        const SizedBox(height: 80), // FAB için alt boşluk
      ],
    );
  }
}

// ==============================================================================
// 7. ALT BİLEŞENLER (MODÜLER VE TEMİZ WIDGET YAPISI)
// ==============================================================================

/// Başlık ve Demo Rozeti Kartı
class _StartupHeaderCard extends StatelessWidget {
  final StartupDetailEntity startup;

  const _StartupHeaderCard({required this.startup});

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    startup.name,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (startup.isDemoData)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Demo Veri',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              startup.sector,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              startup.pitchSummary,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// 7 Girişim Aşaması Seçici ve Zaman Çizelgesi
class _StartupStageSelector extends StatelessWidget {
  final StartupStage currentStage;
  final void Function(StartupStage stage) onStageSelected;

  const _StartupStageSelector({
    required this.currentStage,
    required this.onStageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Girişim Aşaması',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Adım ${currentStage.order}/7: ${currentStage.label}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: StartupStage.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final stage = StartupStage.values[index];
              final isSelected = stage == currentStage;
              final isPassed = stage.order < currentStage.order;

              return ChoiceChip(
                selected: isSelected,
                onSelected: (_) => onStageSelected(stage),
                showCheckmark: false,
                avatar: isPassed
                    ? const Icon(Icons.check, size: 16)
                    : CircleAvatar(
                        radius: 10,
                        backgroundColor: isSelected ? colorScheme.onPrimary : colorScheme.outlineVariant,
                        child: Text(
                          '${stage.order}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                          ),
                        ),
                      ),
                label: Text(stage.label),
                labelStyle: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// İlerleme Yüzdesi ve 360 Derece Entegre Metrik Kartları
class _StartupMetricsOverview extends StatelessWidget {
  final StartupDetailEntity startup;

  const _StartupMetricsOverview({required this.startup});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = startup.calculatedProgress;

    return Column(
      children: [
        // Ana İlerleme Kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.4),
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
                    'Genel İlerleme',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
              const SizedBox(height: 10),
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
                'Aşama ilerlemesi tamamlanan görevler (%60) ve kilometre taşlarına (%40) göre hesaplanmaktadır.',
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3'lü Modül Kartları (Mentor, Hukuk, İş Planı)
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.handshake_outlined,
                iconColor: Colors.teal,
                title: 'Mentor Uyumu',
                value: '%${startup.mentorMatchScore}',
                subtitle: startup.assignedMentorName,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                icon: Icons.gavel_outlined,
                iconColor: Colors.deepPurple,
                title: 'Hukuki Süreç',
                value: '${startup.completedLegalSteps}/${startup.totalLegalSteps}',
                subtitle: 'KVKK & Sözleşmeler',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                icon: Icons.analytics_outlined,
                iconColor: Colors.indigo,
                title: 'İş Planı',
                value: '%${startup.businessPlanProgressScore}',
                subtitle: 'YZ Analizi Aktif',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: colorScheme.outline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Görevler ve Kilometre Taşları Bölümü
class _StartupTasksSection extends StatelessWidget {
  final List<StartupTaskEntity> tasks;
  final void Function(String id) onToggleTask;

  const _StartupTasksSection({
    required this.tasks,
    required this.onToggleTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aşama Görevleri ve Kilometre Taşları',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${tasks.where((t) => t.status == TaskStatus.completed).length}/${tasks.length}',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...tasks.map((task) {
          final isDone = task.status == TaskStatus.completed;

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDone
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                    : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              value: isDone,
              onChanged: (_) => onToggleTask(task.id),
              title: Row(
                children: [
                  if (task.isMilestone) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Kilometre Taşı',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? Theme.of(context).colorScheme.outline : null,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Son Tarih: ${task.dueDate.day}.${task.dueDate.month}.${task.dueDate.year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
