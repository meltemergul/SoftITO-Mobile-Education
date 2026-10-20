import 'package:flutter/material.dart';
import '../models/workout_model.dart';

/// Yeni Egzersiz Ekleme Modalı (Sadece lokal mikro UI durumu için StatefulWidget)
class WorkoutAddSheet extends StatefulWidget {
  final void Function(WorkoutType type, int duration) onAdd;

  const WorkoutAddSheet({
    super.key,
    required this.onAdd,
  });

  @override
  State<WorkoutAddSheet> createState() => _WorkoutAddSheetState();
}

class _WorkoutAddSheetState extends State<WorkoutAddSheet> {
  WorkoutType _selectedType = WorkoutType.cardio;
  int _duration = 30;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            selectedType: _selectedType,
            duration: _duration,
          ),
          const SizedBox(height: 16),
          _TypeSelector(
            selectedType: _selectedType,
            onChanged: (type) => setState(() => _selectedType = type),
          ),
          const SizedBox(height: 16),
          _DurationSelector(
            duration: _duration,
            onChanged: (val) => setState(() => _duration = val),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              widget.onAdd(_selectedType, _duration);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('Egzersizi Kaydet & Su Ekle'),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final WorkoutType selectedType;
  final int duration;

  const _Header({required this.selectedType, required this.duration});

  @override
  Widget build(BuildContext context) {
    final extraWater = duration * selectedType.waterPerMinuteMl;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Egzersiz Ekle',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Chip(
          label: Text('+$extraWater ml su'),
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        ),
      ],
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final WorkoutType selectedType;
  final ValueChanged<WorkoutType> onChanged;

  const _TypeSelector({required this.selectedType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<WorkoutType>(
      initialValue: selectedType,
      decoration: const InputDecoration(
        labelText: 'Egzersiz Türü',
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      items: WorkoutType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.label),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _DurationSelector extends StatelessWidget {
  final int duration;
  final ValueChanged<int> onChanged;

  const _DurationSelector({required this.duration, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Süre: '),
        Expanded(
          child: Slider(
            value: duration.toDouble(),
            min: 5,
            max: 120,
            divisions: 23,
            label: '$duration dk',
            onChanged: (val) => onChanged(val.round()),
          ),
        ),
        Text('$duration dk', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
