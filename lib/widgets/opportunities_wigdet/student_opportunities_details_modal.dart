// import 'package:flutter/material.dart';
//
// class StudentOpportunitiesDetailsModal {
//   static void show(
//     BuildContext context,
//     String title,
//     String company,
//     String hours,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       builder: (context) => Container(
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.8,
//         ),
//         padding: const EdgeInsets.all(25),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//               Text(
//                 company,
//                 style: const TextStyle(fontSize: 18, color: Colors.grey),
//               ),
//               const SizedBox(height: 20),
//
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFD6E2F2),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(
//                       Icons.school,
//                       size: 30,
//                       color: Color(0xFF284B8C),
//                     ),
//                     const SizedBox(width: 15),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Duration: $hours'),
//                           const Text('Type: Training Program'),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               const Text(
//                 'Description',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'This comprehensive training program is designed to help students gain practical skills and industry experience. You will work on real-world projects under the guidance of experienced mentors.',
//               ),
//
//               const SizedBox(height: 20),
//
//               const Text(
//                 'Requirements',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               const Text('• Basic programming knowledge'),
//               const Text('• Currently enrolled student'),
//               const Text('• Good academic standing'),
//
//               const SizedBox(height: 20),
//
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.calendar_today,
//                     size: 16,
//                     color: Colors.grey,
//                   ),
//                   const SizedBox(width: 8),
//                   const Text('Start Date: Flexible'),
//                 ],
//               ),
//
//               const SizedBox(height: 20),
//
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         side: const BorderSide(color: Color(0xFF284B8C)),
//                       ),
//                       child: const Text('Close'),
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF284B8C),
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text(
//                         'Apply Now',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//new version with dynamic data and apply button state
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentOpportunitiesDetailsModal {
  static void show(
      BuildContext context,
      Map<String, dynamic> program,
      VoidCallback onApply,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      program['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                program['company'] ?? '',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E2F2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school, size: 30, color: Color(0xFF284B8C)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${program['type'] ?? 'N/A'}'),
                          Text('Location: ${program['location'] ?? 'Not specified'}'),
                          Text('Work Mode: ${program['workMode'] ?? 'N/A'}'),
                          Text('Paid: ${program['paidStatus'] == true ? 'Yes' : 'No'}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (program['startDate'] != null) ...[
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Deadline: ${program['startDate']}'),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(program['description'] ?? 'No description available'),
              const SizedBox(height: 20),
              const Text(
                'Required Skills',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(program['requirements'] ?? 'No specific requirements'),
              const SizedBox(height: 20),
               Row(
                 children: [
                   Expanded(
                     child: OutlinedButton(
                       onPressed: () => Navigator.pop(context),
                       style: OutlinedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 15),
                         side: const BorderSide(color: Color(0xFF284B8C)),
                       ),
                       child: const Text('Close'),
                     ),
                   ),
                   const SizedBox(width: 15),
                   Expanded(
                     child: ElevatedButton(
                       style: ElevatedButton.styleFrom(
                         backgroundColor: program['applied'] == true
                             ? Colors.grey.shade200
                             : const Color(0xFF637E99),
                         padding: const EdgeInsets.symmetric(vertical: 15),
                       ),
                       onPressed: program['applied'] == true
                           ? null
                           : () async {
                             if (program['applicationMethod'] == 'EXTERNAL' &&
                                 program['externalApplyUrl'] != null) {
                               // Redirect to external link
                               final url = Uri.parse(program['externalApplyUrl']);
                               if (await canLaunchUrl(url)) {
                                 await launchUrl(url, mode: LaunchMode.externalApplication);
                               }
                               Navigator.pop(context);
                             } else {
                               // Internal application
                               Navigator.pop(context);
                               onApply();
                             }
                           },
                       child: Text(
                         program['applied'] == true 
                             ? 'Already Applied'
                             : (program['applicationMethod'] == 'EXTERNAL'
                                 ? 'Apply on Company Website'
                                 : 'Apply Now'),
                         style: TextStyle(
                           color: program['applied'] == true
                               ? Colors.black54
                               : Colors.white,
                         ),
                       ),
                     ),
                   ),
                 ],
               ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}