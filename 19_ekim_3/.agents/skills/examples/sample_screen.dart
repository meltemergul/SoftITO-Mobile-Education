import 'package:flutter/material.dart';

// ============================================================================
// SUSADIM - ÖRNEK EKRAN VE MODÜLER STATE MİMARİSİ (WATER TRACKER)
// Bu dosya, project.md ve SKILL.md kurallarına tam uyumlu referans örnektir:
// 1. Ağır harici state paketi yok -> Yerel ValueNotifier & ValueListenableBuilder.
// 2. Sayfa düzeyinde setState yok.
// 3. 40 satırı geçen build metodu yok -> Parçalanmış const alt widget'lar.
// 4. Renk/metin stilleri Theme.of(context) üzerinden alınır.
// ============================================================================

/// Su takibi değişmez (immutable) veri modeli
@immutable
class WaterTrackerModel {
  final int currentWaterMl;
  final int baseGoalMl;
  final int workoutExtraMl;
  final DateTime lastUpdated;

  const WaterTrackerModel({
    required this.currentWaterMl,
    required this.baseGoalMl,
    required this.workoutExtraMl,
    required this.lastUpdated,
  });

  /// Toplam günlük hedef (temel hedef + egzersizden gelen ek su ihtiyacı)
  int get totalGoalMl => baseGoalMl + workoutExtraMl;

  /// Hedefe ulaşma oranı (0.0 - 1.0 aralığı)
  double get progressRatio {
    if (totalGoalMl == 0) return 0.0;
    return (currentWaterMl / totalGoalMl).clamp(0.0, 1.0);
  }

  /// Hedefe kalan miktar
  int get remainingMl {
    final diff = totalGoalMl - currentWaterMl;
    return diff > 0 ? diff : 0;
  }

  WaterTrackerModel copyWith({
    int? currentWaterMl,
    int? baseGoalMl,
    int? workoutExtraMl,
    DateTime? lastUpdated,
  }) {
    return WaterTrackerModel(
      currentWaterMl: currentWaterMl ?? this.currentWaterMl,
      baseGoalMl: baseGoalMl ?? this.baseGoalMl,
      workoutExtraMl: workoutExtraMl ?? this.workoutExtraMl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory WaterTrackerModel.initial() {
    return WaterTrackerModel(
      currentWaterMl: 0,
      baseGoalMl: 2000,
      workoutExtraMl: 0,
      lastUpdated: DateTime.now(),
    );
  }

  factory WaterTrackerModel.fromJson(Map<String, dynamic> json) {
    return WaterTrackerModel(
      currentWaterMl: json['currentWaterMl'] as int? ?? 0,
      baseGoalMl: json['baseGoalMl'] as int? ?? 2000,
      workoutExtraMl: json['workoutExtraMl'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentWaterMl': currentWaterMl,
      'baseGoalMl': baseGoalMl,
      'workoutExtraMl': workoutExtraMl,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

/// Su takibi iş mantığı ve reaktif durum yöneticisi
class WaterTrackerController {
  final ValueNotifier<WaterTrackerModel> state =
      ValueNotifier<WaterTrackerModel>(WaterTrackerModel.initial());

  /// Su tüketimi ekle (örn. 250ml veya 500ml)
  void addWater(int amountMl) {
    if (amountMl <= 0) return;
    final current = state.value;
    state.value = current.copyWith(
      currentWaterMl: current.currentWaterMl + amountMl,
      lastUpdated: DateTime.now(),
    );
  }

  /// Egzersizden gelen ek su ihtiyacını hedefe dahil et
  void addWorkoutExtra(int extraMl) {
    if (extraMl <= 0) return;
    final current = state.value;
    state.value = current.copyWith(
      workoutExtraMl: current.workoutExtraMl + extraMl,
      lastUpdated: DateTime.now(),
    );
  }

  /// Günlük sayacı sıfırla
  void resetWater() {
    final current = state.value;
    state.value = current.copyWith(
      currentWaterMl: 0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Bellek sızıntısını önlemek için dinleyicileri serbest bırak
  void dispose() {
    state.dispose();
  }
}

/// Ana Su Takibi Ekranı (StatelessWidget - Clean UI)
class WaterTrackerView extends StatelessWidget {
  final WaterTrackerController controller;

  const WaterTrackerView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('susadım - Su Takibi'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sıfırla',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.resetWater,
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<WaterTrackerModel>(
          valueListenable: controller.state,
          builder: (context, model, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WaterProgressCard(model: model),
                  const SizedBox(height: 16),
                  WaterStatsGrid(model: model),
                  const SizedBox(height: 24),
                  WaterQuickAddSection(onAdd: controller.addWater),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// İlerleme yüzdesi ve kalan miktar kartı (<= 40 satır)
class WaterProgressCard extends StatelessWidget {
  final WaterTrackerModel model;

  const WaterProgressCard({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (model.progressRatio * 100).toInt();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Text(
              '${model.currentWaterMl} / ${model.totalGoalMl} ml',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Günlük Hedef Tamamlanma: %$percentage',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: model.progressRatio,
                minHeight: 14,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// İstatistik özet gridi (Egzersiz ek su ve kalan miktar) (<= 40 satır)
class WaterStatsGrid extends StatelessWidget {
  final WaterTrackerModel model;

  const WaterStatsGrid({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            title: 'Kalan İhtiyaç',
            value: '${model.remainingMl} ml',
            icon: Icons.water_drop_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            title: 'Egzersiz Ek',
            value: '+${model.workoutExtraMl} ml',
            icon: Icons.fitness_center_rounded,
          ),
        ),
      ],
    );
  }
}

/// Küçük istatistik kutusu bileşeni (<= 40 satır)
class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.secondary, size: 24),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hızlı su ekleme butonları bölümü (<= 40 satır)
class WaterQuickAddSection extends StatelessWidget {
  final ValueChanged<int> onAdd;

  const WaterQuickAddSection({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Su Ekle',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _QuickAddButton(amount: 150, label: 'Bardak (150 ml)', onAdd: onAdd),
            _QuickAddButton(amount: 250, label: 'Kupa (250 ml)', onAdd: onAdd),
            _QuickAddButton(amount: 500, label: 'Şişe (500 ml)', onAdd: onAdd),
          ],
        ),
      ],
    );
  }
}

/// Tekil hızlı ekleme butonu (<= 40 satır)
class _QuickAddButton extends StatelessWidget {
  final int amount;
  final String label;
  final ValueChanged<int> onAdd;

  const _QuickAddButton({
    required this.amount,
    required this.label,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: FilledButton.tonal(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () => onAdd(amount),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 18),
              const SizedBox(height: 4),
              Text(
                '$amount ml',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
