import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student.dart';

final studentProfilesProvider =
    StateNotifierProvider<StudentProfilesNotifier, StudentProfilesState>(
  (ref) => StudentProfilesNotifier(),
);

class StudentProfilesState {
  final List<Student> students;
  final bool isLoading;
  final String searchTerm;

  const StudentProfilesState({
    this.students = const [],
    this.isLoading = true,
    this.searchTerm = '',
  });

  StudentProfilesState copyWith({
    List<Student>? students,
    bool? isLoading,
    String? searchTerm,
  }) {
    return StudentProfilesState(
      students: students ?? this.students,
      isLoading: isLoading ?? this.isLoading,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }

  List<Student> get filteredStudents {
    if (searchTerm.trim().isEmpty) return students;

    final query = searchTerm.trim().toLowerCase();
    final isNumericQuery = RegExp(r'^[0-9]+$').hasMatch(query);

    return students.where((s) {
      final collegeId = (s.collegeId ?? '').toLowerCase();

      bool idMatch = false;

      if (isNumericQuery) {
        final numericId =
            collegeId.replaceAll(RegExp(r'[^0-9]'), '');
        idMatch = numericId.contains(query);
      } else {
        idMatch = collegeId.contains(query);
      }

      return idMatch ||
          s.name.toLowerCase().contains(query) ||
          s.email.toLowerCase().contains(query) ||
          s.major.toLowerCase().contains(query);
    }).toList();
  }
}

class StudentProfilesNotifier extends StateNotifier<StudentProfilesState> {
  StudentProfilesNotifier() : super(const StudentProfilesState()) {
    loadStudents();
  }

  final supabase = Supabase.instance.client;

  Future<void> loadStudents() async {
    try {
      final response =
          await supabase.from('student_profiles_view').select();

      final students = (response as List).map((e) {
        return Student(
          id: e['studentid'].toString(),
          name: e['name'] ?? '',
          email: e['email'] ?? '',
          major: e['major'] ?? '',
          year: e['academicyear'] ?? '',
          gpa: (e['gpa'] ?? 0).toDouble(),
          collegeId: e['college_id']?.toString(),
          applications: e['application_count'] ?? 0,
          trainingHours: e['completedtraininghours'] ?? 0,
          phone: e['phone'],
          address: e['address'],
          dateOfBirth: e['date_of_birth']?.toString(),
          gender: e['gender'],
          linkedinUrl: e['linkedin_url'],
          skills: e['skills'],
          bio: e['bio'],
          profileImageUrl: e['profile_image_url'],
        );
      }).toList();

      state = state.copyWith(
        students: students,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void updateSearch(String value) {
    state = state.copyWith(searchTerm: value);
  }

  void toggleExpanded(String id) {
    final updated = state.students.map((s) {
      if (s.id == id) {
        return s.copyWith(expanded: !s.expanded);
      }
      return s;
    }).toList();

    state = state.copyWith(students: updated);
  }
}