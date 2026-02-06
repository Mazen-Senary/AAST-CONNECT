import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Dashboard Overview',
          style: AppTextStyles.h1.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
