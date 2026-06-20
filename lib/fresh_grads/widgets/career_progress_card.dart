import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CareerProgressCard extends StatelessWidget {
  const CareerProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGreen : AppColors.lightGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    color: AppColors.primaryGreen,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Career Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '24',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'total applied',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Applications this month',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(label: 'Interviews', value: '8', isDark: isDark),
              const SizedBox(width: 10),
              _StatChip(label: 'Pending', value: '12', isDark: isDark),
              const SizedBox(width: 10),
              _StatChip(label: 'Offers', value: '3', isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _StatChip({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface.withOpacity(0.6)
              : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
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
        ),
      ),
    );
  }
}