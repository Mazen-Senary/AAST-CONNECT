import 'package:flutter/material.dart';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.rejected.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppColors.rejected,
                size: 32,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rejected,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
