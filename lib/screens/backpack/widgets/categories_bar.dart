import 'package:flutter/material.dart';
import '../models/suggestion_item.dart';
import '../theme/backpack_theme.dart';

/// Horizontally scrollable segmented category pills.
class CategoriesBar extends StatelessWidget {
  final ItemCategory selectedCategory;
  final ValueChanged<ItemCategory> onCategorySelected;

  const CategoriesBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: ItemCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = ItemCategory.values[index];
          final isSelected = category == selectedCategory;

          return InkWell(
            onTap: () => onCategorySelected(category),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BackpackDecorations.pillDecoration(
                isSelected: isSelected,
                activeColor: BackpackColors.primaryPurple,
              ),
              child: Center(
                child: Text(
                  category.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : BackpackColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
