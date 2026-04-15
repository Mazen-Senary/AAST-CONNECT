import '../../domain/entities/dashboard_state_entity.dart';
import '../../models/recent_activity.dart';

class DashboardModel extends DashboardStateEntity {
  DashboardModel({
    required super.totalApplications,
    required super.pendingApplications,
    required super.trainingUploads,
    required super.totalAppsChange,
    required super.pendingChange,
    required super.uploadsChange,
    required super.recentActivities,
  });

  factory DashboardModel.fromJson(
    Map<String, dynamic> json,
    List<dynamic> activitiesJson, 
  ) {
    return DashboardModel(
      totalApplications: json['totalApplications'],
      pendingApplications: json['pendingApplications'],
      trainingUploads: json['trainingUploads'],
      totalAppsChange: (json['totalAppsChange'] as num).toDouble(),
      pendingChange: (json['pendingChange'] as num).toDouble(),
      uploadsChange: (json['uploadsChange'] as num).toDouble(),
      recentActivities: activitiesJson
          .map((e) => RecentActivity.fromJson(e))
          .toList(),
    );
  }
}