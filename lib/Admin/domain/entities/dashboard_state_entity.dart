import '../../models/recent_activity.dart';
class DashboardStateEntity {
  final int totalApplications;
  final int pendingApplications;
  final int trainingUploads;
  final double totalAppsChange;
  final double pendingChange;
  final double uploadsChange;
  final List<RecentActivity> recentActivities;

  const DashboardStateEntity({
    required this.totalApplications,
    required this.pendingApplications,
    required this.trainingUploads,
    required this.totalAppsChange,
    required this.pendingChange,
    required this.uploadsChange,
    required this.recentActivities,
  });
}