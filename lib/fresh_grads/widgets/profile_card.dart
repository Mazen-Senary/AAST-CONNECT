import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'info_row.dart';

class ProfileInfoCard extends StatelessWidget {
  final String initials, firstName, lastName, major, gpa, email, phone, bio;
  final bool isDark;

  const ProfileInfoCard({required this.initials, required this.firstName, required this.lastName,
    required this.major, required this.gpa, required this.email, required this.phone,
    required this.bio, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 54, height: 54,
              decoration: BoxDecoration(color: const Color(0xFF4A7C59), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$firstName $lastName', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
            Text('$major • Class of 2024', style: TextStyle(fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
            Text('ID: 2', style: TextStyle(fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
          ]),
        ]),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 14),
        InfoRow(icon: Icons.email_outlined, label: 'Email', value: email, isDark: isDark),
        const SizedBox(height: 12),
        InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: phone, isDark: isDark),
        const SizedBox(height: 12),
        InfoRow(icon: Icons.school_outlined, label: 'GPA', value: gpa, isDark: isDark),
        const SizedBox(height: 14),
        Text('Bio', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(bio, style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, height: 1.4)),
      ]),
    );
  }
}