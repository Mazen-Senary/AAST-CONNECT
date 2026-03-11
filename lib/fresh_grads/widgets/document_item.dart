import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';
class DocumentItem extends StatelessWidget {
  final Document doc;
  final bool isDark;
  final VoidCallback onDelete;
  const DocumentItem({required this.doc, required this.isDark, required this.onDelete});

  Color get _iconBg {
    if (doc.status == 'Approved') return AppColors.lightGreen;
    if (doc.status == 'Rejected') return const Color(0xFFFCE4EC);
    return AppColors.lightOrange;
  }

  Color get _iconColor {
    if (doc.status == 'Approved') return AppColors.primaryGreen;
    if (doc.status == 'Rejected') return const Color(0xFFE91E63);
    return AppColors.accentOrange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40,
              decoration: BoxDecoration(color: _iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.description_outlined, color: _iconColor, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doc.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary), overflow: TextOverflow.ellipsis),
            Text('${doc.type} • ${doc.size} • ${doc.date}', style: TextStyle(fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
          ])),
          GestureDetector(onTap: onDelete, child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20)),
        ]),
        const SizedBox(height: 8),
        StatusBadge(status: doc.status),
        if (doc.rejectionReason != null) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(10), width: double.infinity,
              decoration: BoxDecoration(color: const Color(0xFFFCE4EC), borderRadius: BorderRadius.circular(8)),
              child: RichText(text: TextSpan(children: [
                const TextSpan(text: 'Reason: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                TextSpan(text: doc.rejectionReason, style: const TextStyle(fontSize: 12, color: Colors.red)),
              ]))),
        ],
      ]),
    );
  }
}