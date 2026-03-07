import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recent_activity.dart';
import '../models/activity_status.dart';

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(),
);

class DashboardState {
  final int totalApplications;
  final int pendingApplications;
  final int trainingUploads;
  final double totalAppsChange;
  final double pendingChange;
  final double uploadsChange;
  final bool isLoading;
  final List<RecentActivity> recentActivities;

  DashboardState({
    this.totalApplications = 0,
    this.pendingApplications = 0,
    this.trainingUploads = 0,
    this.totalAppsChange = 0,
    this.pendingChange = 0,
    this.uploadsChange = 0,
    this.isLoading = true,
    this.recentActivities = const [],
  });

  DashboardState copyWith({
    int? totalApplications,
    int? pendingApplications,
    int? trainingUploads,
    double? totalAppsChange,
    double? pendingChange,
    double? uploadsChange,
    bool? isLoading,
    List<RecentActivity>? recentActivities,
  }) {
    return DashboardState(
      totalApplications: totalApplications ?? this.totalApplications,
      pendingApplications: pendingApplications ?? this.pendingApplications,
      trainingUploads: trainingUploads ?? this.trainingUploads,
      totalAppsChange: totalAppsChange ?? this.totalAppsChange,
      pendingChange: pendingChange ?? this.pendingChange,
      uploadsChange: uploadsChange ?? this.uploadsChange,
      isLoading: isLoading ?? this.isLoading,
      recentActivities: recentActivities ?? this.recentActivities,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState()) {
    loadDashboard();
  }

  final supabase = Supabase.instance.client;

  double _percentageChange(int current, int previous) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hour ago';
    return '${diff.inDays} days ago';
  }

  Future<void> loadDashboard() async {
    try {
      final res = await supabase.rpc('get_dashboard_stats');

      final training = await supabase
          .from('trainingrecord')
          .select('studentid, status, created_at')
          .order('created_at', ascending: false)
          .limit(5);

      final applications = await supabase
          .from('application')
          .select('''
            applicantid,
            status,
            created_at,
            vacancies(company_name,title)
          ''')
          .order('created_at', ascending: false)
          .limit(5);

      final studentIds = {
        ...training.map((e) => e['studentid']),
        ...applications.map((e) => e['applicantid']),
      }.toList();

      final users = await supabase
          .from('users')
          .select('userid,name')
          .or(studentIds.map((id) => 'userid.eq.$id').join(','));

      final userMap = {
        for (final u in users) u['userid']: u['name'],
      };

      List<RecentActivity> activities = [];

      for (final t in training) {
        activities.add(
          RecentActivity(
            studentName: userMap[t['studentid']] ?? 'Unknown',
            action: 'Submitted training hours',
            timeAgo: _timeAgo(DateTime.parse(t['created_at'])),
            status: t['status'] == 'APPROVED'
                ? ActivityStatus.completed
                : ActivityStatus.pending,
          ),
        );
      }

      for (final a in applications) {
        final company =
            a['vacancies']?['company_name'] ??
            a['vacancies']?['title'] ??
            'Company';

        activities.add(
          RecentActivity(
            studentName: userMap[a['applicantid']] ?? 'Unknown',
            action: 'Applied to $company',
            timeAgo: _timeAgo(DateTime.parse(a['created_at'])),
            status: a['status'] == 'APPROVED'
                ? ActivityStatus.completed
                : ActivityStatus.pending,
          ),
        );
      }

      activities.shuffle();

      state = state.copyWith(
        totalApplications: res['totalApplications'],
        pendingApplications: res['pendingApplications'],
        trainingUploads: res['trainingUploads'],
        totalAppsChange:
            _percentageChange(res['last7Applications'], res['prev7Applications']),
        pendingChange:
            _percentageChange(res['last7Pending'], res['prev7Pending']),
        uploadsChange:
            _percentageChange(res['last7Uploads'], res['prev7Uploads']),
        recentActivities: activities.take(6).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}