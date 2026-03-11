import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool isDark;

  const InfoRow({required this.icon, required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, fontWeight: FontWeight.w500)),
      ]),
    ]);
  }
}