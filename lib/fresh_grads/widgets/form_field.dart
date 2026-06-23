import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final bool isDark;
  final bool readOnly;
  const FormField({
    required this.label,
    required this.controller,
    this.icon,
    required this.isDark,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
      const SizedBox(height: 6),
      TextField(controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, size: 16,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary) : null,
          filled: true,
          fillColor: isDark ? AppColors.darkCardBg : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      ),
    ]);
  }
}
