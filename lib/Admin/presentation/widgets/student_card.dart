import 'package:flutter/material.dart';
import '../../domain/entities/student.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
class StudentCard extends StatelessWidget {
  final Student student;
  final bool isDark;
  final void Function(String id) onToggle;

  const StudentCard({
    super.key,
    required this.student,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name, 
                    style: AppTextStyles.h3.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    student.major, 
                    style: AppTextStyles.body.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    color: AppColors.interactive.withOpacity(0.12),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    student.collegeId ?? '-',
    style: AppTextStyles.label.copyWith(
      color: AppColors.interactive,
    ),
  ),
),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.interactive.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  student.year,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.interactive,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // EMAIL
          Row(
            children: [
              Icon(
                Icons.mail, 
                size: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  student.email,
                  style: AppTextStyles.body.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          const SizedBox(height: 8),

          // STATS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stat('GPA', student.gpa.toStringAsFixed(1), isDark),
              _stat('Applications', student.applications.toString(), isDark),
              _stat('Training Hrs', student.trainingHours.toString(), isDark),
            ],
          ),

          const SizedBox(height: 14),
          if (student.expanded) ...[
  const Divider(height: 30),

  if ((student.phone ?? '').isNotEmpty)
    _infoRow(Icons.phone, student.phone!, isDark),

  if ((student.address ?? '').isNotEmpty)
    _infoRow(Icons.location_on, student.address!, isDark),

  if ((student.dateOfBirth ?? '').isNotEmpty)
    _infoRow(Icons.cake, student.dateOfBirth!, isDark),

  if (student.gender != null)
    _infoRow(Icons.person, student.gender!, isDark),

  if (student.linkedinUrl != null)
    _infoRow(Icons.link, student.linkedinUrl!, isDark),

  if (student.skills != null)
    _infoRow(Icons.star, student.skills!, isDark),

  if (student.bio != null)
    Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        student.bio!,
        style: AppTextStyles.body.copyWith(
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.textSecondary,
        ),
      ),
    ),

  if (student.profileImageUrl != null)
    Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          student.profileImageUrl!,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    ),
],


          // ACTION
          SizedBox(
            width: double.infinity,
            child: TextButton(
  onPressed: () {
    onToggle(student.id);
  },
  child: Text(
    student.expanded ? 'Show less' : 'Show more',
    style: TextStyle(color: AppColors.interactive),
  ),
),

          ),
        ],
      ),
    );

  }
  Widget _infoRow(IconData icon, String text, bool isDark) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 16,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}
Widget _stat(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value, 
          style: AppTextStyles.body.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}