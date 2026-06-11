import 'package:flutter/material.dart';
import '../rounded_container.dart';

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
    // ✅ FIX: Cap displayed completed hours at required hours
    // Logic: If student completes more hours than required, display only the required amount
    double displayedCompletedHours = completedHours > totalHours ? totalHours : completedHours;
    
    // ✅ FIX: Calculate percentage and cap at 100%
    double percentage = (displayedCompletedHours / totalHours) * 100;
    if (percentage > 100) {
      percentage = 100.0;
    }
    
    // ✅ FIX: Calculate remaining hours and show 0 when at 100%
    double remainingHours = totalHours - displayedCompletedHours;
    if (percentage >= 100) {
      remainingHours = 0;
    }

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
                "$displayedCompletedHours of $totalHours hours completed",
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
              // ✅ FIX: Clamp progress value to 0-1 range using displayed hours
              value: (displayedCompletedHours / totalHours).clamp(0.0, 1.0),
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
