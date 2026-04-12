import 'package:flutter/material.dart';

class StudentOpportunitiesSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClearSearch;
  final VoidCallback? onToggleFilters;
  final bool showFilters;

  const StudentOpportunitiesSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClearSearch,
    this.onToggleFilters,
    this.showFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: "Search programs...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showFilters
                            ? Icons.filter_list
                            : Icons.filter_list_outlined,
                      ),
                      onPressed: onToggleFilters,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
