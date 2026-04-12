import 'package:flutter/material.dart';
import 'rounded_container.dart';

class StudentHomeStatCard extends StatelessWidget {
  final Color backgroundColor;
  final String number;
  final String label;
  final IconData icon;

  const StudentHomeStatCard({
    super.key,
    required this.backgroundColor,
    required this.number,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      backgroundColor: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(height: 10),
          Text(
            number,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
