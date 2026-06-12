import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../services/theme_provider.dart';
import '../../widgets/app_bar_with_logout.dart';
import 'student_tracking.dart';
import '../../providers/CachedChatProvider.dart';
class StudentSupport extends StatelessWidget {
  const StudentSupport({super.key});
  
  // ================= MODAL HELPERS =================
  // void _showChatBot(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => Container(
  //       height: MediaQuery.of(context).size.height * 0.85,
  //       decoration: BoxDecoration(
  //         color: Theme.of(context).colorScheme.surface,
  //         borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
  //       ),
  //       padding: const EdgeInsets.all(25),
  //       child: Column(
  //         children: [
  //           Row(
  //             children: [
  //               CircleAvatar(
  //                 backgroundColor: Colors.blue.shade50,
  //                 child: const Icon(
  //                   Icons.smart_toy_outlined,
  //                   color: Colors.blue,
  //                 ),
  //               ),
  //               const SizedBox(width: 15),
  //               const Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     "FAQ Assistant",
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 18,
  //                     ),
  //                   ),
  //                   Text(
  //                     "Online",
  //                     style: TextStyle(color: Colors.green, fontSize: 12),
  //                   ),
  //                 ],
  //               ),
  //               const Spacer(),
  //               IconButton(
  //                 icon: const Icon(Icons.close),
  //                 onPressed: () => Navigator.pop(context),
  //               ),
  //             ],
  //           ),
  //           const Divider(height: 30),
  //           Expanded(
  //             child: ListView(
  //               children: [
  //                 _buildChatBubble(
  //                   "Hi! I'm here to help you with questions about AAST Connect. You can ask me about training hours, applications, documents, and system features.",
  //                 ),
  //                 const SizedBox(height: 20),
  //                 Text(
  //                   "Frequently Asked Questions:",
  //                   style: TextStyle(
  //                     color: Theme.of(context).colorScheme.onSurface,
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 16,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 10),
  //                 _buildFAQItem(
  //                   context,
  //                   "What are training hours?",
  //                   "Training hours are the required practical work hours that students must complete as part of their academic program. These hours can be completed through internships, workshops, or on-campus training programs.",
  //                 ),
  //                 _buildFAQItem(
  //                   context,
  //                   "How do I submit my training hours?",
  //                   "To submit your training hours:\n1. Go to your Profile page\n2. Click on 'Submit Training Hours'\n3. Fill in the program details\n4. Upload your training certificate\n5. Add supervisor information\n6. Click Submit",
  //                 ),
  //                 _buildFAQItem(
  //                   context,
  //                   "Who approves my training hours?",
  //                   "Training hours are approved by your academic advisor and the training coordinator. You can track the approval status in your dashboard under 'Pending' applications.",
  //                 ),
  //                 _buildFAQItem(
  //                   context,
  //                   "What happens if my training hours are rejected?",
  //                   "If your training hours are rejected, you'll receive feedback explaining why. Common reasons include incomplete documentation or incorrect information. You can resubmit after addressing the feedback.",
  //                 ),
  //                 _buildFAQItem(
  //                   context,
  //                   "How do I apply for an opportunity?",
  //                   "To apply for an opportunity:\n1. Go to the Training page\n2. Browse available programs\n3. Click 'Apply Now' on your chosen program\n4. Confirm your application\n5. Track its status in your dashboard",
  //                 ),
  //                 _buildFAQItem(
  //                   context,
  //                   "Can I cancel an application after applying?",
  //                   "Yes, you can cancel an application within 24 hours of submission by going to your dashboard and selecting 'Cancel Application'. After 24 hours, please contact your program coordinator directly.",
  //                 ),
  //                 _buildFAQItem(
  //                   context,
  //                   "What documents do I need to apply?",
  //                   "Typically you'll need:\n• Updated CV/Resume\n• Cover letter (if required)\n• Academic transcripts\n• Any certificates relevant to the position\nYou can upload these in your Profile under 'Documents'.",
  //                 ),
  //                 _buildFAQItem(
  //                   context,
  //                   "How do I know the status of my application?",
  //                   "You can check your application status in the dashboard. Statuses include: Pending, Under Review, Accepted, or Rejected. You'll also receive email notifications for any updates.",
  //                 ),
  //                 _buildFAQItem(
  //                   context,
  //                   "Can fresh graduates use the same features as students?",
  //                   "Yes! Fresh graduates can access all features including training opportunities, document management, and program applications. Some programs may have specific eligibility criteria for graduates.",
  //                 ),
  //               ],
  //             ),
  //           ),
  //           const SizedBox(height: 10),
  //           TextField(
  //             decoration: InputDecoration(
  //               hintText: "Ask a question...",
  //               suffixIcon: IconButton(
  //                 icon: const Icon(Icons.send, color: AppColors.lightPrimary),
  //                 onPressed: () {},
  //               ),
  //               filled: true,
  //               fillColor: Colors.grey.shade100,
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(15),
  //                 borderSide: BorderSide.none,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showChatBot(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    final List<String> quickQuestions = [
      "What is my current application status?",
      "Are there new opportunities for me?",
      "What are training hours?",
      "How do I submit my training hours?",
      "What documents do I need to apply?",
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(25),
        child: Consumer<CachedChatProvider>(
            builder: (context, chatProvider, child) {
              return Column(
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: const Icon(Icons.smart_toy_outlined, color: Colors.blue),
                      ),
                      const SizedBox(width: 15),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("FAQ Assistant", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text("Online", style: TextStyle(color: Colors.green, fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  // Chat List
                  Expanded(
                    child: ListView.builder(
                      itemCount: chatProvider.messages.length,
                      itemBuilder: (context, index) {
                        final msg = chatProvider.messages[index];
                        return Align(
                          alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: msg.isUser ? AppColors.lightPrimary : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(color: msg.isUser ? Colors.white : Colors.black87),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Typing Indicator
                  if (chatProvider.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Assistant is typing...", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Quick Questions Chips
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: quickQuestions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            label: Text(quickQuestions[index], style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.blue.shade50,
                            side: BorderSide.none,
                            onPressed: () {
                              chatProvider.sendMessage(quickQuestions[index]);
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Input Field
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Ask a question...",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: AppColors.lightPrimary),
                        onPressed: () {
                          chatProvider.sendMessage(controller.text);
                          controller.clear();
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (text) {
                      chatProvider.sendMessage(text);
                      controller.clear();
                    },
                  ),
                ],
              );
            }
        ),
      ),
    );
  }



  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(answer, style: const TextStyle(height: 1.5)),
          ),
        ],
      ),
    );
  }

  void _showInfoModal(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
        ),
      ),
    );
  }

  // ================= UI BUILDER =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBarWithLogout(
        title: "AAST Connect",
        unreadNotificationCount: 0,
        onTimelinePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const StudentTrackingScreen(),
            ),
          );
        },
        onLogout: () {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Help & Support",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              "Find answers and get assistance",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    "Chat with Us",
                    "Get instant help",
                    Icons.chat_bubble_outline,
                    const Color(0xFFD6E2F2),
                    () => _showChatBot(context),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildActionCard(
                    context,
                    "User Guide",
                    "Step-by-step tutorials",
                    Icons.description_outlined,
                    const Color(0xFFCFE3CF),
                    () => _showUserGuide(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            Text(
              "Contact Us",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 15),
            _buildContactTile(
              context,
              "Email Support",
              "training@aast.edu",
              Icons.email_outlined,
            ),
            _buildContactTile(
              context,
              "Phone Support",
              "+20 2 2622 8888",
              Icons.phone_outlined,
            ),

            const SizedBox(height: 30),
            Text(
              "Resources",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 15),
            _buildResourceTile(
              context,
              "Terms & Conditions",
              Icons.shield_outlined,
              () => _showTerms(context),
            ),
            _buildResourceTile(
              context,
              "Privacy Policy",
              Icons.lock_outline,
              () => _showPrivacy(context),
            ),
            _buildResourceTile(
              context,
              "Training Guidelines",
              Icons.assignment_outlined,
              () => _showGuidelines(context),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CONTENT BUILDERS =================

  void _showUserGuide(BuildContext context) {
    _showInfoModal(context, "User Guide", [
      _guideItem(
        "Create and update your user profile with academic and contact information",
      ),
      _guideItem("Upload CVs and supporting documents in PDF or image formats"),
      _guideItem(
        "Browse training and job opportunities using filters and search",
      ),
      _guideItem("Apply for opportunities by completing application forms"),
      _guideItem("Track application status in your dashboard"),
      _guideItem(
        "Submit training hours with certificates and supervisor details",
      ),
      _guideItem("Monitor training hour approvals and feedback"),
    ]);
  }

  void _showTerms(BuildContext context) {
    _showInfoModal(context, "Terms & Conditions", [
      const Text(
        "By accessing and using the AAST Connect platform, you agree to comply with all academic policies and guidelines established by the Arab Academy for Science, Technology and Maritime Transport.\n\n"
        "Students are responsible for maintaining accurate profile information and submitting authentic documents. Any misrepresentation may result in disciplinary action.",
        style: TextStyle(fontSize: 14, height: 1.5),
      ),
    ]);
  }

  void _showPrivacy(BuildContext context) {
    _showInfoModal(context, "Privacy Policy", [
      const Text(
        "AAST Connect collects and processes student data solely for academic and administrative purposes related to training hours and career development programs.\n\n"
        "Your personal information, including contact details and academic records, is stored securely and accessed only by authorized university personnel.",
        style: TextStyle(fontSize: 14, height: 1.5),
      ),
    ]);
  }

  void _showGuidelines(BuildContext context) {
    _showInfoModal(context, "Training Guidelines", [
      _guideStep(
        "1",
        "All training hours require official university approval before being counted",
      ),
      _guideStep(
        "2",
        "Official training certificates must be uploaded with each submission",
      ),
      _guideStep(
        "3",
        "Incomplete or invalid submissions may be rejected with feedback",
      ),
    ]);
  }

  // ================= SMALL UI PIECES =================

  Widget _guideItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _guideStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.orange.shade100,
            child: Text(
              num,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String sub,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(sub, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context,
    String title,
    String info,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFD6E2F2),
            child: Icon(icon, color: const Color(0xFF284B8C)),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              Text(
                info,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResourceTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.orange.shade300),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: Text(text),
    );
  }
}
