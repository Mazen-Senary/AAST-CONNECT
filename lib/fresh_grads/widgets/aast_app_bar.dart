import 'package:flutter/material.dart';

import '../../widgets/professional_app_chrome.dart';
import '../screens/fresh_grad_notifications.dart';

class AastAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;
  final VoidCallback onThemeToggle;
  final int unreadNotificationCount;
  final VoidCallback? onTrackingPressed;
  final VoidCallback? onSupportPressed;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onChatbotPressed;
  final String? photoUrl;

  const AastAppBar({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
    this.unreadNotificationCount = 0,
    this.onTrackingPressed,
    this.onSupportPressed,
    this.onNotificationsPressed,
    this.onProfilePressed,
    this.onChatbotPressed,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ProfessionalAppBar(
      unreadNotificationCount: unreadNotificationCount,
      onTrackingPressed: onTrackingPressed,
      onSupportPressed: onSupportPressed,
      onNotificationsPressed: onNotificationsPressed ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FreshGradNotificationsScreen(),
              ),
            );
          },
      onProfilePressed: onProfilePressed,
      onChatbotPressed: onChatbotPressed,
      onThemeToggle: onThemeToggle,
      photoUrl: photoUrl,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
