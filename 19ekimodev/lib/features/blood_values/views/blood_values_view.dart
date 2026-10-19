import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/blood_value_ranges.dart';
import '../../../core/theme/theme_controller.dart';
import '../controllers/blood_values_controller.dart';
import '../models/blood_metric_model.dart';
import '../widgets/blood_metric_card.dart';
import '../widgets/eligibility_summary_card.dart';
import '../widgets/metric_edit_sheet.dart';

class BloodValuesPage extends StatefulWidget {
  const BloodValuesPage({super.key});

  @override
  State<BloodValuesPage> createState() => _BloodValuesPageState();
}

class _BloodValuesPageState extends State<BloodValuesPage> {
  late final BloodValuesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BloodValuesController()..loadInitialData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BloodValuesView(controller: _controller);
  }
}

class BloodValuesView extends StatelessWidget {
  final BloodValuesController controller;

  const BloodValuesView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.bloodValuesTitle),
        actions: const [ThemeToggleButton()],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: controller.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ValueListenableBuilder<String?>(
            valueListenable: controller.errorMessage,
            builder: (context, error, _) {
              if (error != null) return Center(child: Text(error));
              return _MetricsList(controller: controller);
            },
          );
        },
      ),
    );
  }
}

class _MetricsList extends StatelessWidget {
  final BloodValuesController controller;

  const _MetricsList({required this.controller});

  void _openEditor(BuildContext context, BloodMetricModel metric) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => MetricEditSheet(
        metric: metric,
        onSave: (v) => controller.updateMetricValue(metric.id, v),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<BloodMetricModel>>(
      valueListenable: controller.metrics,
      builder: (context, metrics, _) {
        if (metrics.isEmpty) {
          return const Center(child: Text('Kayıtlı değer bulunamadı.'));
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            EligibilitySummaryCard(metrics: metrics),
            _GenderSelector(controller: controller),
            for (final m in metrics)
              BloodMetricCard(
                key: ValueKey(m.id),
                metric: m,
                onTap: () => _openEditor(context, m),
              ),
          ],
        );
      },
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final BloodValuesController controller;

  const _GenderSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ValueListenableBuilder<Gender>(
        valueListenable: controller.gender,
        builder: (context, gender, _) {
          return SegmentedButton<Gender>(
            segments: const [
              ButtonSegment(
                value: Gender.female,
                label: Text('Kadın'),
                icon: Icon(Icons.female),
              ),
              ButtonSegment(
                value: Gender.male,
                label: Text('Erkek'),
                icon: Icon(Icons.male),
              ),
            ],
            selected: {gender},
            onSelectionChanged: (s) => controller.setGender(s.first),
          );
        },
      ),
    );
  }
}
