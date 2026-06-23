import 'package:flutter/material.dart';

import 'professional_app_chrome.dart';
import '../student/screens/student_notifications.dart';

class AppBarWithLogout extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLogout;
  final List<Widget>? additionalActions;
  final int unreadNotificationCount;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onTimelinePressed;
  final VoidCallback? onSupportPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onChatbotPressed;
  final String? photoUrl;

  const AppBarWithLogout({
    super.key,
    required this.title,
    this.onLogout,
    this.additionalActions,
    this.unreadNotificationCount = 0,
    this.onNotificationsPressed,
    this.onTimelinePressed,
    this.onSupportPressed,
    this.onProfilePressed,
    this.onChatbotPressed,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ProfessionalAppBar(
      unreadNotificationCount: unreadNotificationCount,
      onNotificationsPressed: onNotificationsPressed ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StudentNotificationsScreen(),
              ),
            );
          },
      onTrackingPressed: onTimelinePressed,
      onSupportPressed: onSupportPressed,
      onProfilePressed: onProfilePressed,
      onChatbotPressed: onChatbotPressed,
      onLogoutPressed: onLogout,
      additionalActions: additionalActions,
      photoUrl: photoUrl,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
