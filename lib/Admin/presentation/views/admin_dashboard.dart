import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'theme_provider.dart';
import 'stat_card.dart';
import 'activity_card.dart';
import '../../models/recent_activity.dart';
import '../../core/di/dashboard_providers.dart';
import '../widgets/skeleton_stat_card.dart';          
import '../widgets/skeleton_activity_card.dart'; 
import '../../../auth_session.dart';  
import '../../../supabase_helper.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  @override
  void initState() {
    super.initState();
  }

 Future<void> _logout() async {
  if (AuthSession.token != null) {
    await supabase.rpc('logout', params: {
      'p_token': AuthSession.token,
    });
  }
  AuthSession.clear();
  Navigator.of(context).pushNamedAndRemoveUntil('/signin', (route) => false);
}

  @override
  Widget build(BuildContext context) {
    final themeProvider = provider.Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final state = ref.watch(dashboardProvider);

    if (state.error != null) {
      return Center(child: Text(state.error!));
    }
    final dashboard = state.data;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADMIN PANEL',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dashboard',
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
  decoration: BoxDecoration(
    color: isDark ? AppColors.darkCard : Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
  ),
  child: 
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode_outlined,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textSecondary,
                      ),
                      onPressed: themeProvider.toggleTheme,
                    ),
                    IconButton(
                      onPressed: _logout,
                      icon: Icon(
                        Icons.logout,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      tooltip: 'Logout',
                    ),
                  ],
                ),),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Overview of all activities',
              style: AppTextStyles.body.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            if (state.isLoading) ...[
  const Row(
    children: [
      Expanded(child: SkeletonStatCard()),
      SizedBox(width: 12),
      Expanded(child: SkeletonStatCard()),
    ],
  ),
  const SizedBox(height: 12),
  const SkeletonStatCard(),  // 👈 uploads skeleton inside here
] else ...[
  Row(
    children: [
      Expanded(
        child: StatCard(
          icon: LucideIcons.trendingUp,
          label: 'Total Applications',
          value: dashboard!.totalApplications.toString(),
          change: '${dashboard.totalAppsChange.toStringAsFixed(1)}%',
          backgroundColor: AppColors.accentInfo,
          textColor: AppColors.accentInfoText,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: StatCard(
          icon: LucideIcons.clock,
          label: 'Pending Approvals',
          value: dashboard.pendingApplications.toString(),
          change: '${dashboard.pendingChange.toStringAsFixed(1)}%',
          backgroundColor: AppColors.accentAlert,
          textColor: AppColors.accentAlertText,
        ),
      ),
    ],
  ),
  const SizedBox(height: 12),
  SizedBox(
  width: double.infinity,
  child:
  StatCard(                
    icon: LucideIcons.upload,
    label: 'New Student Uploads',
    value: dashboard.trainingUploads.toString(),
    change: '${dashboard.uploadsChange.toStringAsFixed(1)}',
    backgroundColor: AppColors.accentSuccess,
    textColor: AppColors.accentSuccessText,
  ),),
],

const SizedBox(height: 32),
const Text(
  'Recent Activity',
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
),
const SizedBox(height: 12),

if (state.isLoading)
  ...List.generate(4, (_) => const SkeletonActivityCard())
else if (dashboard!.recentActivities.isEmpty)
  const Text('No recent activity')
else
  ...dashboard.recentActivities.map(
    (RecentActivity a) => ActivityCard(
      student: a.studentName,
      action: a.action,
      time: a.timeAgo,
      status: a.status,
    ),
  ),
          ],
        ),
      ),
    );
  }
}
