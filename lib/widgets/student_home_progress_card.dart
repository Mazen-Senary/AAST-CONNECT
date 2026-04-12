import 'package:flutter/material.dart';
import 'rounded_container.dart';

class StudentHomeProgressCard extends StatelessWidget {
  final double completedHours;
  final double totalHours;
  final Color? backgroundColor;

  const StudentHomeProgressCard({
    super.key,
    required this.completedHours,
    required this.totalHours,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = (completedHours / totalHours) * 100;
    double remainingHours = totalHours - completedHours;

    return RoundedContainer(
      backgroundColor: backgroundColor ?? const Color(0xffEAD2B7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Training Progress",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$completedHours of $totalHours hours completed",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                "${percentage.toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completedHours / totalHours,
              minHeight: 10,
              backgroundColor: Colors.white,
              color: const Color(0xFF206E54),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${remainingHours.toStringAsFixed(0)} hours remaining",
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
