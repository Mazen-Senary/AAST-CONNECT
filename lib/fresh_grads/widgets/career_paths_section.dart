import 'package:flutter/material.dart';

import '../../services/fresh_grad_home_service.dart';
import '../../widgets/company_logo.dart';
import '../theme/app_theme.dart';

class RecentActivitiesSection extends StatelessWidget {
  final List<FreshGradRecentActivity> activities;

  const RecentActivitiesSection({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _SectionHeader(
          title: 'Recent Activities',
          actionLabel: 'View all ->',
          isDark: isDark,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        if (activities.isEmpty)
          _EmptyState(isDark: isDark)
        else
          ...activities.map(
            (activity) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RecentActivityCard(
                activity: activity,
                isDark: isDark,
              ),
            ),
          ),
      ],
    );
  }
}

class RecentActivityCard extends StatelessWidget {
  final FreshGradRecentActivity activity;
  final bool isDark;

  const RecentActivityCard({
    super.key,
    required this.activity,
    required this.isDark,
  });

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
      child: Row(
        children: [
          CompanyLogo(
            logoUrl: activity.imageUrl,
            fallbackIcon: Icons.business,
            fallbackColor: AppColors.accentBlue,
            borderColor: isDark ? AppColors.darkSurface : Colors.grey.shade200,
            size: 42,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.company,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _StatusPill(status: activity.status, isDark: isDark),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  final bool isDark;

  const _StatusPill({
    required this.status,
    required this.isDark,
  });

  Color get _background {
    switch (status) {
      case 'APPROVED':
        return AppColors.lightGreen;
      case 'REJECTED':
        return const Color(0xFFFCE4EC);
      case 'CANCELED':
        return Colors.grey.shade200;
      default:
        return AppColors.lightOrange;
    }
  }

  Color get _foreground {
    switch (status) {
      case 'APPROVED':
        return AppColors.primaryGreen;
      case 'REJECTED':
        return const Color(0xFFE91E63);
      case 'CANCELED':
        return Colors.grey.shade700;
      default:
        return AppColors.accentOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? _foreground.withValues(alpha: 0.18) : _background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _foreground,
        ),
      ),
    );
  }

  String get _label {
    switch (status) {
      case 'APPROVED':
        return 'Accepted';
      case 'REJECTED':
        return 'Rejected';
      case 'CANCELED':
        return 'Canceled';
      default:
        return 'Pending';
    }
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;

  const _EmptyState({required this.isDark});

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
      child: Text(
        'No recent applications yet.',
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
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
          child: const Text(
            'View all ->',
            style: TextStyle(
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
