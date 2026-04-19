// import 'package:flutter/material.dart';
// import 'rounded_container.dart';
//
// class StudentOpportunitiesProgramCard extends StatelessWidget {
//   final Map<String, dynamic> program;
//   final VoidCallback onViewDetails;
//   final VoidCallback onApply;
//
//   const StudentOpportunitiesProgramCard({
//     super.key,
//     required this.program,
//     required this.onViewDetails,
//     required this.onApply,
//   });
//
//   Color _getColorForCategory(String category) {
//     switch (category.toLowerCase()) {
//       case 'development':
//         return Colors.green.shade100;
//       case 'it':
//         return Colors.blue.shade100;
//       case 'security':
//         return Colors.red.shade100;
//       case 'design':
//         return Colors.orange.shade100;
//       case 'data':
//         return Colors.teal.shade100;
//       case 'cloud':
//         return Colors.lightBlue.shade100;
//       case 'ai':
//         return Colors.indigo.shade100;
//       case 'general':
//         return Colors.grey.shade100;
//       default:
//         return Colors.grey.shade100;
//     }
//   }
//
//   IconData _getIconForCategory(String category) {
//     switch (category.toLowerCase()) {
//       case 'development':
//         return Icons.computer;
//       case 'it':
//         return Icons.storage;
//       case 'security':
//         return Icons.security;
//       case 'design':
//         return Icons.design_services;
//       case 'data':
//         return Icons.analytics;
//       case 'cloud':
//         return Icons.cloud;
//       case 'ai':
//         return Icons.psychology;
//       case 'general':
//         return Icons.work;
//       default:
//         return Icons.work_outline;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return RoundedContainer(
//       margin: const EdgeInsets.only(bottom: 15),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: _getColorForCategory(program['category']),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(_getIconForCategory(program['category']), size: 24),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       program['title'],
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     Text(
//                       program['company'],
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 15),
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFD6E2F2),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   program['type'],
//                   style: const TextStyle(
//                     color: Color(0xFF284B8C),
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   "${program['hours']} • ${program['location']}",
//                   style: const TextStyle(color: Colors.grey),
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: onViewDetails,
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     side: const BorderSide(color: Color(0xFF284B8C)),
//                   ),
//                   child: const Text(
//                     'View Details',
//                     style: TextStyle(color: Color(0xFF284B8C)),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: program['applied']
//                         ? Colors.grey.shade200
//                         : const Color(0xFF637E99),
//                     foregroundColor: program['applied']
//                         ? Colors.black87
//                         : Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   onPressed: program['applied'] ? onViewDetails : onApply,
//                   child: Text(
//                     program['applied'] ? 'Applied' : 'Apply Now',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

//new program card with save bookmark button and applied state
import 'package:flutter/material.dart';
import 'rounded_container.dart';

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

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'development': return Colors.green.shade100;
      case 'it': return Colors.blue.shade100;
      case 'security': return Colors.red.shade100;
      case 'design': return Colors.orange.shade100;
      case 'data': return Colors.teal.shade100;
      case 'cloud': return Colors.lightBlue.shade100;
      case 'ai': return Colors.indigo.shade100;
      default: return Colors.grey.shade100;
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'development': return Icons.computer;
      case 'it': return Icons.storage;
      case 'security': return Icons.security;
      case 'design': return Icons.design_services;
      case 'data': return Icons.analytics;
      case 'cloud': return Icons.cloud;
      case 'ai': return Icons.psychology;
      default: return Icons.work_outline;
    }
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getColorForCategory(program['category']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIconForCategory(program['category']), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      program['company'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // save bookmark button
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? const Color(0xFF284B8C) : Colors.grey,
                ),
                onPressed: onSave,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  program['type'],
                  style: const TextStyle(
                    color: Color(0xFF284B8C),
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
                    backgroundColor: program['applied']
                        ? Colors.grey.shade200
                        : const Color(0xFF637E99),
                    foregroundColor: program['applied']
                        ? Colors.black87
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: program['applied'] ? onViewDetails : onApply,
                  child: Text(
                    program['applied'] ? 'Applied' : 'Apply Now',
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