// new code for the home page stateful
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/app_bar_with_logout.dart';
import '../../widgets/student_home_deadline_card.dart';
import '../../widgets/student_home_program_card.dart';
import '../../widgets/student_home_progress_card.dart';
import '../../widgets/student_home_section_header.dart';
import '../../widgets/student_home_stat_card.dart';
import '../../widgets/student_opportunities_apply_modal.dart';
import '../../widgets/student_opportunities_details_modal.dart';
import '../../services/vacancy_service.dart';
 class StudentHome extends StatefulWidget {
  final VoidCallback onSeeAll;
   const StudentHome({super.key,required this.onSeeAll});
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
//
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final supabase = Supabase.instance.client;
      //final userId = supabase.auth.currentUser?.id;//e3mlha uncomment  lama yb2a fi user login screen
      final userId = 5; // temporary hardcoded user ID for testing, replace with actual user ID from auth
      if (userId == null) return;

      // fetch student info
      final studentData = await supabase
          .from('student')
          .select()
          .eq('studentid', userId)
          .single();

      // fetch profileId
      final profile = await supabase
          .from('profile')
          .select('profileid')
          .eq('userid', userId)
          .maybeSingle();
      _profileId = profile?['profileid'];

      // fetch pending applications count
      final pendingData = await supabase
          .from('trainingrecord')
          .select()
          .eq('studentid', userId)
          .eq('status', 'PENDING');

      // fetch approved applications count
      final approvedData = await supabase
          .from('trainingrecord')
          .select()
          .eq('studentid', userId)
          .eq('status', 'APPROVED');

      // fetch available vacancies for students
      final vacanciesData = await supabase
          .from('vacancies')
          .select()
          .or('target_audience.eq.STUDENT,target_audience.eq.BOTH')
          .order('deadline', ascending: true)
          .limit(2);

      // fetch upcoming deadlines (vacancies closing soon)
      final deadlinesData = await supabase
          .from('vacancies')
          .select()
          .or('target_audience.eq.STUDENT,target_audience.eq.BOTH')
          .gte('deadline', DateTime.now().toIso8601String())
          .order('deadline', ascending: true)
          .limit(2);

      // fetch user applications
      _applications = await _vacancyService.getUserApplications(userId);

      setState(() {
        _studentName = studentData['name'] ?? '';
        _completedHours = (studentData['completedtraininghours'] ?? 0).toDouble();
        _totalHours = (studentData['requiredtraininghours'] ?? 0).toDouble();
        _pendingCount = pendingData.length;
        _approvedCount = approvedData.length;
        _vacancies = List<Map<String, dynamic>>.from(vacanciesData);
        _deadlines = List<Map<String, dynamic>>.from(deadlinesData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  bool _hasApplied(String? vacancyId) {
    if (vacancyId == null) return false;
    return _applications.any((app) => app['vacancyid'].toString() == vacancyId.toString());
  }

  // void _showApplyModal(BuildContext context, String title) {
  //   StudentOpportunitiesApplyModal.show(context, {'title': title}, null);
  // }
  //
  // void _showApplyModal(BuildContext context, String title) {
  //   StudentOpportunitiesApplyModal.show(context, {'title': title}, () {});
  // }

  void _showApplyModal(BuildContext context, Map<String, dynamic> vacancy) {
    StudentOpportunitiesApplyModal.show(
      context,
      {
        'title': vacancy['title'] ?? '',
        'company': vacancy['company_name'] ?? '',
        'vacancyId': vacancy['vacancyid'] ?? '',
      },
          () => _fetchData(), // Refresh data after apply
      profileId: _profileId,
      studentId: 5,
      collegeId: 'STD2023005',
      studentName: _studentName,
    );
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
    
    StudentOpportunitiesDetailsModal.show(
      context,
      {
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
      },
      () => _showApplyModal(context, vacancy),
    );
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const AppBarWithLogout(title: "AAST Connect"),
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
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(fontSize: 28),
                ),
                Text(
                  "Let's continue your learning journey",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 25),
                StudentHomeProgressCard(
                  completedHours: _completedHours,
                  totalHours: _totalHours == 0 ? 1 : _totalHours,
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: StudentHomeStatCard(
                        backgroundColor: const Color(0xffF2C6C6),
                        number: _pendingCount.toString(),
                        label: "Pending",
                        icon: Icons.access_time,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: StudentHomeStatCard(
                        backgroundColor: const Color(0xffCFE3CF),
                        number: _approvedCount.toString(),
                        label: "Completed",
                        icon: Icons.verified,
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
                  final vacancyId = vacancy['vacancyid']?.toString() ?? '';
                  final isApplied = _hasApplied(vacancyId);
                  
                  return StudentHomeProgramCard(
                    title: vacancy['title'] ?? '',
                    subtitle: vacancy['company_name'] ?? '',
                    hours: vacancy['deadline'] != null
                        ? "Deadline: ${DateTime.parse(vacancy['deadline']).day}/${DateTime.parse(vacancy['deadline']).month}"
                        : 'No deadline',
                    onViewDetails: () => _showDetailsModal(
                      context,
                      vacancy['title'] ?? '',
                      vacancy['company_name'] ?? '',
                      vacancy['type'] ?? '',
                      vacancy,
                    ),
                    onApply: isApplied ? null : () => _showApplyModal(
                      context,
                      vacancy,
                    ),
                    isApplied: isApplied,
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
 
