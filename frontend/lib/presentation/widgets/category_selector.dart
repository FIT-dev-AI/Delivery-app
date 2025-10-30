// lib/presentation/widgets/category_selector.dart
// ✅ NEW: Category selector widget with horizontal scrollable chips

import 'package:flutter/material.dart';
import '../../core/constants/order_categories.dart';
import '../../core/constants/app_colors.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;
  final bool showDescription;

  const CategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.showDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Loại Hàng',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),

        // Horizontal scrollable chips
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: OrderCategories.all.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = OrderCategories.all[index];
              final isSelected = category.id == selectedCategoryId;

              return _CategoryChip(
                category: category,
                isSelected: isSelected,
                onTap: () => onCategorySelected(category.id),
              );
            },
          ),
        ),

        // Selected category description
        if (showDescription) ...[
          const SizedBox(height: 12),
          _CategoryDescription(categoryId: selectedCategoryId),
        ],
      ],
    );
  }
}

/// Individual category chip
class _CategoryChip extends StatelessWidget {
  final OrderCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? category.color.withAlpha(25)
                : Colors.grey.withAlpha(13),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? category.color
                  : Colors.grey.withAlpha(51),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji
              Text(
                category.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),

              // Icon
              Icon(
                category.icon,
                size: 20,
                color: isSelected ? category.color : textLight,
              ),
              const SizedBox(width: 6),

              // Name
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? category.color : textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Category description display
class _CategoryDescription extends StatelessWidget {
  final String categoryId;

  const _CategoryDescription({required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final category = OrderCategories.getById(categoryId);
    if (category == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: category.color.withAlpha(13),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: category.color.withAlpha(51),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: category.color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              category.description,
              style: TextStyle(
                fontSize: 13,
                color: textDark.withAlpha(204),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}