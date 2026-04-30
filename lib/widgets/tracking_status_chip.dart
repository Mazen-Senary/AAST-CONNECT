import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TrackingStatusChip extends StatelessWidget {
  final String status;

  const TrackingStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final style = _styleForStatus(normalized);

    return Chip(
      avatar: Icon(style.icon, size: 16, color: style.color),
      label: Text(
        style.label,
        style: TextStyle(color: style.color, fontWeight: FontWeight.w600),
      ),
      shape: StadiumBorder(
        side: BorderSide(color: style.color.withValues(alpha: 0.25)),
      ),
      backgroundColor: style.color.withValues(alpha: 0.12),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  _StatusStyle _styleForStatus(String status) {
    switch (status) {
      case 'APPROVED':
        return _StatusStyle('Accepted', AppColors.approved, Icons.check_circle);
      case 'REJECTED':
        return _StatusStyle('Rejected', AppColors.rejected, Icons.cancel);
      case 'CANCELED':
        return _StatusStyle(
          'Canceled',
          AppColors.canceled,
          Icons.do_not_disturb_alt,
        );
      case 'PENDING':
      default:
        return _StatusStyle('Pending', AppColors.pending, Icons.hourglass_top);
    }
  }
}

class _StatusStyle {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusStyle(this.label, this.color, this.icon);
}
