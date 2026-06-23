// lib/Admin/presentation/widgets/skeleton_activity_card.dart
import 'package:flutter/material.dart';
import '../widgets/skeleton_box.dart';

class SkeletonActivityCard extends StatelessWidget {
  const SkeletonActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 120, height: 14),
                    SizedBox(height: 6),
                    SkeletonBox(width: 180, height: 12),
                  ],
                ),
              ),
              SkeletonBox(width: 70, height: 26, borderRadius: 8),
            ],
          ),
          SizedBox(height: 8),
          SkeletonBox(width: 80, height: 11),
        ],
      ),
    );
  }
}