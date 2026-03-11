import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Greeting — rebuilds automatically when firstName changes
          Consumer<ProfileProvider>(
            builder: (context, profile, _) => Row(
              children: [
                Text(
                  'Hello, ${profile.firstName} ',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const Text('👋', style: TextStyle(fontSize: 26)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your career journey starts here',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          CareerProgressCard(),
          const SizedBox(height: 14),

          const StatsRow(),
          const SizedBox(height: 24),

          CareerPathsSection(),
          const SizedBox(height: 24),

          const LatestOpportunitiesSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}