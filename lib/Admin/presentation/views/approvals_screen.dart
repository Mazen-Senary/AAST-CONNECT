import 'dart:async';

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
import 'dart:html' as html;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';


class ApprovalsScreen extends ConsumerStatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  ConsumerState<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends ConsumerState<ApprovalsScreen> {
  Timer? _bannerTimer;
  double _bannerOpacity = 1.0;
  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerOpacity = 1.0;
    _bannerTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _bannerOpacity = 0.0);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) ref.read(approvalsProvider.notifier).dismissNewData();
      });
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  Future<void> _showTrainingRejectDialog(Training record) async {
    final controller = TextEditingController();
    final themeProvider = provider.Provider.of<ThemeProvider>(
      context,
      listen: false,
    );
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
                    color: isDark ? AppColors.darkDivider : AppColors.border,
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
    final themeProvider = provider.Provider.of<ThemeProvider>(
      context,
      listen: false,
    );
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
                    color: isDark ? AppColors.darkDivider : AppColors.border,
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
                        await notifier.rejectApplication(
                          record,
                          null,
                        ); // 👈 reject without reason
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
    if (state.hasNewData && _bannerTimer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startBannerTimer());
    }
    if (!state.hasNewData) {
      _bannerTimer = null;
      _bannerOpacity = 1.0;
    }
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 20,
          20,
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ADMIN PANEL',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Approvals',
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.hasNewData)
                    AnimatedOpacity(
                      opacity: _bannerOpacity,
                      duration: const Duration(milliseconds: 400),
                      child: GestureDetector(
                        onTap: () {
                          _bannerTimer?.cancel();
                          _bannerTimer = null;
                          ref.read(approvalsProvider.notifier).dismissNewData();
                          notifier.loadAll();
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.interactive.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.interactive),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications_active,
                                color: AppColors.interactive,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'New data available — tap to refresh',
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.interactive,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Section Selector
                  _buildSectionSelector(isDark, state, notifier),
                  const SizedBox(height: 24),

                  // Status Tabs
                  _buildStatusTabs(isDark, state, notifier),
                  const SizedBox(height: 20),

                  // Sort Bar (applications only)
                  if (state.selectedSection == 'applications') ...[
                    _buildApplicationSortBar(isDark, state, notifier),
                    const SizedBox(height: 12),
                  ],

                  // Content
                  Expanded(
                    child: state.selectedSection == 'applications'
                        ? (state.filteredApplications.isEmpty
                              ? RefreshIndicator(
                                  onRefresh: () => notifier.loadAll(),
                                  child: SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: SizedBox(
                                      height: 400,
                                      child: _emptyState(
                                        'applications',
                                        isDark,
                                      ),
                                    ),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: () => notifier.loadAll(),
                                  child: state.applicationsFilter == 'PENDING'
                                      ? ListView.separated(
                                          itemCount:
                                              state.filteredApplications.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 16),
                                          itemBuilder: (_, index) {
                                            final app = state
                                                .filteredApplications[index];
                                            return KeyedSubtree(
                                              key: ValueKey(app.applicationId),
                                              child: _buildApplicationCard(
                                                app,
                                                isDark,
                                                notifier,
                                              ),
                                            );
                                          },
                                        )
                                      : Builder(
                                          builder: (_) {
                                            final grouped =
                                                state.groupedApplications;
                                            final names = grouped.keys.toList();
                                            return ListView.separated(
                                              itemCount: names.length,
                                              separatorBuilder: (_, __) =>
                                                  const SizedBox(height: 16),
                                              itemBuilder: (_, index) {
                                                final name = names[index];
                                                final records = grouped[name]!;
                                                final profileImageUrl = records.first.profileImageUrl;
                                                return _buildGroupedApplicationCard(
                                                  name,
                                                  records,
                                                  isDark,
                                                  notifier,
                                                  profileImageUrl: profileImageUrl,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                ))
                        : (state.filteredTrainingHours.isEmpty
                              ? RefreshIndicator(
                                  onRefresh: () => notifier.loadAll(),
                                  child: SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: SizedBox(
                                      height: 400,
                                      child: _emptyState(
                                        'applications',
                                        isDark,
                                      ),
                                    ),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: () => notifier.loadAll(),
                                  child: Builder(
                                    builder: (_) {
                                      final grouped = state.groupedTraining;
                                      final names = grouped.keys.toList();
                                      return ListView.separated(
                                        itemCount: names.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 16),
                                        itemBuilder: (_, index) {
                                          final name = names[index];
                                          final records = grouped[name]!;
                                          return _buildGroupedTrainingCard(
                                            name,
                                            records,
                                            isDark,
                                            notifier,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedApplicationCard(
  String studentName,
  List<Application> records,
  bool isDark,
  ApprovalsNotifier notifier, {
  String? profileImageUrl,
}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
  radius: 24,
  backgroundImage: profileImageUrl != null &&
          profileImageUrl.isNotEmpty
      ? NetworkImage(profileImageUrl)
      : null,
  child: profileImageUrl == null ||
          profileImageUrl.isEmpty
      ? const Icon(Icons.person)
      : null,
),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(studentName, style: AppTextStyles.h3),
                  Text(
                    '${records.length} application${records.length > 1 ? 's' : ''}',
                    style: AppTextStyles.body.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          ...records.map((r) => _buildApplicationSubCard(r, isDark, notifier)),
        ],
      ),
    );
  }

  Widget _buildApplicationSubCard(
    Application record,
    bool isDark,
    ApprovalsNotifier notifier,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM dd, yyyy').format(record.submissionDate),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              _statusChip(record.status),
            ],
          ),
          const SizedBox(height: 8),
          _buildLabeledItem(
            Icons.badge,
            'College ID',
            record.collegeId,
            isDark,
          ),
          _buildLabeledItem(
            Icons.workspace_premium,
            'GPA',
            record.gpa?.toStringAsFixed(2) ?? 'N/A',
            isDark,
          ),
          if (record.expanded) ...[
            const Divider(height: 24),
            _buildLabeledItem(
              Icons.description,
              'Cover Letter',
              record.coverLetter ?? 'No cover letter',
              isDark,
            ),
            if (record.documentId != null)
              _buildLabeledLink(
                Icons.picture_as_pdf,
                'CV',
                'View CV',
                () => _openCV(record.documentId!),
                isDark,
              ),
            if (record.rejectionReason != null &&
                record.rejectionReason!.isNotEmpty)
              _buildLabeledItem(
                Icons.info_outline,
                'Rejection Reason',
                record.rejectionReason!,
                isDark,
              ),
          ],
          TextButton(
            onPressed: () =>
                notifier.toggleApplicationExpanded(record.applicationId),
            child: Text(
              record.expanded ? 'Show less' : 'Show more',
              style: TextStyle(color: AppColors.interactive),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg;
    Color text;

    switch (status.toUpperCase()) {
      case 'APPROVED':
        bg = AppColors.accentSuccess;
        text = AppColors.accentSuccessText;
        break;
      case 'REJECTED':
        bg = AppColors.accentAlert;
        text = AppColors.accentAlertText;
        break;
      case 'PENDING':
      default:
        bg = AppColors.accentInfo;
        text = AppColors.accentInfoText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg, // ✅ solid color (NOT transparent)
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: text,
        ),
      ),
    );
  }
  // ---------------- SECTION SELECTOR ----------------

  Widget _buildSectionSelector(bool isDark, state, notifier) {
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
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
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
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
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

    final currentFilter = state.selectedSection == 'applications'
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
        ? AppColors.accentInfo
        : record.status == 'APPROVED'
        ? AppColors.accentSuccess
        : AppColors.accentAlert;

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
              _statusChip(record.status),
            ],
          ),

          const SizedBox(height: 8),

          _buildLabeledItem(
            Icons.badge,
            'College ID',
            record.collegeId,
            isDark,
          ),
          _buildLabeledItem(
            Icons.workspace_premium,
            'GPA',
            record.gpa?.toStringAsFixed(2) ?? 'N/A',
            isDark,
          ),
          _buildLabeledItem(
            Icons.calendar_today,
            'Date Applied',
            DateFormat('MMM dd, yyyy').format(record.submissionDate),
            isDark,
          ),

          const SizedBox(height: 12),

          if (record.expanded) ...[
            const Divider(),
            _buildLabeledItem(
              Icons.description,
              'Cover Letter',
              record.coverLetter ?? 'No cover letter',
              isDark,
            ),
            if (record.documentId != null) ...[
              const SizedBox(height: 4),
              _buildLabeledLink(
                Icons.picture_as_pdf,
                'CV',
                'View CV',
                () => _openCV(record.documentId!),
                isDark,
              ),
            ],
          ],
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
          ],
        ],
      ),
    );
  }

  Future<void> downloadFile(String url) async {
    if (kIsWeb) {
      await downloadWeb(url); // comes from download_web.dart
    } else {
      final dir = await getApplicationDocumentsDirectory();

      final filePath =
          '${dir.path}/training_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Dio().download(url, filePath);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved to:\n$filePath')));
    }
  }

  Future<void> _openCV(String documentId) async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('document')
          .select('filepath')
          .eq('documentid', documentId)
          .single();

      final fileUrl = response['filepath']; // 👈 already FULL URL

      if (kIsWeb) {
        html.window.open(fileUrl, '_blank'); // ✅ open directly
      } else {
        await downloadFile(fileUrl);
      }
    } catch (e) {
      debugPrint('Error opening CV: $e');
    }
  }

  Future<void> _uploadCertificate(Training record) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    final file = result.files.single;
    final supabase = Supabase.instance.client;
    final path = 'certificates/${record.recordId}/${file.name}';

    // Upload to storage
    await supabase.storage.from('certificates').uploadBinary(path, file.bytes!);

    // Get public URL
    final url = supabase.storage.from('certificates').getPublicUrl(path);

    // Save URL to DB
    await supabase
        .from('trainingrecord')
        .update({'certificate_url': url})
        .eq('recordid', record.recordId);

    // Refresh UI
    ref.read(approvalsProvider.notifier).loadAll();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Certificate uploaded!')));
    }
  }

  // Helper: labeled row with icon + bold label + value
  Widget _buildLabeledItem(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          RichText(
            text: TextSpan(
              style: AppTextStyles.body.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedTrainingCard(
    String studentName,
    List<Training> records,
    bool isDark,
    ApprovalsNotifier notifier,
  ) {
    final profileImageUrl = records.isNotEmpty
      ? records.first.profileImageUrl
      : null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage:
                  profileImageUrl != null &&
                          profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : null,
              child:
                  profileImageUrl == null ||
                          profileImageUrl.isEmpty
                      ? const Icon(Icons.person)
                      : null,
            ),
            const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(studentName, style: AppTextStyles.h3),
                  Text(
                    '${records.length} record${records.length > 1 ? 's' : ''}',
                    style: AppTextStyles.body.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          ...records.map((r) => _buildSubCard(r, isDark, notifier)),
        ],
      ),
    );
  }

  Widget _buildSubCard(
    Training record,
    bool isDark,
    ApprovalsNotifier notifier,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${record.hoursSubmitted} hrs • ${record.companyName}',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              _statusChip(record.status),
            ],
          ),
          const SizedBox(height: 8),
          _buildLabeledItem(
            Icons.calendar_today,
            'Date Applied',
            DateFormat('MMM dd, yyyy').format(record.createdAt),
            isDark,
          ),
          if (record.expanded) ...[
            const Divider(height: 24),
            _buildLabeledItem(
              Icons.badge,
              'ID',
              record.collegeId ?? 'N/A',
              isDark,
            ),
            _buildLabeledItem(
              Icons.supervisor_account,
              'Supervisor',
              record.supervisorName,
              isDark,
            ),
            _buildLabeledItem(
              Icons.date_range,
              'Duration',
              '${DateFormat.yMMMd().format(record.startDate)} → ${DateFormat.yMMMd().format(record.endDate)}',
              isDark,
            ),
            if (record.proofImageUrl != null &&
                record.proofImageUrl!.isNotEmpty)
              _buildLabeledLink(
                Icons.image,
                'Proof',
                'View',
                () => html.window.open(record.proofImageUrl!, '_blank'),
                isDark,
              ),
            if (record.certificateUrl != null &&
                record.certificateUrl!.isNotEmpty)
              _buildLabeledLink(
                Icons.workspace_premium,
                'Certificate',
                'View',
                () => html.window.open(record.certificateUrl!, '_blank'),
                isDark,
              ),
          ],
          TextButton(
            onPressed: () => notifier.toggleTrainingExpanded(record.recordId),
            child: Text(
              record.expanded ? 'Show less' : 'Show more',
              style: TextStyle(color: AppColors.interactive),
            ),
          ),
          if (record.status == 'PENDING') ...[
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

  // Helper: labeled clickable link row
  Widget _buildLabeledLink(
    IconData icon,
    String label,
    String linkText,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.interactive),
        const SizedBox(width: 12),
        RichText(
          text: TextSpan(
            style: AppTextStyles.body,
            children: [
              TextSpan(
                text: '$label: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: TextStyle(
              color: AppColors.interactive,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String value, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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

  Widget _buildApplicationSortBar(
    bool isDark,
    ApprovalsState state,
    ApprovalsNotifier notifier,
  ) {
    return Row(
      children: [
        Icon(
          Icons.sort,
          size: 18,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          'Sort by:',
          style: AppTextStyles.label.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _sortChip(
                  'Date ↑',
                  ApplicationSortOption.dateAsc,
                  state,
                  notifier,
                  isDark,
                ),
                const SizedBox(width: 8),
                _sortChip(
                  'Date ↓',
                  ApplicationSortOption.dateDesc,
                  state,
                  notifier,
                  isDark,
                ),
                const SizedBox(width: 8),
                _sortChip(
                  'GPA ↑',
                  ApplicationSortOption.gpaAsc,
                  state,
                  notifier,
                  isDark,
                ),
                const SizedBox(width: 8),
                _sortChip(
                  'GPA ↓',
                  ApplicationSortOption.gpaDesc,
                  state,
                  notifier,
                  isDark,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sortChip(
    String label,
    ApplicationSortOption option,
    ApprovalsState state,
    ApprovalsNotifier notifier,
    bool isDark,
  ) {
    final selected = state.applicationSort == option;
    return GestureDetector(
      onTap: () => notifier.updateApplicationSort(
        selected ? ApplicationSortOption.none : option,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.interactive.withOpacity(0.15)
              : (isDark ? AppColors.darkCard : AppColors.card),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.interactive
                : (isDark ? AppColors.darkDivider : AppColors.border),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: selected
                ? AppColors.interactive
                : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary),
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String section, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            section == 'applications' ? Icons.description : Icons.access_time,
            size: 64,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No ${section == 'applications' ? 'applications' : 'training hours'} found',
            style: AppTextStyles.h3.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All ${section == 'applications' ? 'applications' : 'training hours'} in this status will appear here',
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
