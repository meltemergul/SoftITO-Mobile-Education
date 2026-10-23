import 'package:flutter/material.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/widgets/app_filter_chip.dart';

class BadgeCategoryFilter extends StatelessWidget {
  const BadgeCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  static const categories = [
    {'id': 'all', 'label': 'Tümü'},
    {'id': 'streak', 'label': 'Zincirler'},
    {'id': 'sport', 'label': 'Spor & Sağlık'},
    {'id': 'mind', 'label': 'Zihin'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat['id'];
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s8),
            child: AppFilterChip(
              label: cat['label']!,
              isSelected: isSelected,
              onSelected: (_) => onCategorySelected(cat['id']!),
            ),
          );
        }).toList(),
      ),
    );
  }
}
