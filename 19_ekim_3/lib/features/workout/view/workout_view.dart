import 'package:flutter/material.dart';
import '../controllers/workout_controller.dart';
import '../models/workout_model.dart';
import '../widgets/workout_add_dialog.dart';
import '../widgets/workout_card.dart';
import '../widgets/workout_summary_card.dart';

/// Egzersiz ve Kalori Takip Ekranı (StatelessWidget - Clean UI)
class WorkoutView extends StatelessWidget {
  final WorkoutController controller;

  const WorkoutView({
    super.key,
    required this.controller,
  });

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WorkoutAddSheet(onAdd: controller.addWorkout),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('susadım - Egzersiz Takibi'),
        actions: [
          IconButton(
            tooltip: 'Temizle',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: controller.clearWorkouts,
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<WorkoutStateModel>(
          valueListenable: controller.state,
          builder: (context, state, _) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WorkoutSummaryCard(state: state),
                  const SizedBox(height: 16),
                  Text(
                    'Bugünkü Egzersizler',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: state.workouts.isEmpty
                        ? const _EmptyState()
                        : ListView.builder(
                            itemCount: state.workouts.length,
                            itemBuilder: (context, index) {
                              return WorkoutCard(item: state.workouts[index]);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Egzersiz Ekle'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            'Henüz egzersiz kaydı yok',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
