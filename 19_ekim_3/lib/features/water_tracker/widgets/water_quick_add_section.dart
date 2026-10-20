import 'package:flutter/material.dart';

/// Hızlı su ekleme butonları bölümü (<= 40 satır build)
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
          children: [
            _QuickBtn(amount: 150, label: 'Bardak (150ml)', onAdd: onAdd),
            const SizedBox(width: 8),
            _QuickBtn(amount: 250, label: 'Kupa (250ml)', onAdd: onAdd),
            const SizedBox(width: 8),
            _QuickBtn(amount: 500, label: 'Şişe (500ml)', onAdd: onAdd),
          ],
        ),
      ],
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final int amount;
  final String label;
  final ValueChanged<int> onAdd;

  const _QuickBtn({
    required this.amount,
    required this.label,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => onAdd(amount),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, size: 20),
            const SizedBox(height: 4),
            Text(
              '$amount ml',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
