import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import '../../constants/app_colors.dart';
import '../../services/user_session.dart';
import '../../services/vacancy_service.dart';
import '../../widgets/app_bar_with_logout.dart';
import '../../widgets/cancellation_confirmation_dialog.dart';
import '../../widgets/rounded_container.dart';
import '../../widgets/tracking_status_chip.dart';

class FreshGradTrackingScreen extends StatefulWidget {
  final String initialStatusFilter;

  const FreshGradTrackingScreen({
    super.key,
    this.initialStatusFilter = 'All',
  });

  @override
  State<FreshGradTrackingScreen> createState() =>
      _FreshGradTrackingScreenState();
}

class _FreshGradTrackingScreenState extends State<FreshGradTrackingScreen> {
  String _selectedStatus = 'All';
  bool _isLoading = true;
  String? _error;

  final VacancyService _vacancyService = VacancyService();
  List<Map<String, dynamic>> _applications = [];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatusFilter;
    _fetchTrackingData();
  }

  Future<void> _fetchTrackingData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = UserSession.instance.userId;
      if (userId == null) {
        throw Exception('No logged-in user found');
      }

      final applications = await _vacancyService.getUserApplications(userId);

      if (!mounted) return;

      setState(() {
        _applications = List<Map<String, dynamic>>.from(applications);
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

  String _normalizeStatus(dynamic status) {
    return (status?.toString().toUpperCase() ?? 'PENDING');
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

  int _countByStatus(List<Map<String, dynamic>> source, String status) {
    return source
        .where((item) => _normalizeStatus(item['status']) == status)
        .length;
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

  bool _canCancelApplication(Map<String, dynamic> application) {
    final status = _normalizeStatus(application['status']);
    if (status != 'PENDING') return false;

    final submissionDate = _readDate(application['submissiondate']);
    if (submissionDate == null) return false;

    final hoursSinceSubmission = DateTime.now().difference(submissionDate).inHours;
    return hoursSinceSubmission <= 24;
  }

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

  void _showTimelineSheet({
    required String title,
    required String subtitle,
    required String status,
    required DateTime? submittedAt,
    required String? rejectionReason,
  }) {
    final phases = _buildPhases(
      status: status,
      submittedAt: submittedAt,
      rejectionReason: rejectionReason,
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
  }) {
    final normalized = status.toUpperCase();

    final submitted = _TimelinePhase(
      title: 'Application Submitted',
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

  Widget _buildSummaryCard() {
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
    const statuses = ['All', 'Pending', 'Approved', 'Rejected', 'Canceled'];

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
                    'Track your applications in one place',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  _buildSummaryCard(),
                  const SizedBox(height: 15),
                  _buildStatusFilters(),
                  const SizedBox(height: 10),
                  ..._buildApplicationCards(_filteredApplications),
                ],
              ),
            ),
    );
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
