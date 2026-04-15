import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/student.dart'; 
import '../../domain/usecases/get_students.dart';


/// ---------------- STATE ----------------
class StudentProfilesState {
  final List<Student> students;
  final bool isLoading;
  final String searchTerm;
  final String? error;

  const StudentProfilesState({
    this.students = const [],
    this.isLoading = true,
    this.searchTerm = '',
    this.error,
  });

  StudentProfilesState copyWith({
    List<Student>? students,
    bool? isLoading,
    String? searchTerm,
    String? error,
  }) {
    return StudentProfilesState(
      students: students ?? this.students,
      isLoading: isLoading ?? this.isLoading,
      searchTerm: searchTerm ?? this.searchTerm,
      error: error,
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
/// ---------------- NOTIFIER ----------------

class StudentProfilesNotifier extends StateNotifier<StudentProfilesState> {
  final GetStudents getStudents;

  StudentProfilesNotifier(this.getStudents)
      : super(const StudentProfilesState()) {
    loadStudents();
  }


  Future<void> loadStudents() async {
    state = state.copyWith(isLoading: true, error: null);
  try {
    final students = await getStudents();

    state = state.copyWith(
      students: students,
      isLoading: false,
      error: null,
    );
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
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
