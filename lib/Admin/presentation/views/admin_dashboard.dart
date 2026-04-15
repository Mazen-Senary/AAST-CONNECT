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
    try {
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/signin', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = provider.Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final state = ref.watch(dashboardProvider);
    
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text(state.error!));
    }
    final dashboard = state.data;


if (dashboard == null) {
  return const Center(child: CircularProgressIndicator());
}


    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
        elevation: 0,
        title: Text(
          'AAST Connect Staff',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        actions: [
          // Dark Mode Toggle
          IconButton(
            onPressed: () {
              themeProvider.toggleTheme();
            },
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          ),

          // Logout Button
          IconButton(
            onPressed: _logout,
            icon: Icon(
              Icons.logout,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: AppTextStyles.h1.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Overview of all activities',
              style: AppTextStyles.body.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: LucideIcons.trendingUp,
                    label: 'Total Applications',
                    value: state.isLoading
                        ? '—'
                        : dashboard.totalApplications.toString(),
                    change: state.isLoading
                        ? '—'
                        : '${dashboard.totalAppsChange.toStringAsFixed(1)}%',

                    backgroundColor: AppColors.accentInfo,
                    textColor: AppColors.accentInfoText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: LucideIcons.clock,
                    label: 'Pending Approvals',
                    value: state.isLoading
                        ? '—'
                        : dashboard.pendingApplications.toString(),
                    change: state.isLoading
                        ? '—'
                        : '${dashboard.pendingChange.toStringAsFixed(1)}%',

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
              value: state.isLoading
                  ? '—'
                  : dashboard.trainingUploads.toString(),
              change: state.isLoading
                  ? '—'
                  : '${dashboard.uploadsChange.toStringAsFixed(1)}',

              backgroundColor: AppColors.accentSuccess,
              textColor: AppColors.accentSuccessText,
            ),
            const SizedBox(height: 32),
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            if (dashboard.recentActivities.isEmpty)
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
