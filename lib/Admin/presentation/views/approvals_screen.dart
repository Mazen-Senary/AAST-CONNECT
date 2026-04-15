import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'theme_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:grad_project/Admin/domain/entities/application.dart';
import 'package:grad_project/Admin/domain/entities/training.dart';
import '../viewmodels/approval_notifier.dart';
import '../../core/di/approval_provider.dart';
import 'package:grad_project/Admin/utils/download_stub.dart';
import 'package:flutter/foundation.dart' show kIsWeb;



class ApprovalsScreen extends ConsumerStatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  ConsumerState<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends ConsumerState<ApprovalsScreen> {



Future<void> _showTrainingRejectDialog(
  Training record,
) async {
  final controller = TextEditingController();
  final themeProvider = provider.Provider.of<ThemeProvider>(context, listen: false);
  final isDark = themeProvider.isDarkMode;
  final notifier = ref.read(approvalsProvider.notifier);

  await showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Reject Training Record',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark 
                          ? AppColors.darkTextPrimary 
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // STUDENT INFO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.darkBackground 
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student',
                    style: AppTextStyles.label.copyWith(
                      color: isDark 
                          ? AppColors.darkTextSecondary 
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.studentName,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark 
                          ? AppColors.darkTextPrimary 
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${record.hoursSubmitted} hours • ${record.supervisorName}',
                    style: AppTextStyles.body.copyWith(
                      color: isDark 
                          ? AppColors.darkTextSecondary 
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // REASON INPUT
            Text(
              'Reason for rejection (optional)',
              style: AppTextStyles.label.copyWith(
                color: isDark 
                    ? AppColors.darkTextSecondary 
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.darkBackground 
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark 
                      ? AppColors.darkDivider 
                      : AppColors.border,
                ),
              ),
              child: TextField(
                controller: controller,
                maxLines: 3,
                style: AppTextStyles.body.copyWith(
                  color: isDark 
                      ? AppColors.darkTextPrimary 
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter reason for rejecting training hours...',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: isDark 
                        ? AppColors.darkTextSecondary 
                        : AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ACTIONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await notifier.rejectTraining(record, null);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark 
                          ? AppColors.darkTextSecondary 
                          : AppColors.textSecondary,
                      side: BorderSide(
                        color: isDark 
                            ? AppColors.darkDivider 
                            : AppColors.border,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await notifier.rejectTraining(
                        record,
                        controller.text.trim(),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentAlert,
                      foregroundColor: AppColors.accentAlertText,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Reject Training',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentAlertText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _showRejectDialog(Application record) async {
  final controller = TextEditingController();
  final themeProvider = provider.Provider.of<ThemeProvider>(context, listen: false);
  final isDark = themeProvider.isDarkMode;
  final notifier = ref.read(approvalsProvider.notifier);

  await showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Rejection Reason',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark 
                          ? AppColors.darkTextPrimary 
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // APPLICANT INFO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.darkBackground 
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Applicant',
                    style: AppTextStyles.label.copyWith(
                      color: isDark 
                          ? AppColors.darkTextSecondary 
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.studentName,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark 
                          ? AppColors.darkTextPrimary 
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // REASON INPUT
            Text(
              'Reason for rejection (optional)',
              style: AppTextStyles.label.copyWith(
                color: isDark 
                    ? AppColors.darkTextSecondary 
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.darkBackground 
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark 
                      ? AppColors.darkDivider 
                      : AppColors.border,
                ),
              ),
              child: TextField(
                controller: controller,
                maxLines: 3,
                style: AppTextStyles.body.copyWith(
                  color: isDark 
                      ? AppColors.darkTextPrimary 
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter reason for rejection...',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: isDark 
                        ? AppColors.darkTextSecondary 
                        : AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ACTIONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await notifier.rejectApplication(record, null); // 👈 reject without reason
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark 
                          ? AppColors.darkTextSecondary 
                          : AppColors.textSecondary,
                      side: BorderSide(
                        color: isDark 
                            ? AppColors.darkDivider 
                            : AppColors.border,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await notifier.rejectApplication(
                        record,
                        controller.text.trim(),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentAlert,
                      foregroundColor: AppColors.accentAlertText,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Reject Application',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentAlertText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final themeProvider = provider.Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final state = ref.watch(approvalsProvider);
    final notifier = ref.read(approvalsProvider.notifier);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
        elevation: 0,
        title: Text(
          'APPROVALS',
          style: AppTextStyles.h1.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode_outlined,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textSecondary,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Selector
            _buildSectionSelector(isDark , state, notifier),
            const SizedBox(height: 24),
            
            // Status Tabs
            _buildStatusTabs(isDark , state, notifier),
            const SizedBox(height: 20),
            
            // Content
            Expanded(
              child: state.selectedSection == 'applications'
                  ? (state.filteredApplications.isEmpty
                      ? _emptyState('applications', isDark)
                      : ListView.separated(
                          itemCount: state.filteredApplications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (_, index) => _buildApplicationCard(
                            state.filteredApplications[index],
                            isDark,
                            notifier
                          ),
                        ))
                  : (state.filteredTrainingHours.isEmpty
                      ? _emptyState('training', isDark)
                      : ListView.separated(
                          itemCount: state.filteredTrainingHours.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (_, index) =>
                            _buildTrainingCard(state.filteredTrainingHours[index], isDark , notifier),

                        )),
            ),
          ],
        ),
      ),
    );
  }
  Widget _statusChip(String status, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status.toUpperCase(),
      style: AppTextStyles.label.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}


  // ---------------- SECTION SELECTOR ----------------

  Widget _buildSectionSelector(bool isDark , state, notifier) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
           notifier.changeSection('applications'); // force refilter
          },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: state.selectedSection == 'applications'
                    ? AppColors.interactive.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppColors.radius),
                border: Border.all(
                  color: state.selectedSection == 'applications'
                      ? AppColors.interactive
                      : (isDark ? AppColors.darkDivider : AppColors.border),
                ),
              ),
              child: Text(
                'Applications',
                textAlign: TextAlign.center,
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: state.selectedSection == 'applications'
                      ? AppColors.interactive
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => notifier.changeSection('training'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: state.selectedSection == 'training'
                    ? AppColors.interactive.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppColors.radius),
                border: Border.all(
                  color: state.selectedSection == 'training'
                      ? AppColors.interactive
                      : (isDark ? AppColors.darkDivider : AppColors.border),
                ),
              ),
              child: Text(
                'Training Hours',
                textAlign: TextAlign.center,
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: state.selectedSection == 'training'
                      ? AppColors.interactive
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- STATUS TABS ----------------

Widget _buildStatusTabs(bool isDark, state, notifier) {
  final tabs = ['PENDING', 'APPROVED', 'REJECTED'];

  final currentFilter =
      state.selectedSection == 'applications'
          ? state.applicationsFilter
          : state.trainingFilter;

  return Row(
    children: tabs.map((tab) {
      final selected = currentFilter == tab;

      return Expanded(
        child: GestureDetector(
          onTap: () => notifier.changeFilter(tab),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.interactive.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppColors.radius),
            ),
            child: Text(
              tab,
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: selected
                    ? AppColors.interactive
                    : isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }).toList(),
  );
}
  // ---------------- CARD ----------------
  Widget _buildApplicationCard(
  Application record,
  bool isDark,
  ApprovalsNotifier notifier,
) {
  final statusColor = record.status == 'PENDING'
      ? Colors.orange
      : record.status == 'APPROVED'
          ? Colors.green
          : Colors.red;

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : AppColors.card,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(record.studentName, style: AppTextStyles.h3),
            _statusChip(record.status, statusColor),
          ],
        ),

        const SizedBox(height: 8),

        _buildDetailItem(
          Icons.badge,
          'College ID: ${record.collegeId}',
          isDark,
        ),

        _buildDetailItem(
          Icons.calendar_today,
          DateFormat('MMM dd, yyyy').format(record.submissionDate),
          isDark,
        ),

        const SizedBox(height: 12),

        if (record.expanded) ...[
          const Divider(),
          _buildDetailItem(
            Icons.description,
            record.coverLetter ?? 'No cover letter',
            isDark,
          ),
        ], // ✅ THIS COMMA IS CRITICAL

        TextButton(
          onPressed: () {
            notifier.toggleApplicationExpanded(record.applicationId);
          },
          child: Text(
            record.expanded ? 'Show less' : 'Show more',
            style: TextStyle(color: AppColors.interactive),
          ),
        ),

        if (record.status == 'PENDING') ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showRejectDialog(record),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentAlertText,
                    side: const BorderSide(color: AppColors.accentAlertText),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => notifier.approveApplication(record),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentSuccess,
                    foregroundColor: AppColors.accentSuccessText,
                  ),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ], // ✅ AND THIS COMMA TOO
      ],
    ),
  );
}
Future<void> downloadFile(String url) async {
  if (kIsWeb) {
    await downloadWeb(url);   // comes from download_web.dart
  } else {
    final dir = await getApplicationDocumentsDirectory();

    final filePath =
        '${dir.path}/training_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await Dio().download(url, filePath);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to:\n$filePath')),
    );
  }
}
  void _openImagePreview(BuildContext context, String imageUrl , String storagePath,) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          InteractiveViewer(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // CLOSE BUTTON
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // DOWNLOAD BUTTON
          FloatingActionButton(
  backgroundColor: Colors.white,
  onPressed: () {
  downloadFile(imageUrl);
},


  child: const Icon(Icons.download, color: Colors.black),
),

        ],
      ),
    ),
  );
}

 Widget _buildTrainingCard(Training record, bool isDark , ApprovalsNotifier notifier) {

  final Color statusColor =
    record.status == 'PENDING'
        ? const Color(0xFFFFC107)
        : record.status == 'APPROVED'
            ? const Color(0xFF4CAF50)
            : const Color(0xFFD32F2F);


  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : AppColors.card,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(record.studentName, style: AppTextStyles.h3),
            _statusChip(record.status, statusColor),
          ],
        ),

        const SizedBox(height: 16),

        // SUMMARY (ALWAYS)
        _buildDetailItem(
          Icons.access_time,
          '${record.hoursSubmitted} hours',
          isDark,
        ),

        _buildDetailItem(
          Icons.calendar_today,
          DateFormat('MMM dd, yyyy').format(record.createdAt),
          isDark,
        ),

        // EXPANDED CONTENT
        if (record.expanded) ...[
          const Divider(height: 32),

          _buildDetailItem(
            Icons.business,
            record.companyName,
            isDark,
          ),

          _buildDetailItem(
            Icons.supervisor_account,
            record.supervisorName,
            isDark,
          ),

          _buildDetailItem(
            Icons.date_range,
            '${DateFormat.yMMMd().format(record.startDate)} → '
            '${DateFormat.yMMMd().format(record.endDate)}',
            isDark,
          ),

          if (record.proofImageUrl != null &&
              record.proofImageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
  onTap: () {
    final path = record.proofImageUrl!
    .split('/training-proofs/')
    .last;



    _openImagePreview(
      context,
      record.proofImageUrl!,
      path,
    );
  },
  child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.network(
      record.proofImageUrl!,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
    ),
  ),
),

          ],
        ],

        const SizedBox(height: 12),

        // SHOW MORE / LESS - ALWAYS AT BOTTOM
        TextButton(
          onPressed: () {
            notifier.toggleTrainingExpanded(record.recordId);

          },
          child: Text(
            record.expanded ? 'Show less' : 'Show more',
            style: TextStyle(color: AppColors.interactive),
          ),
        ),

        // ✅ ACCEPT / REJECT (VISIBLE WHEN PENDING ONLY)
        if (record.status == 'PENDING') ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showTrainingRejectDialog(record),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentAlertText,
                    side: const BorderSide(color: AppColors.accentAlertText),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => notifier.approveTraining(record),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentSuccess,
                    foregroundColor: AppColors.accentSuccessText,
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}


  Widget _buildDetailItem(IconData icon, String value, bool isDark) {
  return Row(
    children: [
      Icon(
        icon,
        size: 18,
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.textSecondary,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ),
    ],
  );
}


  Widget _emptyState(String section, bool isDark) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          section == 'applications'
              ? Icons.description
              : Icons.access_time,
          size: 64,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.textSecondary,
        ),
        const SizedBox(height: 16),
        Text(
          'No ${section == 'applications'
              ? 'applications'
              : 'training hours'} found',
          style: AppTextStyles.h3.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'All ${section == 'applications'
              ? 'applications'
              : 'training hours'} in this status will appear here',
          style: AppTextStyles.body.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

}
