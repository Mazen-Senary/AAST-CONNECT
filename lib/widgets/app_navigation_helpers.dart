import 'package:flutter/material.dart';

import '../fresh_grads/screens/fresh_grad_notifications.dart';
import '../fresh_grads/screens/profile_screen.dart';
import '../student/screens/student_profile.dart';

void openStudentProfile(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const StudentProfile()),
  );
}

void openFreshGradProfile(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ProfileScreen()),
  );
}

void openFreshGradNotifications(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const FreshGradNotificationsScreen(),
    ),
  );
}
