import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class CareerPathsSection extends StatelessWidget {
  const CareerPathsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _SectionHeader(
          title: 'Career Paths',
          actionLabel: 'Explore →',
          isDark: isDark,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        ...AppData.careerPaths.map(
              (path) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CareerPathCard(path: path, isDark: isDark),
          ),
        ),
      ],
    );
  }
}

class CareerPathCard extends StatelessWidget {
  final CareerPath path;
  final bool isDark;

  const CareerPathCard({super.key, required this.path, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            path.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _PathStat(
                value: path.roles.toString(),
                label: 'Roles',
                isDark: isDark,
              ),
              _PathStat(
                value: path.avgSalary,
                label: 'Avg. Salary',
                isDark: isDark,
              ),
              _PathStat(
                value: path.growth,
                label: 'Growth',
                valueColor: AppColors.primaryGreen,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PathStat extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final bool isDark;

  const _PathStat({
    required this.value,
    required this.label,
    this.valueColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final bool isDark;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}