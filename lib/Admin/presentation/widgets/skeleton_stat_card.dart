// lib/Admin/presentation/widgets/skeleton_stat_card.dart
import 'package:flutter/material.dart';
import '../widgets/skeleton_box.dart';

class SkeletonStatCard extends StatelessWidget {
  const SkeletonStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 32, height: 32, borderRadius: 8),
              SizedBox(width: 8),
              SkeletonBox(width: 100, height: 14),
            ],
          ),
          SizedBox(height: 12),
          SkeletonBox(width: 60, height: 24),
          SizedBox(height: 6),
          SkeletonBox(width: 80, height: 12),
        ],
      ),
    );
  }
}