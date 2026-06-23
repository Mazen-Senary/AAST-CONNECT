import 'package:grad_project/Admin/data/models/dashboard_model.dart';
import 'package:grad_project/Admin/models/recent_activity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRemoteDataSource {
  final SupabaseClient client;

  DashboardRemoteDataSource(this.client);

  Future<DashboardModel> getDashboard() async {
    final results = await Future.wait([
      client.from('student_application_counts').select(),
      client.from('application').select().order('created_at', ascending: false).limit(5),
      client.from('trainingrecord').select().order('created_at', ascending: false).limit(5),
    ]);

    final statsResponse = results[0] as List;
    final applications = results[1] as List;
    final training = results[2] as List;

    final studentIds = training
        .map((r) => r['studentid'])
        .where((id) => id != null)
        .toList();

    Map<dynamic, String> studentNames = {};
    if (studentIds.isNotEmpty) {
      final students = await client
          .from('student')
          .select('studentid, name')
          .inFilter('studentid', studentIds);

      studentNames = {
        for (final s in students as List) s['studentid']: s['name'] ?? 'Unknown'
      };
    }

    final totalApplications = statsResponse.fold<int>(
      0, (sum, row) => sum + (row['total_applications'] as int),
    );
    final pendingApplications = applications.where((a) => a['status'] == 'PENDING').length;
    final trainingUploads = training.length;

    final appActivities = applications.map((row) => RecentActivity(
      studentName: row['applicant_name'] ?? 'Unknown',
      action: 'Applied for opportunity',
      timeAgo: _formatTimeAgo(row['created_at']),
      status: RecentActivity.mapStatus(row['status']),
    )).toList();

    final trainingActivities = training.map((row) => RecentActivity(
      studentName: studentNames[row['studentid']] ?? 'Unknown',
      action: 'Submitted training',
      timeAgo: _formatTimeAgo(row['created_at']),
      status: RecentActivity.mapStatus(row['status']),
    )).toList();

    return DashboardModel(
      totalApplications: totalApplications,
      pendingApplications: pendingApplications,
      trainingUploads: trainingUploads,
      totalAppsChange: 0,
      pendingChange: 0,
      uploadsChange: 0,
      recentActivities: [...appActivities, ...trainingActivities],
    );
  }

  String _formatTimeAgo(String dateTimeString) {
    final diff = DateTime.now().difference(DateTime.parse(dateTimeString));
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} days ago';
  }
}