import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentProfilesScreen extends StatefulWidget {
  const StudentProfilesScreen({super.key});

  @override
  State<StudentProfilesScreen> createState() =>
      _StudentProfilesScreenState();
}

class _StudentProfilesScreenState extends State<StudentProfilesScreen> {
  String _searchTerm = '';
  final supabase = Supabase.instance.client;
  @override
void initState() {
  super.initState();
  _loadStudents();
}


List<Student> _students = [];
bool _isLoading = true;

Future<void> _loadStudents() async {
  try {
    final response = await supabase
        .from('student')
        .select();

    final data = response as List<dynamic>;
    debugPrint('Students fetched: ${data.length}');

    setState(() {
      _students = data.map((e) => Student(
        id: e['studentid'].toString(),
        name: e['name'] ?? '',
        email: e['email'] ?? '',
        major: e['major'] ?? '',
        year: e['academicyear'] ?? '',
        gpa: (e['gpa'] ?? 0).toDouble(),
        applications: e['application_count'] ?? 0,
        trainingHours: e['completedtraininghours'] ?? 0,
      )).toList();

      _isLoading = false;
    });
  } catch (e) {
    debugPrint('Load students error: $e');
    setState(() => _isLoading = false);
  }
}


  List<Student> get _filteredStudents {
    if (_searchTerm.isEmpty) return _students;

    return _students.where((s) {
      final q = _searchTerm.toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          s.email.toLowerCase().contains(q) ||
          s.major.toLowerCase().contains(q);
    }).toList();
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
          'Student Profiles',
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
            onPressed: () {
              themeProvider.toggleTheme();
            },
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
            /// SEARCH
            TextField(
              onChanged: (value) =>
                  setState(() => _searchTerm = value),
              decoration: InputDecoration(
                hintText:
                    'Search students by name, email, or major...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.inputHint,
                ),
                prefixIcon: Icon(Icons.search, color: isDark ? AppColors.darkTextSecondary : AppColors.inputHint),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.card,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppColors.radius),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkDivider : AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppColors.radius),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkDivider : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppColors.radius),
                  borderSide: BorderSide(
                    color: AppColors.interactive,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// GRID
            Expanded(
  child: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : ListView.separated(
          itemCount: _filteredStudents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (_, index) =>
              _buildStudentCard(_filteredStudents[index], isDark),
        ),
),


          ],
        ),
      ),
    );
  }

  // ---------------- CARD ----------------

  Widget _buildStudentCard(Student student, bool isDark) {
    return SizedBox(
      height: 240, // 🎯 EXACT CARD HEIGHT (change if needed)
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name, 
                    style: AppTextStyles.h3.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    student.major, 
                    style: AppTextStyles.body.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.interactive.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  student.year,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.interactive,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // EMAIL
          Row(
            children: [
              Icon(
                Icons.mail, 
                size: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  student.email,
                  style: AppTextStyles.body.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const Spacer(), // 🔑 keeps layout consistent

          // STATS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stat('GPA', student.gpa.toStringAsFixed(1), isDark),
              _stat('Applications', student.applications.toString(), isDark),
              _stat('Training Hrs', student.trainingHours.toString(), isDark),
            ],
          ),

          const SizedBox(height: 14),

          // ACTION
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.interactive : AppColors.interactive,
                side: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.border),
              ),
              child: const Text('View Full Profile'),
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _stat(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value, 
          style: AppTextStyles.body.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
