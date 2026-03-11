import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SummaryItem extends StatelessWidget {
  final String value, label;
  final bool isDark;
  const SummaryItem({required this.value, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.accentBlue)),
    ]);
  }
}