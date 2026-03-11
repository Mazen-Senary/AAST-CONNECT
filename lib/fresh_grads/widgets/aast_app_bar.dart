import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AastAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;
  final VoidCallback onThemeToggle;
  final VoidCallback onLogout;

  const AastAppBar({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      elevation: 0,
      title: Text(
        'AAST Connect',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: onThemeToggle,
          icon: Icon(
            isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        TextButton.icon(
          onPressed: onLogout,
          icon: Icon(
            Icons.logout,
            size: 18,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          label: Text(
            'Logout',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}