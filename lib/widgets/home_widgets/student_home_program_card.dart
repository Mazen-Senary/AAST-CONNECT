import 'package:flutter/material.dart';
import '../rounded_container.dart';

class StudentHomeProgramCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String hours;
  final VoidCallback onViewDetails;
  final VoidCallback? onApply;
  final bool isApplied;
  final bool isExternal;
  final String? logoUrl;
  final String vacancyType;

  const StudentHomeProgramCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.hours,
    required this.onViewDetails,
    this.onApply,
    this.isApplied = false,
    this.isExternal = false,
    this.logoUrl,
    this.vacancyType = 'INTERNSHIP',
  });

  /// Get default icon based on vacancy type
  IconData _getDefaultIcon() {
    switch (vacancyType.toUpperCase()) {
      case 'TRAINING':
        return Icons.book;
      case 'INTERNSHIP':
        return Icons.school;
      case 'JOB':
      case 'COMPETITION':
        return Icons.work;
      default:
        return Icons.business;
    }
  }

  /// Build fallback icon with type-specific styling
  Widget _buildFallbackIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getDefaultIcon(),
        size: 24,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Build company logo or fallback to type-specific icon
  Widget _buildCompanyLogo(BuildContext context) {
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            logoUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to type-specific icon if image fails to load
              return _buildFallbackIcon(context);
            },
          ),
        ),
      );
    }

    // Fallback: Show type-specific icon if no logo URL
    return _buildFallbackIcon(context);
  }

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      margin: const EdgeInsets.only(bottom: 15),
      borderColor: Theme.of(context).dividerColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + Title + Subtitle
          Row(
            children: [
              _buildCompanyLogo(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                  vacancyType,
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
                   onPressed: isApplied ? null : onApply,
                   child: Text(
                     isApplied 
                         ? "Applied ✓" 
                         : (isExternal ? "Apply on Website" : "Apply Now"),
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
