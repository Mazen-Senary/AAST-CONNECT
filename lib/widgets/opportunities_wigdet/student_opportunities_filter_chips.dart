import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        SizedBox(height: 15.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: categories.map((category) {
              return FilterChip(
                label: Text(category),
                selected: selectedFilter == category,
                onSelected: (selected) => onFilterSelected?.call(category),
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                checkmarkColor: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
