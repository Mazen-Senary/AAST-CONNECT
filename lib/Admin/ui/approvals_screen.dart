import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/training_record.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/application_record.dart';


class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  String _selectedSection = 'applications'; // 'applications' or 'training'
  String _applicationsFilter = 'PENDING'; 
  String _trainingFilter = 'PENDING'; 
  late List<ApplicationRecord> _applications = [];

  //List<TrainingRecord> _applications = [];
  late List<TrainingRecord> _trainingRecords = [];
  final supabase = Supabase.instance.client;
  
  @override
void initState() {
  super.initState();
  _loadTrainingRecords();
  _loadApplications();
}

bool _loadingTraining = true;
Future<void> _loadTrainingRecords() async {
  final data = await fetchTrainingRecords();
  
  setState(() {
    _trainingRecords = data;
    _loadingTraining = false;
  });
}
Future<void> _loadApplications() async {
  final data = await fetchApplications();

  debugPrint('APPLICATION COUNT = ${data.length}');
  for (final a in data) {
    debugPrint(
      'APP ${a.applicationId} | ${a.status} | ${a.studentName} | ${a.collegeId}',
    );
  }

  setState(() {
    _applications = data;
  });
}


Future<List<ApplicationRecord>> fetchApplications() async {
  final response = await supabase
      .from('application')
      .select('''
        applicationid,
        status,
        submissiondate,
        applicant_name,
        college_id,
        coverletter,
        rejectionreason
      ''');


  return response
      .map<ApplicationRecord>((row) => ApplicationRecord.fromMap(row))
      .toList();
}
List<ApplicationRecord> get _filteredApplications {
  if (_applications.isEmpty) return [];
  return _applications
      .where((a) => a.status == _applicationsFilter)
      .toList();
}

List<TrainingRecord> get _filteredTrainingHours {
  final filtered = _trainingRecords
      .where((t) => t.status == _trainingFilter)
      .toList();
  
  // Debug: Print filtering info
  print('Filter: "$_trainingFilter"');
  print('Total records: ${_trainingRecords.length}');
  print('Filtered records: ${filtered.length}');
  for (var record in _trainingRecords) {
    print('  Record: "${record.status}" -> matches: ${record.status == _trainingFilter}');
  }
  
  return filtered;
}
  Future<List<TrainingRecord>> fetchTrainingRecords() async {
  final response = await supabase
      .from('trainingrecord')
      .select('''
        recordid,
        studentid,
        companyname,
        supervisorname,
        hourssubmitted,
        startdate,
        enddate,
        status,
        created_at,
        proof_image_url,
        student:studentid ( name )
      ''');

  return response.map<TrainingRecord>((row) {
    return TrainingRecord.fromMap({
      ...row,
      'studentname': row['student']['name'],
    });
  }).toList();
}
Future<void> _approveTraining(TrainingRecord record) async {
  print('Approving training record: ${record.recordId}');
  
  try {
    await supabase
        .from('trainingrecord')
        .update({'status': 'accepted'})
        .eq('recordid', record.recordId);

    print('Database update successful');

    setState(() {
      _trainingRecords = _trainingRecords.map((r) {
        if (r.recordId == record.recordId) {
          print('Updating local state for record ${r.recordId} to APPROVED');
          return r.copyWith(status: 'APPROVED');
        }
        return r;
      }).toList();
    });
    
    print('Local state update complete');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Training record APPROVED!')),
    );
  } catch (e) {
    print('Error approving training: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}


Future<void> _rejectTraining(TrainingRecord record) async {
  print('Rejecting training record: ${record.recordId}');
  
  try {
    await supabase
        .from('trainingrecord')
        .update({'status': 'REJECTED'})
        .eq('recordid', record.recordId);

    print('Database update successful');

    setState(() {
      _trainingRecords = _trainingRecords.map((r) {
        if (r.recordId == record.recordId) {
          print('Updating local state for record ${r.recordId} to rejected');
          return r.copyWith(status: 'REJECTED');
        }
        return r;
      }).toList();
    });
    
    print('Local state update complete');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Training record rejected!')),
    );
  } catch (e) {
    print('Error rejecting training: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
Future<void> _approveApplication(ApplicationRecord record) async {
  await supabase
      .from('application')
      .update({'status': 'ACCEPTED'})
      .eq('applicationid', record.applicationId);

  setState(() {
    _applications = _applications.map<ApplicationRecord>((a) {
      if (a.applicationId == record.applicationId) {
        return a.copyWith(status: 'ACCEPTED');
      }
      return a;
    }).toList();
  });
}
Future<void> _rejectApplication(
  ApplicationRecord record,
  String? reason,
) async {
  await supabase
      .from('application')
      .update({
        'status': 'REJECTED',
        'rejection_reason': reason,
      })
      .eq('applicationid', record.applicationId);

  setState(() {
    _applications = _applications.map<ApplicationRecord>((a) {
      if (a.applicationId == record.applicationId) {
        return a.copyWith(
          status: 'REJECTED',
          rejectionReason: reason,
        );
      }
      return a;
    }).toList();
  });
}

Future<void> _showRejectDialog(ApplicationRecord record) async {
  final controller = TextEditingController();
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final isDark = themeProvider.isDarkMode;

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
                Container(
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
                    onPressed: () => Navigator.pop(context),
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
                      await _rejectApplication(
                        record,
                        controller.text.trim(),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Reject Application',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
        elevation: 0,
        title: Text(
          'AAST Connect',
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
            _buildSectionSelector(isDark),
            const SizedBox(height: 24),
            
            // Status Tabs
            _buildStatusTabs(isDark),
            const SizedBox(height: 20),
            
            // Content
            Expanded(
              child: _selectedSection == 'applications'
                  ? (_filteredApplications.isEmpty
                      ? _emptyState('applications', isDark)
                      : ListView.separated(
                          itemCount: _filteredApplications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (_, index) => _buildApplicationCard(
                            _filteredApplications[index],
                            isDark,
                          ),
                        ))
                  : (_filteredTrainingHours.isEmpty
                      ? _emptyState('training', isDark)
                      : ListView.separated(
                          itemCount: _filteredTrainingHours.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (_, index) =>
                            _buildTrainingCard(_filteredTrainingHours[index], isDark),

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

  Widget _buildSectionSelector(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
            setState(() {
              _selectedSection = 'applications';
              _applicationsFilter = 'PENDING'; // force refilter
            });
          },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _selectedSection == 'applications'
                    ? AppColors.interactive.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppColors.radius),
                border: Border.all(
                  color: _selectedSection == 'applications'
                      ? AppColors.interactive
                      : (isDark ? AppColors.darkDivider : AppColors.border),
                ),
              ),
              child: Text(
                'Applications',
                textAlign: TextAlign.center,
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _selectedSection == 'applications'
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
            onTap: () => setState(() => _selectedSection = 'training'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _selectedSection == 'training'
                    ? AppColors.interactive.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppColors.radius),
                border: Border.all(
                  color: _selectedSection == 'training'
                      ? AppColors.interactive
                      : (isDark ? AppColors.darkDivider : AppColors.border),
                ),
              ),
              child: Text(
                'Training Hours',
                textAlign: TextAlign.center,
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _selectedSection == 'training'
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

  Widget _buildStatusTabs(bool isDark) {
  final tabs = ['PENDING', 'ACCEPTED', 'REJECTED'];

  final currentFilter =
      _selectedSection == 'applications'
          ? _applicationsFilter
          : _trainingFilter;

  return Row(
    children: tabs.map((tab) {
      final bool selected = currentFilter == tab;

      return Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (_selectedSection == 'applications') {
                _applicationsFilter = tab; // APPLICATIONS ONLY
              } else {
                _trainingFilter = tab; // training untouched
              }
            });
          },
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

  Widget _buildApprovalCard(
    TrainingRecord approval,
    bool isDark,
    String section,
  ) {
    final Color statusColor = approval.status == 'PENDING'
        ? const Color(0xFFFFC107)
        : approval.status == 'APPROVED'
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  approval.status.toUpperCase(),
                  style: AppTextStyles.label.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          /// ───── DETAILS ─────
          Column(
            children: [
              _buildDetailItem(
                section == 'applications' ? Icons.business : Icons.access_time,
                section == 'applications' 
                    ? approval.companyName 
                    : '${approval.hoursSubmitted} hours',
                isDark,
              ),
              const SizedBox(height: 12),
              _buildDetailItem(
                section == 'applications' ? Icons.person : Icons.supervisor_account,
                section == 'applications' 
                    ? 'Application ID: ${approval.recordId}'
                    : approval.supervisorName,
                isDark,
              ),
              const SizedBox(height: 12),
              _buildDetailItem(
                Icons.calendar_today,
                DateFormat('MMM dd, yyyy').format(approval.createdAt),
                isDark,
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// ───── ACTIONS ─────
          if (approval.status == 'PENDING'&& section == 'applications')
  Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => _rejectTraining(approval),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Reject'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          onPressed: () => _approveTraining(approval),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.interactive,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Accept'),
        ),
      ),
    ],
  ),

        ],
      ),
    );
  }
  Widget _buildApplicationCard(
  ApplicationRecord record,
  bool isDark,
) {
  final statusColor = record.status == 'PENDING'
      ? Colors.orange
      : record.status == 'ACCEPTED'
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
            setState(() {
              _applications = _applications.map<ApplicationRecord>((a) {
                if (a.applicationId == record.applicationId) {
                  return a.copyWith(expanded: !a.expanded);
                }
                return a;
              }).toList();
            });
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
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _approveApplication(record),
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


  Future<void> _downloadImage(String imageUrl) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/training_proof_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await Dio().download(imageUrl, filePath);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image downloaded to:\n$filePath')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to download image')),
    );
  }
}

  void _openImagePreview(BuildContext context, String imageUrl) {
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
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () => _downloadImage(imageUrl),
              child: const Icon(Icons.download, color: Colors.black),
            ),
          ),
        ],
      ),
    ),
  );
}

 Widget _buildTrainingCard(TrainingRecord record, bool isDark) {
  // Debug: Print status to see what we're getting from DB
  print('Training Record Status: "${record.status}" (Filter: "$_trainingFilter")');
  
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
              onTap: () =>
                  _openImagePreview(context, record.proofImageUrl!),
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
            setState(() {
  _trainingRecords = _trainingRecords.map((r) {
    if (r.recordId == record.recordId) {
      return r.copyWith(expanded: !r.expanded);
    }
    return r;
  }).toList();
});

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
                  onPressed: () => _rejectTraining(record),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _approveTraining(record),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.interactive,
                    foregroundColor: Colors.white,
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
