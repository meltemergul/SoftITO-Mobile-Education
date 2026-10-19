import 'package:flutter/material.dart';

import '../models/urgent_request_model.dart';

class BloodGroupFilterBar extends StatelessWidget {
  final BloodGroup? selected;
  final ValueChanged<BloodGroup?> onSelected;

  const BloodGroupFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildChip(context, null, 'Tümü'),
          for (final group in BloodGroup.values)
            _buildChip(context, group, group.label),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, BloodGroup? group, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected == group,
        selectedColor: colorScheme.primary.withAlpha(46),
        onSelected: (_) => onSelected(group),
      ),
    );
  }
}
