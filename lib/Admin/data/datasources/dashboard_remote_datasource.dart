import 'package:grad_project/Admin/data/models/dashboard_model.dart';
import 'package:grad_project/Admin/models/recent_activity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRemoteDataSource {
  final SupabaseClient client;

  DashboardRemoteDataSource(this.client);

  Future<DashboardModel> getDashboard() async {
  // 1️⃣ dashboard stats
  final statsResponse = await client
      .from('student_application_counts')
      .select();
  
  // 2️⃣ recent activities
  final applications = await client
    .from('application')
    .select()
    .order('created_at', ascending: false)
    .limit(5);

final training = await client
    .from('trainingrecord')
    .select()
    .order('created_at', ascending: false)
    .limit(5);
    // Applications → activities

  final totalApplications = (statsResponse as List)
    .fold<int>(0, (sum, row) => sum + (row['total_applications'] as int));
  final pendingApplications =
    (applications as List)
        .where((a) => a['status'] == 'pending')
        .length;
  final trainingUploads = (training as List).length;
// ⏱ time formatter
String _formatTimeAgo(String dateTimeString) {
  final dateTime = DateTime.parse(dateTimeString);
  final diff = DateTime.now().difference(dateTime);

  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  return '${diff.inDays} days ago';
}
final appActivities = (applications as List<dynamic>).map((row) {
  return RecentActivity(
    studentName: row['applicant_name'] ?? 'Unknown',
    action: 'Applied for opportunity',
    timeAgo: _formatTimeAgo(row['created_at']),
    status: RecentActivity.mapStatus(row['status']),
  );
}).toList();

// Training → activities
final trainingActivities = (training as List<dynamic>).map((row) {
  return RecentActivity(
    studentName: row['name'] ?? 'Unknown',
    action: 'Submitted training',
    timeAgo: _formatTimeAgo(row['created_at']),
    status: RecentActivity.mapStatus(row['status']),
  );
}).toList();
final allActivities = [
  ...appActivities,
  ...trainingActivities,
];
  return DashboardModel(
    totalApplications: totalApplications,
    pendingApplications: pendingApplications,
    trainingUploads: trainingUploads,
    totalAppsChange: 0,
    pendingChange: 0,
    uploadsChange: 0,
    recentActivities: allActivities,
  );
}
}