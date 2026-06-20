import 'package:flutter/material.dart';
import '../widgets/summary_item.dart';import '../theme/app_theme.dart';

class ApplicationSummaryCard extends StatelessWidget {
  final bool isDark;
  const ApplicationSummaryCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBlue : AppColors.lightBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Application Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
            color: isDark ? AppColors.accentBlue : AppColors.accentBlue)),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          SummaryItem(value: '24', label: 'Applied', isDark: isDark),
          SummaryItem(value: '8', label: 'Interviews', isDark: isDark),
          SummaryItem(value: '3', label: 'Offers', isDark: isDark),
        ]),
      ]),
    );
  }
}