import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';

class DocumentsListSection extends StatelessWidget {
  final List<Document> documents;
  final bool isDark;
  final VoidCallback onManage;

  const DocumentsListSection({required this.documents, required this.isDark, required this.onManage});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
        ElevatedButton.icon(onPressed: onManage,
          icon: const Icon(Icons.upload_outlined, size: 14, color: Colors.white),
          label: const Text('Manage', style: TextStyle(fontSize: 13, color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.applyButton,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
        ),
      ]),
      const SizedBox(height: 12),
      ...documents.map((doc) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBg : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.description_outlined, color: AppColors.accentBlue, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(doc.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary), overflow: TextOverflow.ellipsis),
              Text('${doc.type} • ${doc.date}', style: TextStyle(fontSize: 11,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
            ])),
          ]),
        ),
      )),
    ]);
  }
}