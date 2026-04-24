import 'package:flutter/material.dart';
import 'rounded_container.dart';

class StudentHomeProgramCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String hours;
  final VoidCallback onViewDetails;
  final VoidCallback? onApply;
  final bool isApplied;

  const StudentHomeProgramCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.hours,
    required this.onViewDetails,
    this.onApply,
    this.isApplied = false,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      margin: const EdgeInsets.only(bottom: 15),
      borderColor: Theme.of(context).dividerColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Training",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(hours, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF284B8C)),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(color: Color(0xFF284B8C)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
               Expanded(
                 child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                     backgroundColor: isApplied 
                         ? Colors.green 
                         : const Color(0xFF637E99),
                     padding: const EdgeInsets.symmetric(vertical: 12),
                   ),
                   onPressed: onApply,
                   child: Text(
                     isApplied ? "Applied ✓" : "Apply Now",
                     style: const TextStyle(
                       color: Colors.white,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ),
               ),
            ],
          ),
        ],
      ),
    );
  }
}
