import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../services/fresh_grad_home_service.dart';
import '../../services/app_refresh_service.dart';
import '../theme/app_theme.dart';
import '../utils/profile_provider.dart';
import '../widgets/career_paths_section.dart';
import '../widgets/career_progress_card.dart';
import '../widgets/latest_opportunities_section.dart';
import '../widgets/stats_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FreshGradHomeService _homeService = FreshGradHomeService();

  FreshGradHomeData? _homeData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    AppRefreshService.instance.addListener(_handleRefreshSignal);
  }

  @override
  void dispose() {
    AppRefreshService.instance.removeListener(_handleRefreshSignal);
    super.dispose();
  }

  void _handleRefreshSignal() {
    if (!mounted) return;
    _loadHomeData(forceRefresh: true);
    context.read<ProfileProvider>().loadFromDatabase();
  }

  Future<void> _loadHomeData({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _homeService.load(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _homeData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load home data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading && _homeData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _homeData == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              SizedBox(height: 12.h),
              Text(_error!),
              SizedBox(height: 12.h),
              ElevatedButton(
                onPressed: () => _loadHomeData(forceRefresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final homeData = _homeData!;

    return RefreshIndicator(
      onRefresh: () => _loadHomeData(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            Consumer<ProfileProvider>(
              builder: (context, profile, _) => Row(
                children: [
                  Text(
                    'Hello, ${profile.firstName} ',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text('👋', style: TextStyle(fontSize: 26.sp)),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Your career journey starts here',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 20.h),
            CareerProgressCard(
              totalApplications: homeData.totalApplications,
              pendingApplications: homeData.pendingApplications,
              approvedApplications: homeData.approvedApplications,
              rejectedApplications: homeData.rejectedApplications,
            ),
            SizedBox(height: 14.h),
            StatsRow(jobMatches: homeData.jobMatches),
            SizedBox(height: 24.h),
            RecentActivitiesSection(activities: homeData.recentActivities),
            SizedBox(height: 24.h),
            LatestOpportunitiesSection(
              opportunities: homeData.latestOpportunities,
              appliedVacancyIds: homeData.appliedVacancyIds,
              onApplied: (vacancyId) {
                setState(() {
                  _homeData = homeData.copyWith(
                    totalApplications: homeData.totalApplications + 1,
                    pendingApplications: homeData.pendingApplications + 1,
                    appliedVacancyIds: {
                      ...homeData.appliedVacancyIds,
                      vacancyId,
                    },
                  );
                });

                _loadHomeData(forceRefresh: true);
              },
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
