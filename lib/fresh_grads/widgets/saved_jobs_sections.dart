import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SavedJobsSection extends StatelessWidget {
  final bool isDark;
  const SavedJobsSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final saved = [
      {'title': 'Full Stack Developer', 'company': 'Tech Innovators', 'salary': '\$60k - \$80k'},
      {'title': 'Software Engineer', 'company': 'Digital Solutions', 'salary': '\$55k - \$75k'},
      {'title': 'Data Analyst', 'company': 'Analytics Corp', 'salary': '\$50k - \$65k'},
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.bookmark_outline, size: 20, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
        const SizedBox(width: 8),
        Text('Saved Jobs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
      ]),
      const SizedBox(height: 12),
      ...saved.map((job) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBg : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(job['title']!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
              Text(job['company']!, style: TextStyle(fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
            ])),
            Text(job['salary']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryGreen)),
          ]),
        ),
      )),
    ]);
  }
}