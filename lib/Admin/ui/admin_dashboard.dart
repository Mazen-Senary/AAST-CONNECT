import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/app_colors.dart';
import 'stat_card.dart';
import 'activity_card.dart';
import '../models/activity_status.dart';
import '../models/recent_activity.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final supabase = Supabase.instance.client;
  List<RecentActivity> recentActivities = [];

  int totalApplications = 0;
  int pendingApplications = 0;
  int trainingUploads = 0;
  bool isLoading = true;

  double totalAppsChange = 0;
  double pendingChange = 0;
  double uploadsChange = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
    _loadRecentActivity();
  }
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



  Future<void> _loadDashboardStats() async {
  final now = DateTime.now();
  final last7 = now.subtract(const Duration(days: 7));
  final prev7 = now.subtract(const Duration(days: 14));

  try {
    /// ---------- TOTAL APPLICATIONS ----------
    final totalApps = await supabase
        .from('application')
        .select('applicationid');

    final totalAppsLast7 = await supabase
        .from('application')
        .select('applicationid')
        .gte('created_at', last7.toIso8601String());

    final totalAppsPrev7 = await supabase
        .from('application')
        .select('applicationid')
        .gte('created_at', prev7.toIso8601String())
        .lt('created_at', last7.toIso8601String());

    /// ---------- PENDING APPLICATIONS ----------
    final pendingApps = await supabase
        .from('application')
        .select('applicationid')
        .eq('status', 'PENDING');

    final pendingLast7 = await supabase
        .from('application')
        .select('applicationid')
        .eq('status', 'PENDING')
        .gte('created_at', last7.toIso8601String());

    final pendingPrev7 = await supabase
        .from('application')
        .select('applicationid')
        .eq('status', 'PENDING')
        .gte('created_at', prev7.toIso8601String())
        .lt('created_at', last7.toIso8601String());

    /// ---------- TRAINING RECORDS ----------
    final trainingAll = await supabase
        .from('trainingrecord')
        .select('recordid');

    final trainingLast7 = await supabase
        .from('trainingrecord')
        .select('recordid')
        .gte('created_at', last7.toIso8601String());

    final trainingPrev7 = await supabase
        .from('trainingrecord')
        .select('recordid')
        .gte('created_at', prev7.toIso8601String())
        .lt('created_at', last7.toIso8601String());

    setState(() {
      totalApplications = totalApps.length;
      pendingApplications = pendingApps.length;
      trainingUploads = trainingAll.length;

      totalAppsChange =
          _percentageChange(totalAppsLast7.length, totalAppsPrev7.length);
      pendingChange =
          _percentageChange(pendingLast7.length, pendingPrev7.length);
      uploadsChange =
          _percentageChange(trainingLast7.length, trainingPrev7.length);

      isLoading = false;
    });
  } catch (e) {
    debugPrint('Dashboard load error: $e');
    setState(() => isLoading = false);
  }
}
Future<void> _loadRecentActivity() async {
  try {
    /// 1️⃣ Fetch recent training records
    final training = await supabase
        .from('trainingrecord')
        .select('studentid, status, created_at')
        .order('created_at', ascending: false)
        .limit(5);

    /// 2️⃣ Fetch recent applications
    final applications = await supabase
    .from('application')
    .select('''
      applicantid,
      status,
      created_at,
      vacancies (
        company_name,
        title
      )
    ''')
    .order('created_at', ascending: false)
    .limit(5);


    /// 3️⃣ Collect all student IDs
    final studentIds = {
      ...training.map((e) => e['studentid']),
      ...applications.map((e) => e['applicantid']),
    }.toList();

    if (studentIds.isEmpty) return;

    /// 4️⃣ Fetch users by userid
    final users = await supabase
        .from('users')
        .select('userid, name')
        .or(
  studentIds.map((id) => 'userid.eq.$id').join(','),
);


    final userMap = {
      for (final u in users) u['userid']: u['name'],
    };

    List<RecentActivity> items = [];

    /// 5️⃣ Training activities
    for (final t in training) {
      items.add(
        RecentActivity(
          studentName: userMap[t['studentid']] ?? 'Unknown Student',
          action: 'Submitted training hours',
          timeAgo: _timeAgo(DateTime.parse(t['created_at'])),
          status: t['status'] == 'APPROVED'
              ? ActivityStatus.completed
              : ActivityStatus.pending,
        ),
      );
    }

    /// 6️⃣ Application activities
    /// 6️⃣ Application activities
for (final a in applications) {
  final companyName =
      a['vacancies']?['company_name'] ??
      a['vacancies']?['title'] ??
      'Company';

  items.add(
    RecentActivity(
      studentName: userMap[a['applicantid']] ?? 'Unknown Student',
      action: 'Applied to $companyName',
      timeAgo: _timeAgo(DateTime.parse(a['created_at'])),
      status: a['status'] == 'APPROVED'
          ? ActivityStatus.completed
          : ActivityStatus.pending,
    ),
  );
}

    /// 7️⃣ Shuffle for “random” feeling
    items.shuffle();

    setState(() {
      recentActivities = items.take(6).toList();
    });
  } catch (e) {
    debugPrint('Recent activity error: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Overview of all activities',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: LucideIcons.trendingUp,
                  label: 'Total Applications',
                  value: isLoading ? '—' : totalApplications.toString(),
                  change: isLoading
    ? '—'
    : '${totalAppsChange.toStringAsFixed(1)}%',

                  backgroundColor: AppColors.accentInfo,
                  textColor: AppColors.accentInfoText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: LucideIcons.clock,
                  label: 'Pending Approvals',
                  value: isLoading ? '—' : pendingApplications.toString(),
                  change: isLoading
    ? '—'
    : '${pendingChange.toStringAsFixed(1)}%',

                  backgroundColor: AppColors.accentAlert,
                  textColor: AppColors.accentAlertText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          StatCard(
            icon: LucideIcons.upload,
            label: 'New Student Uploads',
            value: isLoading ? '—' : trainingUploads.toString(),
            change: isLoading
    ? '—'
    : '${uploadsChange.toStringAsFixed(1)}%',

            backgroundColor: AppColors.accentSuccess,
            textColor: AppColors.accentSuccessText,
          ),
          const SizedBox(height: 32),
const Text(
  'Recent Activity',
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
),
const SizedBox(height: 12),

if (recentActivities.isEmpty)
  const Text('No recent activity')
else
  ...recentActivities.map(
    (RecentActivity a) => ActivityCard(
      student: a.studentName,
      action: a.action,
      time: a.timeAgo,
      status: a.status,
    ),
  ),
        ],
      ),
    );

  }
}
