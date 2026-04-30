import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import '../../widgets/app_bar_with_logout.dart';
import '../../widgets/rounded_container.dart';
import '../../widgets/tracking_status_chip.dart';
import '../../widgets/profile_widgets/student_profile_submit_hours_modal.dart';
import '../../widgets/cancellation_confirmation_dialog.dart';
import '../../services/vacancy_service.dart';
import '../../constants/app_colors.dart';

class StudentTrackingScreen extends StatefulWidget {
  final int initialTabIndex;
  final String initialStatusFilter;

  const StudentTrackingScreen({
    super.key,
    this.initialTabIndex = 0,
    this.initialStatusFilter = 'All',
  });

  @override
  State<StudentTrackingScreen> createState() => _StudentTrackingScreenState();
}

class _StudentTrackingScreenState extends State<StudentTrackingScreen> {
  static const int _fallbackStudentId =
      5; // this is just for tetsing, replace with actual student ID from auth/session

  int _selectedTab = 0; // 0 = Applications, 1 = Training Hours
  String _selectedStatus = 'All';
  bool _isLoading = true;
  String? _error;

  final VacancyService _vacancyService = VacancyService();

  double _completedHours = 0;
  double _requiredHours = 0;

  List<Map<String, dynamic>> _applications = [];
  List<Map<String, dynamic>> _trainingRecords = [];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex.clamp(0, 1);
    _selectedStatus = widget.initialStatusFilter;
    _fetchTrackingData();
  }

  Future<void> _fetchTrackingData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final studentId = _fallbackStudentId;

      final studentData = await supabase
          .from('student')
          .select('completedtraininghours, requiredtraininghours')
          .eq('studentid', studentId)
          .single();

      final applications = await supabase
          .from('application')
          .select('''
            *,
            vacancy:vacancyid(title, company_name, type, location)
          ''')
          .eq('applicantid', studentId)
          .order('submissiondate', ascending: false);

      final trainingRecords = await supabase
          .from('trainingrecord')
          .select()
          .eq('studentid', studentId)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _completedHours = (studentData['completedtraininghours'] ?? 0)
            .toDouble();
        _requiredHours = (studentData['requiredtraininghours'] ?? 0).toDouble();
        _applications = List<Map<String, dynamic>>.from(applications);
        _trainingRecords = List<Map<String, dynamic>>.from(trainingRecords);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load tracking data: $e';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredApplications {
    if (_selectedStatus == 'All') return _applications;
    return _applications
        .where(
          (item) =>
              _normalizeStatus(item['status']) == _selectedStatus.toUpperCase(),
        )
        .toList();
  }

  List<Map<String, dynamic>> get _filteredTrainingRecords {
    if (_selectedStatus == 'All') return _trainingRecords;
    return _trainingRecords
        .where(
          (item) =>
              _normalizeStatus(item['status']) == _selectedStatus.toUpperCase(),
        )
        .toList();
  }

  String _normalizeStatus(dynamic status) {
    return (status?.toString().toUpperCase() ?? 'PENDING');
  }

  int _countByStatus(List<Map<String, dynamic>> source, String status) {
    return source
        .where((item) => _normalizeStatus(item['status']) == status)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBarWithLogout(
        title: 'AAST Connect',
        additionalActions: [
          IconButton(
            tooltip: 'Refresh tracking',
            onPressed: _fetchTrackingData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : RefreshIndicator(
              onRefresh: _fetchTrackingData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'My Tracking',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge?.copyWith(fontSize: 28),
                  ),
                  Text(
                    'Track applications and training hours in one place',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  _buildToggle(),
                  const SizedBox(height: 15),
                  _buildSummaryCard(),
                  const SizedBox(height: 15),
                  _buildStatusFilters(),
                  const SizedBox(height: 10),
                  ...(_selectedTab == 0
                      ? _buildApplicationCards(_filteredApplications)
                      : _buildTrainingCards(_filteredTrainingRecords)),
                  if (_selectedTab == 1) ...[const SizedBox(height: 80)],
                ],
              ),
            ),
      floatingActionButton: _selectedTab == 1
          ? FloatingActionButton.extended(
              onPressed: () => StudentProfileSubmitHoursModal.show(
                context,
                studentId: _fallbackStudentId,
                onSubmitted: _fetchTrackingData,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Submit Hours'),
            )
          : null,
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(_error ?? 'Unexpected error'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchTrackingData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return RoundedContainer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      borderColor: Theme.of(context).dividerColor,
      borderRadius: 14,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: 'Applications',
              selected: _selectedTab == 0,
              onTap: () {
                setState(() {
                  _selectedTab = 0;
                  _selectedStatus = 'All';
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildToggleButton(
              label: 'Training Hours',
              selected: _selectedTab == 1,
              onTap: () {
                setState(() {
                  _selectedTab = 1;
                  _selectedStatus = 'All';
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.toggleSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected
                ? AppColors.lightPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (_selectedTab == 0) {
      final total = _applications.length;
      return RoundedContainer(
        backgroundColor: AppColors.toggleSelected,
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Applications Overview',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text('Total: $total'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _miniCounter(
                  'Approved',
                  _countByStatus(_applications, 'APPROVED'),
                  AppColors.approved,
                ),
                _miniCounter(
                  'Pending',
                  _countByStatus(_applications, 'PENDING'),
                  AppColors.pending,
                ),
                _miniCounter(
                  'Rejected',
                  _countByStatus(_applications, 'REJECTED'),
                  AppColors.rejected,
                ),
                _miniCounter(
                  'Canceled',
                  _countByStatus(_applications, 'CANCELED'),
                  AppColors.canceled,
                ),
              ],
            ),
          ],
        ),
      );
    }

    final safeRequired = _requiredHours <= 0 ? 1 : _requiredHours;
    final progress = (_completedHours / safeRequired).clamp(0.0, 1.0);
    final remaining = (_requiredHours - _completedHours).clamp(
      0,
      double.infinity,
    );

    return RoundedContainer(
      backgroundColor: AppColors.trainingProgress,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Training Hours Progress',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${_completedHours.toStringAsFixed(0)} / ${_requiredHours.toStringAsFixed(0)} hrs',
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: Colors.white,
            color: AppColors.progressGreen,
          ),
          const SizedBox(height: 8),
          Text('${remaining.toStringAsFixed(0)} hours remaining'),
        ],
      ),
    );
  }

  Widget _miniCounter(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStatusFilters() {
    final statuses = _selectedTab == 0
        ? const ['All', 'Pending', 'Approved', 'Rejected', 'Canceled']
        : const ['All', 'Pending', 'Approved', 'Rejected'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses
          .map(
            (status) => ChoiceChip(
              label: Text(status),
              selected: _selectedStatus == status,
              onSelected: (_) => setState(() => _selectedStatus = status),
            ),
          )
          .toList(),
    );
  }

  List<Widget> _buildApplicationCards(List<Map<String, dynamic>> records) {
    if (records.isEmpty) {
      return [
        const SizedBox(height: 30),
        const Center(child: Text('No applications found for this filter.')),
      ];
    }

    return records.map((record) {
      final vacancy = (record['vacancy'] as Map<String, dynamic>?) ?? {};
      final status = _normalizeStatus(record['status']);
      final appliedDate = _readDate(record['submissiondate']);

      return RoundedContainer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).dividerColor,
        borderRadius: 16,
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vacancy['title']?.toString() ?? 'Untitled Application',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vacancy['company_name']?.toString() ??
                            'Unknown Company',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Applied: ${_formatDate(appliedDate)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                TrackingStatusChip(status: status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_canCancelApplication(record))
                  TextButton.icon(
                    onPressed: () => _cancelApplication(record),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.rejected,
                    ),
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showTimelineSheet(
                    title:
                        vacancy['title']?.toString() ?? 'Application Timeline',
                    subtitle:
                        vacancy['company_name']?.toString() ?? 'Application',
                    status: status,
                    submittedAt: appliedDate,
                    rejectionReason: record['rejectionreason']?.toString(),
                    isTraining: false,
                  ),
                  icon: const Icon(Icons.timeline),
                  label: const Text('View Timeline'),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildTrainingCards(List<Map<String, dynamic>> records) {
    if (records.isEmpty) {
      return [
        const SizedBox(height: 30),
        const Center(child: Text('No training records found for this filter.')),
      ];
    }

    return records.map((record) {
      final status = _normalizeStatus(record['status']);
      final submittedAt =
          _readDate(record['created_at']) ??
          _readDate(record['submissiondate']);
      final startDate = _readDate(record['startdate']);
      final endDate = _readDate(record['enddate']);

      return RoundedContainer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).dividerColor,
        borderRadius: 16,
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record['companyname']?.toString() ?? 'Unknown Company',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hours: ${record['hourssubmitted'] ?? 0}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Range: ${_formatDate(startDate)} - ${_formatDate(endDate)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                TrackingStatusChip(status: status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_canCancelTrainingRecord(record))
                  TextButton.icon(
                    onPressed: () => _cancelTrainingRecord(record),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.rejected,
                    ),
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showTimelineSheet(
                    title:
                        record['companyname']?.toString() ??
                        'Training Timeline',
                    subtitle:
                        '${record['hourssubmitted'] ?? 0} hours submitted',
                    status: status,
                    submittedAt: submittedAt,
                    rejectionReason: record['rejectionreason']?.toString(),
                    isTraining: true,
                  ),
                  icon: const Icon(Icons.timeline),
                  label: const Text('View Timeline'),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  // Check if application can be canceled (within 24 hours and pending)
  bool _canCancelApplication(Map<String, dynamic> application) {
    final status = _normalizeStatus(application['status']);
    if (status != 'PENDING') return false;

    final submissionDate = _readDate(application['submissiondate']);
    if (submissionDate == null) return false;

    final hoursSinceSubmission = DateTime.now()
        .difference(submissionDate)
        .inHours;
    return hoursSinceSubmission <= 24;
  }

  // Check if training record can be canceled (pending status only)
  bool _canCancelTrainingRecord(Map<String, dynamic> trainingRecord) {
    final status = _normalizeStatus(trainingRecord['status']);
    return status == 'PENDING';
  }

  // Cancel application with confirmation
  Future<void> _cancelApplication(Map<String, dynamic> application) async {
    final vacancy = application['vacancy'] as Map<String, dynamic>? ?? {};

    CancellationConfirmationDialog.showApplicationCancellation(
      context,
      jobTitle: vacancy['title']?.toString() ?? 'Untitled Application',
      companyName: vacancy['company_name']?.toString() ?? 'Unknown Company',
      onConfirm: () async {
        try {
          await _vacancyService.cancelApplication(application['applicationid']);
          await _fetchTrackingData();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Success',
                  message: 'Application canceled successfully',
                  contentType: ContentType.success,
                ),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Error',
                  message: 'Failed to cancel application: $e',
                  contentType: ContentType.failure,
                ),
              ),
            );
          }
        }
      },
    );
  }

  // Cancel training record with confirmation
  Future<void> _cancelTrainingRecord(
    Map<String, dynamic> trainingRecord,
  ) async {
    CancellationConfirmationDialog.showTrainingCancellation(
      context,
      companyName:
          trainingRecord['companyname']?.toString() ?? 'Unknown Company',
      hours: trainingRecord['hourssubmitted'] ?? 0,
      onConfirm: () async {
        try {
          await _vacancyService.cancelTrainingRecord(
            trainingRecord['recordid'],
          );
          await _fetchTrackingData();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Success',
                  message: 'Training submission canceled successfully',
                  contentType: ContentType.success,
                ),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Error',
                  message: 'Failed to cancel training submission: $e',
                  contentType: ContentType.failure,
                ),
              ),
            );
          }
        }
      },
    );
  }

  void _showTimelineSheet({
    required String title,
    required String subtitle,
    required String status,
    required DateTime? submittedAt,
    required String? rejectionReason,
    required bool isTraining,
  }) {
    final phases = _buildPhases(
      status: status,
      submittedAt: submittedAt,
      rejectionReason: rejectionReason,
      isTraining: isTraining,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            _buildTimelinePhases(phases),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelinePhases(List<_TimelinePhase> phases) {
    return Column(
      children: List.generate(phases.length, (index) {
        final phase = phases[index];
        final hasNext = index < phases.length - 1;
        final next = hasNext ? phases[index + 1] : null;
        final connectorColor = (phase.isReached && (next?.isReached ?? false))
            ? (next?.color ?? Colors.grey.shade300)
            : Colors.grey.shade300;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 34,
              child: Column(
                children: [
                  Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: phase.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(phase.icon, color: Colors.white, size: 16),
                  ),
                  if (hasNext)
                    Container(
                      width: 3,
                      height: 38,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: connectorColor,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: hasNext ? 14 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phase.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: phase.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phase.subtitle,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  List<_TimelinePhase> _buildPhases({
    required String status,
    required DateTime? submittedAt,
    required String? rejectionReason,
    required bool isTraining,
  }) {
    final normalized = status.toUpperCase();
    final submittedLabel = isTraining
        ? 'Training Submitted'
        : 'Application Submitted';

    final submitted = _TimelinePhase(
      title: submittedLabel,
      subtitle: submittedAt == null
          ? 'Submission date unavailable'
          : _formatDate(submittedAt),
      color: AppColors.pending,
      icon: Icons.upload_file,
      isReached: true,
    );

    if (normalized == 'PENDING') {
      return [
        submitted,
        const _TimelinePhase(
          title: 'Under Review',
          subtitle: 'Waiting for admin decision',
          color: AppColors.pending,
          icon: Icons.hourglass_top,
          isReached: true,
        ),
        _TimelinePhase(
          title: 'Final Decision',
          subtitle: 'Not reached yet',
          color: Colors.grey.shade400,
          icon: Icons.flag,
          isReached: false,
        ),
      ];
    }

    if (normalized == 'REJECTED') {
      return [
        submitted,
        const _TimelinePhase(
          title: 'Under Review',
          subtitle: 'Checked by admin',
          color: AppColors.pending,
          icon: Icons.fact_check,
          isReached: true,
        ),
        _TimelinePhase(
          title: 'Rejected',
          subtitle: rejectionReason?.isNotEmpty == true
              ? rejectionReason!
              : 'Submission was rejected',
          color: AppColors.rejected,
          icon: Icons.cancel,
          isReached: true,
        ),
      ];
    }

    if (normalized == 'CANCELED') {
      return [
        submitted,
        const _TimelinePhase(
          title: 'Canceled',
          subtitle: 'You canceled this submission',
          color: AppColors.canceled,
          icon: Icons.do_not_disturb_alt,
          isReached: true,
        ),
      ];
    }

    return [
      submitted,
      const _TimelinePhase(
        title: 'Under Review',
        subtitle: 'Reviewed by admin',
        color: AppColors.pending,
        icon: Icons.fact_check,
        isReached: true,
      ),
      const _TimelinePhase(
        title: 'Approved',
        subtitle: 'Accepted by admin',
        color: AppColors.approved,
        icon: Icons.check_circle,
        isReached: true,
      ),
      const _TimelinePhase(
        title: 'Completed',
        subtitle: 'Tracking reached final phase',
        color: AppColors.approved,
        icon: Icons.flag,
        isReached: true,
      ),
    ];
  }
}

class _TimelinePhase {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final bool isReached;

  const _TimelinePhase({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.isReached,
  });
}
