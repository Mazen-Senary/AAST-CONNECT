import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';
import '../utils/profile_provider.dart';
import '../widgets/career_progress_card.dart';
import '../widgets/stats_row.dart';
import '../widgets/career_paths_section.dart';
import '../widgets/latest_opportunities_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),

          // Greeting — rebuilds automatically when firstName changes
          Consumer<ProfileProvider>(
            builder: (context, profile, _) => Row(
              children: [
                Text(
                  'Hello, ${profile.firstName} ',
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
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
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 20.h),

          CareerProgressCard(),
          SizedBox(height: 14.h),

          const StatsRow(),
          SizedBox(height: 24.h),

          CareerPathsSection(),
          SizedBox(height: 24.h),

          const LatestOpportunitiesSection(),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
