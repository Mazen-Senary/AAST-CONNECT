import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../student/screens/student_notifications.dart';

class AppBarWithLogout extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLogout;
  final List<Widget>? additionalActions;
  final int unreadNotificationCount;
  final VoidCallback? onTimelinePressed;

  const AppBarWithLogout({
    super.key,
    required this.title,
    this.onLogout,
    this.additionalActions,
    this.unreadNotificationCount = 0,
    this.onTimelinePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      actions: [
        // 1. Dark Mode Toggle
        IconButton(
          icon: Icon(
            Provider.of<ThemeProvider>(context).isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
        ),

        // 2. Timeline Icon (Tracking)
        if (onTimelinePressed != null)
          IconButton(
            tooltip: 'Tracking',
            onPressed: onTimelinePressed,
            icon: const Icon(Icons.timeline),
          ),

        // 3. Bell Icon (Notifications)
        Stack(
          children: [
            IconButton(
              tooltip: 'Notifications',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentNotificationsScreen(),
                ),
              ),
              icon: const Icon(Icons.notifications_outlined),
            ),
            if (unreadNotificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
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

        // 4. Logout Button
        if (onLogout != null)
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Logout',
            onPressed: onLogout,
          ),

        if (additionalActions != null) ...additionalActions!,
        const SizedBox(width: 5),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
