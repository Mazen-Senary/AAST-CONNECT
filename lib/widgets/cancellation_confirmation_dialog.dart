import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class CancellationConfirmationDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String confirmText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CancellationConfirmationDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.confirmText,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.rejected.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppColors.rejected,
                size: 32.sp,
              ),
            ),

            SizedBox(height: 20.h),

            // Title
            Text(
              title,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(
                      'Keep',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rejected,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Static methods for specific use cases
  static void showApplicationCancellation(
    BuildContext context, {
    required String jobTitle,
    required String companyName,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CancellationConfirmationDialog(
        title: 'Cancel Application?',
        subtitle:
            'Are you sure you want to cancel your application for "$jobTitle" at $companyName? You can re-apply later if needed.',
        confirmText: 'Cancel Application',
        onConfirm: () {
          Navigator.of(context).pop();
          onConfirm();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  static void showTrainingCancellation(
    BuildContext context, {
    required String companyName,
    required int hours,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CancellationConfirmationDialog(
        title: 'Cancel Training Submission?',
        subtitle:
            'Are you sure you want to cancel your training submission for $hours hours at $companyName? You can resubmit later if needed.',
        confirmText: 'Cancel Submission',
        onConfirm: () {
          Navigator.of(context).pop();
          onConfirm();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}
