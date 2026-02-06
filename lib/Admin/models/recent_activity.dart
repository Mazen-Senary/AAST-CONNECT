import '../models/activity_status.dart';

class RecentActivity {
  final String studentName;
  final String action;
  final String timeAgo;
  final ActivityStatus status;

  RecentActivity({
    required this.studentName,
    required this.action,
    required this.timeAgo,
    required this.status,
  });
}
