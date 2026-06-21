//new program card with save bookmark button and applied state
import 'package:flutter/material.dart';
import '../company_logo.dart';
import '../rounded_container.dart';
import '../../constants/app_colors.dart';

class StudentOpportunitiesProgramCard extends StatelessWidget {
  final Map<String, dynamic> program;
  final VoidCallback onViewDetails;
  final VoidCallback onApply;
  final VoidCallback? onSave;
  final bool isSaved;

  const StudentOpportunitiesProgramCard({
    super.key,
    required this.program,
    required this.onViewDetails,
    required this.onApply,
    this.onSave,
    this.isSaved = false,
  });

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'development':
        return Icons.computer;
      case 'it':
        return Icons.storage;
      case 'security':
        return Icons.security;
      case 'design':
        return Icons.design_services;
      case 'data':
        return Icons.analytics;
      case 'cloud':
        return Icons.cloud;
      case 'ai':
        return Icons.psychology;
      default:
        return Icons.work_outline;
    }
  }

  /// Build company logo or fallback to icon
  Widget _buildCompanyLogo() {
    final logoUrl = program['company_logo_url'] ?? program['companyLogoUrl'];

    return CompanyLogo(
      logoUrl: logoUrl?.toString(),
      fallbackIcon: _getIconForCategory(program['category'] ?? ''),
      fallbackColor: AppColors.lightPrimary,
      borderColor: Colors.grey.shade200,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildCompanyLogo(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program['title'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      program['company'] ?? program['company_name'] ?? 'Unknown Company',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // save bookmark button
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? AppColors.lightPrimary : Colors.grey,
                ),
                onPressed: onSave,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.documentBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  program['type'],
                  style: const TextStyle(
                    color: AppColors.lightPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "${program['hours']} • ${program['location']}",
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
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
                    side: BorderSide(color: AppColors.lightPrimary),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(color: AppColors.lightPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: program['applied']
                        ? Colors.grey.shade200
                        : AppColors.lightSecondary,
                    foregroundColor: program['applied']
                        ? Colors.black87
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: program['applied'] ? null : onApply,
                  child: Text(
                    program['applied']
                        ? 'Applied'
                        : (program['applicationMethod'] == 'EXTERNAL'
                              ? 'Apply on Website'
                              : 'Apply Now'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
