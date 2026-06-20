import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SectionBox extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Widget> children;
  const SectionBox({required this.title, required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
        const SizedBox(height: 14),
        ...children,
      ]),
    );
  }
}