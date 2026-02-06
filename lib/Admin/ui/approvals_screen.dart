import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/training_submission.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'theme_provider.dart';
import 'package:provider/provider.dart';


class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  String _filter = 'pending';
  late List<TrainingSubmission> _approvals;

  @override
  void initState() {
    super.initState();
    _approvals = List.from(_mockApprovals);
  }

  void _approve(String id) {
    setState(() {
      _approvals.firstWhere((a) => a.id == id).status = 'approved';
    });
  }

  void _reject(String id) {
    setState(() {
      _approvals.firstWhere((a) => a.id == id).status = 'rejected';
    });
  }

  List<TrainingSubmission> get _filteredApprovals {
    if (_filter == 'all') return _approvals;
    return _approvals.where((a) => a.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
        elevation: 0,
        title: Text(
          'Training Hours Approval',
          style: AppTextStyles.h1.copyWith(
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode_outlined,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabs(isDark),
            const SizedBox(height: 20),
            Expanded(
              child: _filteredApprovals.isEmpty
                  ? _emptyState(isDark)
                  : ListView.separated(
                      itemCount: _filteredApprovals.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 16),
                      itemBuilder: (_, index) =>
                          _buildApprovalCard(
                              _filteredApprovals[index], isDark),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- TABS ----------------

  Widget _buildTabs(bool isDark) {
    return Row(
      children: ['All', 'Pending', 'Approved', 'Rejected']
          .map((tab) => Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _filter = tab.toLowerCase()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _filter == tab.toLowerCase()
                          ? AppColors.interactive.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(AppColors.radius),
                    ),
                    child: Text(
                      tab,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _filter == tab.toLowerCase()
                            ? AppColors.interactive
                            : isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  // ---------------- CARD ----------------

  Widget _buildApprovalCard(
  TrainingSubmission approval,
  bool isDark,
) {
  final Color statusColor = approval.status == 'pending'
      ? const Color(0xFFFFC107)
      : approval.status == 'approved'
          ? const Color(0xFF4CAF50)
          : const Color(0xFFD32F2F);

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : AppColors.card,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ───── HEADER ─────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              approval.studentName,
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                approval.status,
                style: AppTextStyles.label.copyWith(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        /// Company • Duration
        Text(
          '${approval.company} • ${approval.duration}',
          style: AppTextStyles.body.copyWith(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 20),

        /// ───── DETAILS GRID ─────
        Row(
          children: [
            _infoColumn(
              title: 'Training Hours',
              value: '${approval.hours} hours',
              isDark: isDark,
            ),
            _infoColumn(
              title: 'Supervisor',
              value: approval.supervisor,
              isDark: isDark,
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            _infoColumn(
              title: 'Submitted',
              value: DateFormat('MMM d')
                  .format(approval.submittedDate),
              isDark: isDark,
            ),
            _certificateColumn(isDark),
          ],
        ),

        const SizedBox(height: 20),

        Divider(
          color: isDark
              ? AppColors.darkDivider
              : AppColors.divider,
        ),

        const SizedBox(height: 16),

        /// ───── ACTIONS ─────
        if (approval.status == 'pending')
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approve(approval.id),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E9B63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _reject(approval.id),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD93025),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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
Widget _infoColumn({
  required String title,
  required String value,
  required bool isDark,
}) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}

Widget _certificateColumn(bool isDark) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certificate',
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.description,
              size: 16,
              color: AppColors.interactive,
            ),
            const SizedBox(width: 6),
            Text(
              'View',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.interactive,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  // ---------------- HELPERS ----------------

  Widget _detailItem(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.interactive),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTextStyles.body.copyWith(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _emptyState(bool isDark) {
    return Center(
      child: Text(
        'No approvals found',
        style: AppTextStyles.body.copyWith(
          color:
              isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ---------------- MOCK DATA ----------------

final List<TrainingSubmission> _mockApprovals = [
  TrainingSubmission(
    id: '1',
    studentName: 'John Doe',
    company: 'Tech Corp',
    duration: '3 months',
    hours: 120,
    supervisor: 'Dr. Ahmed Mohamed',
    submittedDate: DateTime(2024, 1, 15),
    status: 'pending',
  ),
  TrainingSubmission(
    id: '2',
    studentName: 'Jane Smith',
    company: 'Data Institute',
    duration: '2 months',
    hours: 80,
    supervisor: 'Prof. Sarah Johnson',
    submittedDate: DateTime(2024, 1, 14),
    status: 'approved',
  ),
  TrainingSubmission(
    id: '3',
    studentName: 'Mike Johnson',
    company: 'StartupXYZ',
    duration: '4 months',
    hours: 160,
    supervisor: 'Eng. Mahmoud Ali',
    submittedDate: DateTime(2024, 1, 13),
    status: 'rejected',
  ),
];
