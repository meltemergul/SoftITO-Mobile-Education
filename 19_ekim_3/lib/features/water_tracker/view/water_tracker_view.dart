import 'package:flutter/material.dart';
import '../controllers/water_tracker_controller.dart';
import '../models/water_tracker_model.dart';
import '../widgets/water_progress_card.dart';
import '../widgets/water_quick_add_section.dart';
import '../widgets/water_stats_grid.dart';

/// Akıllı Su Takip Ekranı (StatelessWidget - Clean UI)
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
