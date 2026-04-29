import 'activity_status.dart';

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
  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      studentName: json['studentName'],
      action: json['action'],
      timeAgo: json['timeAgo'],
      status: mapStatus(json['status']),
    );
  }
  static ActivityStatus mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return ActivityStatus.approved;
      case 'rejected':
        return ActivityStatus.rejected;
      case 'pending':
        return ActivityStatus.pending;
      default:
        return ActivityStatus.pending;
    }
  }
}
