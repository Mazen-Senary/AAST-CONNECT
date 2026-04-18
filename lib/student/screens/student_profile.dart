import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme_provider.dart';
import '../../widgets/student_profile_edit_modal.dart';
import '../../widgets/rounded_container.dart';
import '../../widgets/student_home_section_header.dart';
import '../../widgets/profile_info_field.dart';
import '../../widgets/student_profile_skills_modal.dart';
import '../../widgets/student_profile_documents_modal.dart';
import '../../widgets/student_profile_portfolio_modal.dart';
import '../../widgets/student_profile_submit_hours_modal.dart';
import '../../models/student.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class StudentProfile extends StatefulWidget {
  const StudentProfile({super.key});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  Student? _student;
  bool _isLoading = true;
  int? _profileId;
  List<Map<String, dynamic>> _documents = [];
  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }
  Future<void> _fetchStudentData() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = 5; // temp hardcode, replace later with supabase.auth.currentUser?.id

      final data = await supabase
          .from('student')
          .select()
          .eq('studentid', userId)
          .single();
      // check if profile exists, if not create it
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
      //fetching student documents using profileId
      final docs = await supabase
          .from('document')
          .select()
          .eq('ownerprofileid', profileId ?? 0)
          .order('uploaddate', ascending: false);

      // set everything at once in ONE setState
      setState(() {
        _student = Student.fromMap(data);
        _profileId = profileId;
        _isLoading = false;
        _documents = List<Map<String, dynamic>>.from(docs);
      });
    } catch (e) {
      print('Error: $e'); // add this to see what's failing
      setState(() => _isLoading = false);
    }
  }

  void _showEditProfileModal(BuildContext context) {
    StudentProfileEditModal.show(context, {
      'name': _student?.studentName ?? '',
      'phone': _student?.phoneNumber ?? '',
      'bio': _student?.bio ?? '',
      'address': _student?.address ?? '',
      'linkedin_url': _student?.linkedinURL ?? '',
      'college_id': _student?.collegeID ?? '',
      'major': _student?.major ?? '',
      'academicYear': _student?.academicYear ?? '',
      'gpa': _student?.gpa?.toString() ?? '',
    },  (updatedData) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    });
  }

  Widget _buildEditField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
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
              backgroundColor: const Color(0xFF284B8C),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Application started!")),
              );
            },
            child: const Text("Apply Now"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          "AAST Connect",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          Icon(
            Icons.logout,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 15),
        ],
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

            // Top Quick Actions Grid - Now Clickable
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
                onTap: () => StudentProfileSkillsModal.show(context, _student!.studentID),
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
                    onTap: () => StudentProfileDocumentsModal.show(context,_profileId, onUpdate: () {
                      _fetchStudentData();
                    }),
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
                    onTap: () => StudentProfilePortfolioModal.show(context, _student!.studentID),
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

            // Documents Section - Now Interactive
            StudentHomeSectionHeader(
              title: "Documents",
              actionText: "Manage",
              onActionTap: () => StudentProfileDocumentsModal.show(context,_profileId,onUpdate: () {
                _fetchStudentData();}),
            ),
            const SizedBox(height: 15),
            _documents.isEmpty
                ? GestureDetector(
              onTap: () => StudentProfileDocumentsModal.show(context, _profileId,onUpdate: () {
                _fetchStudentData();}),
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
                final dateStr = "${doc['documenttype']} • ${uploadDate.day}/${uploadDate.month}/${uploadDate.year}";

                // extract real filename from URL
                final filepath = doc['filepath'] ?? '';
                final uri = Uri.parse(filepath);
                final fullName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
                final parts = fullName.split('_');
                final realName = parts.length > 2 ? parts.sublist(2).join('_') : doc['documenttype'] ?? '';

                return GestureDetector(
                  onTap: () => StudentProfileDocumentsModal.show(context, _profileId),
                  child: _buildDocItem(
                    realName, // ← now shows real filename
                    dateStr,
                    true,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Saved Programs - Now Clickable
            StudentHomeSectionHeader(
              title: "Saved Programs",
              actionText: "View All",
              onActionTap: () {},
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => _showSavedProgramDetails(
                context,
                "Software Engineering Intern",
                "TechCorp",
              ),
              child: _buildSavedItem("Software Engineering Intern", "TechCorp"),
            ),
            GestureDetector(
              onTap: () => _showSavedProgramDetails(
                context,
                "Data Science Workshop",
                "DataLab Inc.",
              ),
              child: _buildSavedItem("Data Science Workshop", "DataLab Inc."),
            ),

            const SizedBox(height: 30),

            // Bottom Action Buttons - Removed Resume Checker, Submit Hours is clickable
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => StudentProfileSubmitHoursModal.show(context),
                icon: const Icon(Icons.anchor),
                label: const Text("Submit Training Hours"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6E2F2),
                  foregroundColor: const Color(0xFF284B8C),
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

  // --- UI Components ---

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
                  color: const Color(0xFF637E99),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    // take first letters of name for avatar
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
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              color: const Color(0xFFD6E2F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.file_present, color: Color(0xFF284B8C)),
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

  Widget _buildSavedItem(String title, String company) {
    return RoundedContainer(
      backgroundColor: Colors.white,
      borderColor: Colors.grey.shade100,
      borderRadius: 15.0,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
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
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
