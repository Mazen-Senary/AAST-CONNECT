import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, color;
    IconData icon;
    if (status == 'Approved') { bg = AppColors.lightGreen; color = AppColors.primaryGreen; icon = Icons.check_circle_outline; }
    else if (status == 'Rejected') { bg = const Color(0xFFFCE4EC); color = const Color(0xFFE91E63); icon = Icons.cancel_outlined; }
    else { bg = AppColors.lightOrange; color = AppColors.accentOrange; icon = Icons.access_time_outlined; }

    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}