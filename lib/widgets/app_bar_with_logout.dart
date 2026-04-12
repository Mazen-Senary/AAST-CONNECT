import 'package:flutter/material.dart';
import 'theme_toggle_button.dart';

class AppBarWithLogout extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLogout;
  final List<Widget>? additionalActions;

  const AppBarWithLogout({
    super.key,
    required this.title,
    this.onLogout,
    this.additionalActions,
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
        const ThemeToggleButton(),
        if (additionalActions != null) ...additionalActions!,
        TextButton.icon(
          onPressed: onLogout ?? () {
            // Default logout logic
          },
          icon: const Icon(Icons.logout, color: Colors.grey, size: 18),
          label: Text(
            "Logout",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        const SizedBox(width: 5),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
