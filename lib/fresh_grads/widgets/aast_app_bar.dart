import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../../signIn.dart';
import '../../services/user_session.dart';

class AastAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;
  final VoidCallback onThemeToggle;
  final int unreadNotificationCount;
  final VoidCallback? onTrackingPressed;
  final VoidCallback? onNotificationsPressed;

  const AastAppBar({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
    this.unreadNotificationCount = 0,
    this.onTrackingPressed,
    this.onNotificationsPressed,
  });

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      UserSession.instance.clear();

      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      elevation: 0,
      title: Text(
        'AAST Connect',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color:
              isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: onThemeToggle,
          icon: Icon(
            isDark
                ? Icons.wb_sunny_outlined
                : Icons.nightlight_round,
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        if (onTrackingPressed != null)
          IconButton(
            tooltip: 'Tracking',
            onPressed: onTrackingPressed,
            icon: Icon(
              Icons.timeline,
              color:
                  isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        if (onNotificationsPressed != null)
          Stack(
            children: [
              IconButton(
                tooltip: 'Notifications',
                onPressed: onNotificationsPressed,
                icon: Icon(
                  Icons.notifications_outlined,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              if (unreadNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadNotificationCount > 99
                          ? '99+'
                          : unreadNotificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        TextButton.icon(
          onPressed: () => _logout(context),
          icon: Icon(
            Icons.logout,
            size: 18,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
          label: Text(
            'Logout',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
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
