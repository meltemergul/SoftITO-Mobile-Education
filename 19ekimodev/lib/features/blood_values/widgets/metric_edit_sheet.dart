import 'package:flutter/material.dart';

import '../models/blood_metric_model.dart';
import 'blood_metric_card.dart';

/// Metrik değerini slider ile düzenleyen alt sayfa.
/// Slider değeri yerel mikro durumdur (project.md §4.1); ValueNotifier ile tutulur.
class MetricEditSheet extends StatefulWidget {
  final BloodMetricModel metric;
  final ValueChanged<double> onSave;

  const MetricEditSheet({
    super.key,
    required this.metric,
    required this.onSave,
  });

  @override
  State<MetricEditSheet> createState() => _MetricEditSheetState();
}

class _MetricEditSheetState extends State<MetricEditSheet> {
  late final ValueNotifier<double> _value;

  @override
  void initState() {
    super.initState();
    final m = widget.metric;
    _value = ValueNotifier<double>(
      m.currentValue.clamp(m.sliderMin, m.sliderMax),
    );
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metric = widget.metric;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: ValueListenableBuilder<double>(
        valueListenable: _value,
        builder: (context, value, _) {
          final preview = metric.copyWith(currentValue: value);
          final color = metricStatusColor(preview.status);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(metric.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                '${formatMetric(value)} ${metric.unit}',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(color: color),
              ),
              Slider(
                value: value,
                min: metric.sliderMin,
                max: metric.sliderMax,
                activeColor: color,
                onChanged: (v) =>
                    _value.value = double.parse(v.toStringAsFixed(1)),
              ),
              FilledButton(
                onPressed: () {
                  widget.onSave(value);
                  Navigator.of(context).pop();
                },
                child: const Text('Kaydet'),
              ),
            ],
          );
        },
      ),
    );
  }
}
