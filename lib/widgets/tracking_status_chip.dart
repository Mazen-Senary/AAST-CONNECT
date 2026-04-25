import 'package:flutter/material.dart';

const Color approvedColor = Color(0xFF4CAF50);
const Color pendingColor = Color(0xFFFFC107);
const Color rejectedColor = Color(0xFFF44336);
const Color canceledColor = Color(0xFF757575);

class TrackingStatusChip extends StatelessWidget {
  final String status;

  const TrackingStatusChip({
    super.key,
    required this.status,
  });

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
      shape: StadiumBorder(side: BorderSide(color: style.color.withValues(alpha: 0.25))),
      backgroundColor: style.color.withValues(alpha: 0.12),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  _StatusStyle _styleForStatus(String status) {
    switch (status) {
      case 'APPROVED':
        return const _StatusStyle('Accepted', approvedColor, Icons.check_circle);
      case 'REJECTED':
        return const _StatusStyle('Rejected', rejectedColor, Icons.cancel);
      case 'CANCELED':
        return const _StatusStyle('Canceled', canceledColor, Icons.do_not_disturb_alt);
      case 'PENDING':
      default:
        return const _StatusStyle('Pending', pendingColor, Icons.hourglass_top);
    }
  }
}

class _StatusStyle {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusStyle(this.label, this.color, this.icon);
}

