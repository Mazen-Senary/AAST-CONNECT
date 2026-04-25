import 'package:flutter/material.dart';

class StudentOpportunitiesFilterChips extends StatelessWidget {
  final List<String> categories;
  final String selectedFilter;
  final void Function(String)? onFilterSelected;

  const StudentOpportunitiesFilterChips({
    super.key,
    required this.categories,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: selectedFilter == category,
                  onSelected: (selected) => onFilterSelected?.call(category),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
