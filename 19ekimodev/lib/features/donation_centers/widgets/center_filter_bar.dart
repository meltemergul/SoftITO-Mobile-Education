import 'package:flutter/material.dart';

import '../models/donation_center_model.dart';

class CenterFilterBar extends StatelessWidget {
  final CenterType? selectedType;
  final bool onlyOpen;
  final ValueChanged<CenterType?> onTypeSelected;
  final VoidCallback onToggleOpen;

  const CenterFilterBar({
    super.key,
    required this.selectedType,
    required this.onlyOpen,
    required this.onTypeSelected,
    required this.onToggleOpen,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          FilterChip(
            label: const Text('Şu an açık'),
            selected: onlyOpen,
            onSelected: (_) => onToggleOpen(),
          ),
          const SizedBox(width: 8),
          _typeChip(null, 'Tümü'),
          for (final type in CenterType.values) _typeChip(type, type.label),
        ],
      ),
    );
  }

  Widget _typeChip(CenterType? type, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedType == type,
        onSelected: (_) => onTypeSelected(type),
      ),
    );
  }
}
