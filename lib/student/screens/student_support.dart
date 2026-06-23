import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../services/theme_provider.dart';
import '../../widgets/app_bar_with_logout.dart';
import 'student_tracking.dart';
import '../../providers/CachedChatProvider.dart';
class StudentSupport extends StatelessWidget {
  final bool embedded;
  final VoidCallback? onProfileTab;
  final VoidCallback? onTrackingTab;

  const StudentSupport({
    super.key,
    this.embedded = false,
    this.onProfileTab,
    this.onTrackingTab,
  });
  
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        padding: EdgeInsets.all(25.w),
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
                      SizedBox(width: 15.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("FAQ Assistant", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
                          Text("Online", style: TextStyle(color: Colors.green, fontSize: 12.sp)),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(height: 30.h),

                  // Chat List
                  Expanded(
                    child: ListView.builder(
                      itemCount: chatProvider.messages.length,
                      itemBuilder: (context, index) {
                        final msg = chatProvider.messages[index];
                        return Align(
                          alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5.h),
                            padding: EdgeInsets.all(15.w),
                            decoration: BoxDecoration(
                              color: msg.isUser ? AppColors.lightPrimary : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20.r),
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
                    Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Assistant is typing...", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                      ),
                    ),

                  SizedBox(height: 10.h),

                  // Quick Questions Chips
                  SizedBox(
                    height: 40.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: quickQuestions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: ActionChip(
                            label: Text(quickQuestions[index], style: TextStyle(fontSize: 12.sp)),
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

                  SizedBox(height: 10.h),

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
                        borderRadius: BorderRadius.circular(15.r),
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
      margin: EdgeInsets.symmetric(vertical: 4.h),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(answer, style: TextStyle(height: 1.5, fontSize: 13.sp)),
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
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 520.w),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.maxFinite,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 420.h),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI BUILDER =================

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Help & Support",
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              "Find answers and get assistance",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 25.h),

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
                SizedBox(width: 15.w),
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

            SizedBox(height: 30.h),
            Text(
              "Contact Us",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 15.h),
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

            SizedBox(height: 30.h),
            Text(
              "Resources",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 15.h),
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
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBarWithLogout(
        title: "AAST Connect",
        unreadNotificationCount: 0,
        onTimelinePressed: onTrackingTab ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentTrackingScreen(),
                ),
              );
            },
        onProfilePressed: onProfileTab,
      ),
      body: content,
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
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          SizedBox(width: 10.w),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14.sp))),
        ],
      ),
    );
  }

  Widget _guideStep(String num, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.orange.shade100,
            child: Text(
              num,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14.sp))),
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
      borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Icon(icon, size: 28.sp),
            SizedBox(height: 10.h),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            Text(sub, style: TextStyle(fontSize: 12.sp)),
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
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFD6E2F2),
            child: Icon(icon, color: const Color(0xFF284B8C)),
          ),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12.sp,
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
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.orange.shade300),
            SizedBox(width: 15.w),
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
