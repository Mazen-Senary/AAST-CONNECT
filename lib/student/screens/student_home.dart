// new code for the home page stateful
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../../constants/app_colors.dart';

import '../../widgets/app_bar_with_logout.dart';
import '../../widgets/home_widgets/student_home_deadline_card.dart';
import '../../widgets/home_widgets/student_home_program_card.dart';
import '../../widgets/home_widgets/student_home_progress_card.dart';
import '../../widgets/home_widgets/student_home_section_header.dart';
import '../../widgets/home_widgets/student_home_stat_card.dart';
import '../../widgets/opportunities_wigdet/student_opportunities_apply_modal.dart';
import '../../widgets/opportunities_wigdet/student_opportunities_details_modal.dart';
import '../../services/vacancy_service.dart';
import '../../services/user_session.dart';
import 'student_tracking.dart';
import 'student_notifications.dart';

class StudentHome extends StatefulWidget {
  final VoidCallback onSeeAll;
  final int unreadNotificationCount;
  const StudentHome({
    super.key, 
    required this.onSeeAll,
    this.unreadNotificationCount = 0,
  });
  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  String _studentName = '';
  double _completedHours = 0;
  double _totalHours = 0;
  int _pendingCount = 0;
  int _approvedCount = 0;
  // vacancies for "Available Programs"
  List<Map<String, dynamic>> _vacancies = [];
  // upcoming deadlines from vacancies closing soon
  List<Map<String, dynamic>> _deadlines = [];
  bool _isLoading = true;
  int? _profileId;
  List<Map<String, dynamic>> _applications = [];

  final VacancyService _vacancyService = VacancyService();
  final TrainingService _trainingService = TrainingService();

  // Method channel for Android
  static const platform = MethodChannel('com.aastconnect.app/url_launcher');
  //
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final supabase = Supabase.instance.client;
      
      // ✅ Get user ID from UserSession (set at login)
      final userId = UserSession.instance.userId!;

      // fetch student info (use maybeSingle to avoid crash if no record)
      final studentData = await supabase
          .from('student')
          .select()
          .eq('studentid', userId)
          .maybeSingle();

      // fetch profileId
      final profile = await supabase
          .from('profile')
          .select('profileid')
          .eq('userid', userId)
          .maybeSingle();
      _profileId = profile?['profileid'];

      // fetch pending training records count
      final pendingData = await supabase
          .from('trainingrecord')
          .select()
          .eq('studentid', userId)
          .eq('status', 'PENDING');

      // ✅ Calculate progress based on APPROVED trainings only
      final trainingProgress = await _trainingService.calculateTrainingProgress(userId);

      // fetch available vacancies for students
      final vacanciesData = await supabase
          .from('vacancies')
          .select('vacancyid, title, description, type, location, requiredskills, paidstatus, deadline, companyid, postedbyadminid, created_at, work_mode, company_name, target_audience, application_method, external_apply_url, company_logo_url')
          .or('target_audience.eq.STUDENT,target_audience.eq.BOTH')
          .order('deadline', ascending: true)
          .limit(2);

      // fetch upcoming deadlines (vacancies closing soon)
      final deadlinesData = await supabase
          .from('vacancies')
          .select('vacancyid, title, description, type, location, requiredskills, paidstatus, deadline, companyid, postedbyadminid, created_at, work_mode, company_name, target_audience, application_method, external_apply_url, company_logo_url')
          .or('target_audience.eq.STUDENT,target_audience.eq.BOTH')
          .gte('deadline', DateTime.now().toIso8601String())
          .order('deadline', ascending: true)
          .limit(2);

      // fetch user applications
      _applications = await _vacancyService.getUserApplications(userId);

      setState(() {
        // Use student table name if available, otherwise fall back to UserSession name
        _studentName = studentData?['name'] ?? UserSession.instance.name ?? '';
        // ✅ Use calculated approved hours (only APPROVED trainings)
        _completedHours = (trainingProgress['approvedHours'] as int).toDouble();
        _totalHours = (trainingProgress['requiredHours'] as int).toDouble();
        _pendingCount = pendingData.length;
        _approvedCount = trainingProgress['approvedHours'] > 0 ? 1 : 0;
        _vacancies = List<Map<String, dynamic>>.from(vacanciesData);
        _deadlines = List<Map<String, dynamic>>.from(deadlinesData);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => _isLoading = false);
    }
  }

  bool _hasApplied(String? vacancyId) {
    if (vacancyId == null) return false;
    return _applications.any(
      (app) => app['vacancyid'].toString() == vacancyId.toString(),
    );
  }

  // void _showApplyModal(BuildContext context, String title) {
  //   StudentOpportunitiesApplyModal.show(context, {'title': title}, null);
  // }
  //
  // void _showApplyModal(BuildContext context, String title) {
  //   StudentOpportunitiesApplyModal.show(context, {'title': title}, () {});
  // }

  void _showApplyModal(BuildContext context, Map<String, dynamic> vacancy) {
    // Check if application is external
    if (vacancy['application_method'] == 'EXTERNAL' &&
        vacancy['external_apply_url'] != null) {
      final url = vacancy['external_apply_url'].toString().trim();
      print('Launching external URL: $url');
      if (url.isNotEmpty) {
        _launchExternalUrl(url);
        return;
      }
    }

    StudentOpportunitiesApplyModal.show(
      context,
      {
        'title': vacancy['title'] ?? '',
        'company': vacancy['company_name'] ?? '',
        'vacancyId': vacancy['vacancyid'] ?? '',
      },
      () => _fetchData(), // Refresh data after apply
      profileId: _profileId,
      studentId: UserSession.instance.userId!,
      collegeId: UserSession.instance.collegeId ?? '',
      studentName: _studentName,
    );
  }

  Future<void> _launchExternalUrl(String url) async {
    try {
      print('=== DEBUG: _launchExternalUrl ===');
      print('Input URL: "$url"');

      // Ensure URL has a scheme
      String urlToLaunch = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        urlToLaunch = 'https://$url';
        print('Added https:// scheme -> "$urlToLaunch"');
      }

      final uri = Uri.parse(urlToLaunch);
      print('Parsed URI: $uri');

      // Try platform default first
      print('Trying LaunchMode.platformDefault...');
      try {
        bool success = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (success) {
          print('URL launched successfully with platformDefault!');
          return;
        }
      } catch (e1) {
        print('platformDefault failed: $e1');
      }

      // Fallback 1: Try in-app browser
      print('Trying LaunchMode.inAppBrowserView...');
      try {
        bool success = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        if (success) {
          print('URL launched successfully with inAppBrowserView!');
          return;
        }
      } catch (e2) {
        print('inAppBrowserView failed: $e2');
      }

      // Fallback 2: Try Android native
      print('Trying Android native method...');
      try {
        await platform.invokeMethod('launchURL', {'url': urlToLaunch});
        print('URL launched successfully with Android native method!');
        return;
      } catch (e3) {
        print('Android native method failed: $e3');
      }

      // All failed
      if (mounted) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Could not open URL',
            message: urlToLaunch,
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print('Error launching URL: $e');
      if (mounted) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: e.toString(),
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  //
  void _showDetailsModal(
    BuildContext context,
    String title,
    String company,
    String hours,
    Map<String, dynamic> vacancy,
  ) {
    final vacancyId = vacancy['vacancyid']?.toString() ?? '';
    final isApplied = _hasApplied(vacancyId);

    StudentOpportunitiesDetailsModal.show(context, {
      'title': title,
      'company': company,
      'type': hours,
      'description': null,
      'requirements': null,
      'location': null,
      'workMode': null,
      'paidStatus': null,
      'startDate': null,
      'applied': isApplied,
    }, () => _showApplyModal(context, vacancy));
  }

  // void _showDetailsModal(
  //     BuildContext context,
  //     String title,
  //     String company,
  //     String hours,
  //     ) {
  //   StudentOpportunitiesDetailsModal.show(context, title, company, hours);
  // }

  void _showAllDeadlines(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "All Upcoming Deadlines",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _deadlines.map((vacancy) {
                  final deadline = vacancy['deadline'] != null
                      ? DateTime.parse(vacancy['deadline'])
                      : null;
                  final daysLeft = deadline != null
                      ? deadline.difference(DateTime.now()).inDays
                      : 0;
                  final isUrgent = daysLeft <= 7;
                  final dateStr = deadline != null
                      ? "${deadline.day}/${deadline.month}"
                      : "N/A";
                  return _buildDeadlineCard(
                    context,
                    vacancy['title'] ?? '',
                    dateStr,
                    vacancy['type'] ?? '',
                    isUrgent,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineCard(
    BuildContext context,
    String title,
    String date,
    String hours,
    bool isUrgent,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  Text(
                    "Due: $date",
                    style: TextStyle(
                      color: isUrgent ? Colors.red : Colors.grey,
                    ),
                  ),
                  if (isUrgent) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Urgent",
                        style: TextStyle(color: Colors.red, fontSize: 10),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              hours,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //
  void _openTracking({
    int initialTabIndex = 1,
    String initialStatusFilter = 'All',
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StudentTrackingScreen(
          initialTabIndex: initialTabIndex,
          initialStatusFilter: initialStatusFilter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBarWithLogout(
        title: "AAST Connect",
        unreadNotificationCount: widget.unreadNotificationCount,
        onTimelinePressed: () => _openTracking(initialTabIndex: 0),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, $_studentName 👋",
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(fontSize: 28),
                      ),
                      Text(
                        "Let's continue your learning journey",
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 25),
                      InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _openTracking(initialTabIndex: 1),
                        child: StudentHomeProgressCard(
                          completedHours: _completedHours,
                          totalHours: _totalHours == 0 ? 1 : _totalHours,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => _openTracking(
                                initialTabIndex: 1,
                                initialStatusFilter: 'Pending',
                              ),
                              child: StudentHomeStatCard(
                                backgroundColor: AppColors.statPending,
                                number: _pendingCount.toString(),
                                label: "Pending",
                                icon: Icons.access_time,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => _openTracking(
                                initialTabIndex: 1,
                                initialStatusFilter: 'Approved',
                              ),
                              child: StudentHomeStatCard(
                                backgroundColor: AppColors.statApproved,
                                number: _approvedCount.toString(),
                                label: "Completed",
                                icon: Icons.verified,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      StudentHomeSectionHeader(
                        title: "Upcoming Deadlines",
                        actionText: "View all",
                        onActionTap: () => _showAllDeadlines(context),
                      ),
                      ..._deadlines.map((vacancy) {
                        final deadline = vacancy['deadline'] != null
                            ? DateTime.parse(vacancy['deadline'])
                            : null;
                        final daysLeft = deadline != null
                            ? deadline.difference(DateTime.now()).inDays
                            : 0;
                        final isUrgent = daysLeft <= 7;
                        final dateStr = deadline != null
                            ? "${deadline.day}/${deadline.month}"
                            : "N/A";
                        return StudentHomeDeadlineCard(
                          title: vacancy['title'] ?? '',
                          date: dateStr,
                          hours: vacancy['type'] ?? '',
                          isUrgent: isUrgent,
                        );
                      }),
                      const SizedBox(height: 30),
                      StudentHomeSectionHeader(
                        title: "Available Programs",
                        actionText: "See all",
                        onActionTap: widget.onSeeAll,
                      ),
                      ..._vacancies.map((vacancy) {
                        final vacancyId =
                            vacancy['vacancyid']?.toString() ?? '';
                        final isApplied = _hasApplied(vacancyId);
                        final isExternal =
                            vacancy['application_method'] == 'EXTERNAL';

                        return StudentHomeProgramCard(
                          title: vacancy['title'] ?? '',
                          subtitle: vacancy['company_name'] ?? '',
                          hours: vacancy['deadline'] != null
                              ? "Deadline: ${DateTime.parse(vacancy['deadline']).day}/${DateTime.parse(vacancy['deadline']).month}"
                              : 'No deadline',
                          logoUrl: vacancy['company_logo_url'],
                          vacancyType: vacancy['type'] ?? 'INTERNSHIP',
                          onViewDetails: () => _showDetailsModal(
                            context,
                            vacancy['title'] ?? '',
                            vacancy['company_name'] ?? '',
                            vacancy['type'] ?? '',
                            vacancy,
                          ),
                          onApply: isApplied
                              ? null
                              : () => _showApplyModal(context, vacancy),
                          isApplied: isApplied,
                          isExternal: isExternal,
                        );
                      }),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    return StudentHomeProgressCard(
      completedHours: _completedHours,
      totalHours: _totalHours == 0 ? 1 : _totalHours,
    );
  }
}
