import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../../services/theme_provider.dart';
import '../../services/user_session.dart';
import '../../widgets/profile_widgets/student_profile_edit_modal.dart';
import '../../widgets/rounded_container.dart';
import '../../widgets/home_widgets/student_home_section_header.dart';
import '../../widgets/profile_info_field.dart';
import '../../widgets/profile_widgets/student_profile_skills_modal.dart';
import '../../widgets/profile_widgets/student_profile_documents_modal.dart';
import '../../widgets/profile_widgets/student_profile_portfolio_modal.dart';
import '../../widgets/profile_widgets/student_profile_submit_hours_modal.dart';
import '../../models/student.dart';
import '../../widgets/app_bar_with_logout.dart';
import '../../signIn.dart';
import 'student_tracking.dart';

class StudentProfile extends StatefulWidget {
  final bool shouldRefresh; // NEW — triggered from main.dart on tab switch

  const StudentProfile({super.key, this.shouldRefresh = false});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  Student? _student;
  bool _isLoading = true;
  int? _profileId;
  List<Map<String, dynamic>> _documents = [];
  List<Map<String, dynamic>> _savedPrograms = [];

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  // called when parent passes new shouldRefresh value
  @override
  void didUpdateWidget(StudentProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldRefresh && !oldWidget.shouldRefresh) {
      _fetchStudentData();
    }
  }

  Future<void> _fetchStudentData() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = UserSession.instance.userId!;

      final data = await supabase
          .from('student')
          .select()
          .eq('studentid', userId)
          .single();

      final profile = await supabase
          .from('profile')
          .select()
          .eq('userid', userId)
          .maybeSingle();

      int? profileId;
      if (profile == null) {
        final newProfile = await supabase
            .from('profile')
            .insert({'userid': userId})
            .select()
            .single();
        profileId = newProfile['profileid'];
      } else {
        profileId = profile['profileid'];
      }

      final docs = await supabase
          .from('document')
          .select()
          .eq('ownerprofileid', profileId ?? 0)
          .order('uploaddate', ascending: false);

      final savedData = await supabase
          .from('saved_programs')
          .select('*, vacancies(title, company_name)')
          .eq('studentid', userId);

      setState(() {
        _student = Student.fromMap(data);
        _profileId = profileId;
        _documents = List<Map<String, dynamic>>.from(docs);
        _savedPrograms = List<Map<String, dynamic>>.from(savedData);
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unsaveProgram(String vacancyId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('saved_programs')
          .delete()
          .eq('studentid', _student!.studentID)
          .eq('vacancyid', vacancyId);

      setState(() {
        _savedPrograms.removeWhere(
          (saved) => saved['vacancyid'].toString() == vacancyId,
        );
      });

      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: const AwesomeSnackbarContent(
          title: 'Success',
          message: 'Removed from saved programs',
          contentType: ContentType.success,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error',
          message: 'Error: $e',
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _showEditProfileModal(BuildContext context) {
    StudentProfileEditModal.show(
      context,
      {
        'name': _student?.studentName ?? '',
        'phone': _student?.phoneNumber ?? '',
        'bio': _student?.bio ?? '',
        'address': _student?.address ?? '',
        'linkedin_url': _student?.linkedinURL ?? '',
        'college_id': _student?.collegeID ?? '',
        'major': _student?.major ?? '',
        'academicYear': _student?.academicYear ?? '',
        'gpa': _student?.gpa?.toString() ?? '',
      },
      (updatedData) async {
        try {
          final supabase = Supabase.instance.client;
          await supabase
              .from('student')
              .update({
                'name': updatedData['name'],
                'phone': updatedData['phone'],
                'bio': updatedData['bio'],
                'address': updatedData['address'],
                'linkedin_url': updatedData['linkedin_url'],
              })
              .eq('studentid', _student!.studentID);

          await _fetchStudentData();
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: const AwesomeSnackbarContent(
              title: 'Success',
              message: 'Profile updated successfully!',
              contentType: ContentType.success,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } catch (e) {
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Error',
              message: 'Error: $e',
              contentType: ContentType.failure,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
    );
  }

  void _showSavedProgramDetails(
    BuildContext context,
    String title,
    String company,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(company, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),
            const Text(
              "Program Details:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("• Duration: 6 months"),
            const Text("• Location: Hybrid"),
            const Text("• Start Date: March 2024"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
            ),
            onPressed: () {
              Navigator.pop(context);
              final snackBar = SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: const AwesomeSnackbarContent(
                  title: 'Success',
                  message: 'Application started!',
                  contentType: ContentType.success,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            child: const Text("Apply Now"),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rejected,
            ),
            onPressed: () {
              Navigator.pop(context);
              UserSession.instance.clear();
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SignInScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBarWithLogout(
        title: "AAST Connect",
        unreadNotificationCount: 0,
        onTimelinePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const StudentTrackingScreen(),
            ),
          );
        },
        onLogout: _handleLogout,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Profile",
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge?.copyWith(fontSize: 28),
                  ),
                  Text(
                    "Manage your information and documents",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 25),

                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showEditProfileModal(context),
                          child: _buildQuickAction(
                            Icons.email_outlined,
                            "Edit Profile",
                            const Color(0xFFD6E2F2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => StudentProfileSkillsModal.show(
                            context,
                            _student!.studentID,
                          ),
                          child: _buildQuickAction(
                            Icons.eco_outlined,
                            "Skills & Interests",
                            const Color(0xFFCFE3CF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => StudentProfileDocumentsModal.show(
                            context,
                            _profileId,
                            onUpdate: () => _fetchStudentData(),
                          ),
                          child: _buildQuickAction(
                            Icons.description_outlined,
                            "Documents",
                            const Color(0xFFF9EAD2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => StudentProfilePortfolioModal.show(
                            context,
                            _student!.studentID,
                          ),
                          child: _buildQuickAction(
                            Icons.bookmark_border,
                            "Portfolio Links",
                            const Color(0xFFF2C6C6),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // User Info Card
                  _buildUserInfoCard(context),

                  const SizedBox(height: 30),

                  // Documents Section
                  StudentHomeSectionHeader(
                    title: "Documents",
                    actionText: "Manage",
                    onActionTap: () => StudentProfileDocumentsModal.show(
                      context,
                      _profileId,
                      onUpdate: () => _fetchStudentData(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _documents.isEmpty
                      ? GestureDetector(
                          onTap: () => StudentProfileDocumentsModal.show(
                            context,
                            _profileId,
                            onUpdate: () => _fetchStudentData(),
                          ),
                          child: _buildDocItem(
                            "No documents yet — tap to upload",
                            "Upload your CV, certificates",
                            true,
                          ),
                        )
                      : Column(
                          children: _documents.take(2).map((doc) {
                            final uploadDate = doc['uploaddate'] != null
                                ? DateTime.parse(doc['uploaddate'])
                                : DateTime.now();
                            final dateStr =
                                "${doc['documenttype']} • ${uploadDate.day}/${uploadDate.month}/${uploadDate.year}";
                            final filepath = doc['filepath'] ?? '';
                            final uri = Uri.parse(filepath);
                            final fullName = uri.pathSegments.isNotEmpty
                                ? uri.pathSegments.last
                                : '';
                            final parts = fullName.split('_');
                            final realName = parts.length > 2
                                ? parts.sublist(2).join('_')
                                : doc['documenttype'] ?? '';
                            return GestureDetector(
                              onTap: () => StudentProfileDocumentsModal.show(
                                context,
                                _profileId,
                                onUpdate: () => _fetchStudentData(),
                              ),
                              child: _buildDocItem(realName, dateStr, true),
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 30),

                  // Saved Programs Section
                  StudentHomeSectionHeader(
                    title: "Saved Programs",
                    actionText: "View All",
                    onActionTap: () {},
                  ),
                  const SizedBox(height: 15),
                  _savedPrograms.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            "No saved programs yet — browse opportunities to save some!",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : Column(
                          children: _savedPrograms.map((saved) {
                            final vacancy = saved['vacancies'];
                            return GestureDetector(
                              onTap: () => _showSavedProgramDetails(
                                context,
                                vacancy['title'] ?? '',
                                vacancy['company_name'] ?? '',
                              ),
                              child: _buildSavedItem(
                                vacancy['title'] ?? '',
                                vacancy['company_name'] ?? '',
                                onUnsave: () => _unsaveProgram(
                                  saved['vacancyid'].toString(),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 30),

                  // Submit Training Hours
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => StudentProfileSubmitHoursModal.show(
                        context,
                        studentId: _student!.studentID,
                        onSubmitted: _fetchStudentData,
                      ),
                      icon: const Icon(Icons.anchor),
                      label: const Text("Submit Training Hours"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.quickActionSkills,
                        foregroundColor: AppColors.lightPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return RoundedContainer(
      backgroundColor: color,
      borderRadius: 15.0,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    return RoundedContainer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      borderColor: Theme.of(context).dividerColor,
      borderRadius: 20.0,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.lightSecondary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    _student?.studentName.isNotEmpty == true
                        ? _student!.studentName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _student?.studentName ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${_student?.major ?? ''} • ${_student?.academicYear ?? ''}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "ID: ${_student?.collegeID ?? ''}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 40),
          ProfileInfoField(
            icon: Icons.email_outlined,
            label: "Email",
            value: _student?.studentEmail ?? '',
          ),
          const SizedBox(height: 15),
          ProfileInfoField(
            icon: Icons.phone_outlined,
            label: "Phone",
            value: _student?.phoneNumber ?? 'No phone added',
          ),
          const SizedBox(height: 15),
          ProfileInfoField(
            icon: Icons.workspace_premium_outlined,
            label: "GPA",
            value: _student?.gpa?.toString() ?? 'N/A',
          ),
          const SizedBox(height: 20),
          const Text("Bio", style: TextStyle(color: Colors.grey)),
          Text(_student?.bio ?? 'No bio added'),
        ],
      ),
    );
  }

  Widget _buildDocItem(String name, String date, [bool isClickable = false]) {
    return RoundedContainer(
      backgroundColor: Colors.white,
      borderColor: Colors.grey.shade200,
      borderRadius: 15.0,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.documentBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.file_present,
              color: AppColors.lightPrimary,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isClickable) const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSavedItem(
    String title,
    String company, {
    VoidCallback? onUnsave,
  }) {
    return RoundedContainer(
      backgroundColor: Colors.white,
      borderColor: Colors.grey.shade100,
      borderRadius: 15.0,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(company, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Row(
            children: [
              if (onUnsave != null)
                GestureDetector(
                  onTap: onUnsave,
                  child: const Icon(
                    Icons.bookmark_remove,
                    color: AppColors.lightPrimary,
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
