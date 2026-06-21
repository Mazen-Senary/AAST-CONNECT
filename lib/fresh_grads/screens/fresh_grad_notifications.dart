import 'package:flutter/material.dart';

import '../../services/fresh_grad_opportunity_notification_service.dart';
import '../../services/user_session.dart';
import '../../student/screens/student_notifications.dart';

class FreshGradNotificationsScreen extends StatelessWidget {
  const FreshGradNotificationsScreen({super.key});

  static final FreshGradOpportunityNotificationService _opportunityService =
      FreshGradOpportunityNotificationService();

  int get _userId => UserSession.instance.userId!;

  @override
  Widget build(BuildContext context) {
    return StudentNotificationsScreen(
      loadExtraNotifications: () =>
          _opportunityService.fetchUnreadOpportunityNotifications(_userId),
      onExtraNotificationRead: (notification) {
        final vacancyId = notification['vacancyid']?.toString();
        if (vacancyId == null) return Future.value();
        return _opportunityService.markOpportunityAsRead(_userId, vacancyId);
      },
      onAllExtraNotificationsRead: () =>
          _opportunityService.markAllOpportunitiesAsRead(_userId),
    );
  }
}
