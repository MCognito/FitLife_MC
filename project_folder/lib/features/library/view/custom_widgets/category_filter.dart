import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const CategoryFilter({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" filter chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedCategory == null,
              onSelected: (_) => onCategorySelected(null),
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          ),
          // Category filter chips
          ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: selectedCategory == category,
                  onSelected: (_) => onCategorySelected(category),
                  backgroundColor: Theme.of(context).cardColor,
                  selectedColor:
                      Theme.of(context).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                ),
              )),
        ],
      ),
    );
  }
}
