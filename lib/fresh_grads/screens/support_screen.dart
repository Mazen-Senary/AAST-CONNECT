import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/contact_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/resource_title.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  void _showChatDialog(BuildContext context, bool isDark) {
    final TextEditingController _chatController = TextEditingController();
    final List<Map<String, String>> _messages = [
      {
        'sender': 'bot',
        'text':
        "Hi! I'm here to help you with questions about AAST Connect. You can ask me about training hours, applications, documents, and system features.",
        'time': _currentTime(),
      }
    ];

    final List<String> quickQuestions = [
      'What are training hours?',
      'How do I submit my training?',
      'How do I apply for a job?',
      'Where is my application status?',
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.72,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBg : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.support_agent,
                                color: AppColors.accentBlue, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FAQ Assistant',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                'Online',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Icon(Icons.close,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 20),

                    // Messages
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final msg = _messages[i];
                          final isBot = msg['sender'] == 'bot';
                          return Align(
                            alignment: isBot
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: isBot
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.end,
                              children: [
                                if (isBot) ...[
                                  Container(
                                    width: 32,
                                    height: 32,
                                    margin: const EdgeInsets.only(right: 8, top: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.support_agent,
                                        color: AppColors.accentBlue, size: 16),
                                  ),
                                ],
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isBot
                                          ? (isDark
                                          ? AppColors.darkSurface
                                          : const Color(0xFFF0F4F8))
                                          : AppColors.primaryGreen,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(isBot ? 4 : 16),
                                        bottomRight: Radius.circular(isBot ? 16 : 4),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          msg['text']!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isBot
                                                ? (isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.textPrimary)
                                                : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          msg['time']!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isBot
                                                ? AppColors.textSecondary
                                                : Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Quick questions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick questions:',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: quickQuestions
                                  .map(
                                    (q) => GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      _messages.add({
                                        'sender': 'user',
                                        'text': q,
                                        'time': _currentTime(),
                                      });
                                      _messages.add({
                                        'sender': 'bot',
                                        'text':
                                        'Thanks for asking! Please contact training@aast.edu for detailed information on this topic.',
                                        'time': _currentTime(),
                                      });
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      q,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Input
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              decoration: InputDecoration(
                                hintText: 'Ask a question...',
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? AppColors.darkSurface
                                    : const Color(0xFFF5F5F5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              final text = _chatController.text.trim();
                              if (text.isEmpty) return;
                              setModalState(() {
                                _messages.add({
                                  'sender': 'user',
                                  'text': text,
                                  'time': _currentTime(),
                                });
                                _messages.add({
                                  'sender': 'bot',
                                  'text':
                                  'Thanks for reaching out! For more details, please contact training@aast.edu.',
                                  'time': _currentTime(),
                                });
                              });
                              _chatController.clear();
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: AppColors.accentBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.send,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ), // Container
            );  // Dialog
          },
        );
      },
    );
  }

  void _showUserGuideDialog(BuildContext context, bool isDark) {
    final List<String> guideItems = [
      'Create and update your user profile with academic and contact information',
      'Upload CVs and supporting documents in PDF or image formats',
      'Browse training and job opportunities using filters and search',
      'Apply for opportunities by completing application forms',
      'Track application status in your dashboard',
      'Submit training hours with certificates and supervisor details',
      'Monitor training hour approvals and feedback',
    ];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User Guide',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Icon(Icons.close,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...guideItems.map(
                    (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 12, top: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle,
                            color: AppColors.primaryGreen, size: 18),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTrainingGuidelinesDialog(BuildContext context, bool isDark) {
    final List<String> guidelines = [
      'All training hours require official university approval before being counted',
      'Official training certificates must be uploaded with each submission',
      'Incomplete or invalid submissions may be rejected with feedback',
      'Corrected documents can be resubmitted after rejection',
      'Training organizations must provide supervisor contact information',
    ];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Training Guidelines',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Icon(Icons.close,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...guidelines.asMap().entries.map(
                    (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        margin: const EdgeInsets.only(right: 12, top: 1),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsAndConditionsDialog(BuildContext context, bool isDark) {
    final String terms =
        'By accessing and using the AAST Connect platform, you agree to comply '
        'with all academic policies and guidelines established by the Arab Academy '
        'for Science, Technology and Maritime Transport. Students are responsible '
        'for maintaining accurate profile information and submitting authentic '
        'documents. Any misrepresentation may result in disciplinary action. '
        'The university reserves the right to verify all submitted training hours '
        'and certificates. Approved hours contribute to your official academic '
        'record. All application submissions are subject to review by authorized '
        'university staff. The university is not responsible for external '
        'opportunity postings or outcomes.';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Icon(
                      Icons.close,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                terms,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, bool isDark) {
    final String policy =
        'AAST Connect collects and processes student data solely for academic and administrative purposes related to training hours and career development programs.\n\n'
        'Your personal information, including contact details and academic records, is stored securely and accessed only by authorized university personnel.\n\n'
        'Uploaded documents and certificates are maintained in compliance with university data retention policies. You may request access to your data at any time.\n\n'
        'The platform does not share student information with third parties without explicit consent, except as required by academic partnerships or legal obligations.'
    ;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Icon(
                      Icons.close,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                policy,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _currentTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Title
          Text(
            'Help & Support',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find answers and get assistance',
            style: TextStyle(
              fontSize: 14,
              color:
              isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Quick Action Cards
          Row(
            children: [
              Expanded(
                child: QuickActionCard(
                  icon: Icons.chat_bubble_outline,
                  title: 'Chat with Us',
                  subtitle: 'Get instant help',
                  bgColor: isDark ? AppColors.darkBlue : AppColors.lightBlue,
                  iconColor: AppColors.accentBlue,
                  isDark: isDark,
                  onTap: () => _showChatDialog(context, isDark),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionCard(
                  icon: Icons.menu_book_outlined,
                  title: 'User Guide',
                  subtitle: 'Step-by-step tutorials',
                  bgColor: isDark ? AppColors.darkGreen : AppColors.lightGreen,
                  iconColor: AppColors.primaryGreen,
                  isDark: isDark,
                  onTap: () => _showUserGuideDialog(context, isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Contact Us
          Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ContactCard(
            icon: Icons.email_outlined,
            iconBg: AppColors.lightBlue,
            iconColor: AppColors.accentBlue,
            title: 'Email Support',
            highlight: 'training@aast.edu',
            subtitle: 'Send us an email anytime',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          ContactCard(
            icon: Icons.phone_outlined,
            iconBg: AppColors.lightBlue,
            iconColor: AppColors.accentBlue,
            title: 'Phone Support',
            highlight: '+20 2 2622 8888',
            subtitle: 'Mon-Fri, 9AM-5PM',
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // Resources
          Text(
            'Resources',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ResourceTile(
            icon: Icons.shield_outlined,
            iconBg: AppColors.lightOrange,
            iconColor: AppColors.accentOrange,
            title: 'Terms & Conditions',
            isDark: isDark,
            onTap: () => _showTermsAndConditionsDialog(context, isDark),
          ),
          const SizedBox(height: 10),
          ResourceTile(
            icon: Icons.lock_outline,
            iconBg: AppColors.lightOrange,
            iconColor: AppColors.accentOrange,
            title: 'Privacy Policy',
            isDark: isDark,
            onTap: () => _showPrivacyPolicyDialog(context, isDark),
          ),
          const SizedBox(height: 10),
          ResourceTile(
            icon: Icons.description_outlined,
            iconBg: AppColors.lightOrange,
            iconColor: AppColors.accentOrange,
            title: 'Training Guidelines',
            isDark: isDark,
            onTap: () => _showTrainingGuidelinesDialog(context, isDark),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
