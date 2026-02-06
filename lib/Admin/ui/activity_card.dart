import 'package:flutter/material.dart';
import '../models/activity_status.dart';
import '../theme/app_colors.dart';
class ActivityCard extends StatelessWidget {
  final String student;
  final String action;
  final String time;
  final ActivityStatus status;

  const ActivityCard({
    super.key,
    required this.student,
    required this.action,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      action,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors['bg'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors['text'],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _statusColors(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.pending:
        return {
          'bg':AppColors.accentAlert,
          'text':AppColors.accentAlertText,
        };
      case ActivityStatus.newItem:
        return {
          'bg': AppColors.accentInfo,
          'text':  AppColors.accentInfoText,
        };
      case ActivityStatus.completed:
        return {
          'bg': AppColors.accentSuccess,
          'text': AppColors.accentSuccessText,
        };
    }
  }
}
