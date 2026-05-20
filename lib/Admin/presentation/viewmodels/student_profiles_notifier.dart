import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/student.dart'; 
import '../../domain/usecases/get_students.dart';
enum StudentSortOption { none, gpaDesc, gpaAsc, dateAsc }

/// ---------------- STATE ----------------
class StudentProfilesState {
  final List<Student> students;
  final bool isLoading;
  final String searchTerm;
  final String? error;
  final StudentSortOption sortOption;

  const StudentProfilesState({
    this.students = const [],
    this.isLoading = true,
    this.searchTerm = '',
    this.error,
    this.sortOption = StudentSortOption.none,
  });

  StudentProfilesState copyWith({
    List<Student>? students,
    bool? isLoading,
    String? searchTerm,
    String? error,
    StudentSortOption? sortOption,
  }) {
    return StudentProfilesState(
      students: students ?? this.students,
      isLoading: isLoading ?? this.isLoading,
      searchTerm: searchTerm ?? this.searchTerm,
      error: error,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  List<Student> get filteredStudents {
  var list = students.where((s) {
    if (searchTerm.trim().isEmpty) return true;
    final query = searchTerm.trim().toLowerCase();
    final isNumericQuery = RegExp(r'^[0-9]+$').hasMatch(query);
    final collegeId = (s.collegeId ?? '').toLowerCase();
    bool idMatch = false;
    if (isNumericQuery) {
      final numericId = collegeId.replaceAll(RegExp(r'[^0-9]'), '');
      idMatch = numericId.contains(query);
    } else {
      idMatch = collegeId.contains(query);
    }
    return idMatch ||
        s.name.toLowerCase().contains(query) ||
        s.email.toLowerCase().contains(query) ||
        s.major.toLowerCase().contains(query);
  }).toList();

  switch (sortOption) {
    case StudentSortOption.gpaDesc:
      list.sort((a, b) => b.gpa.compareTo(a.gpa));
      break;
    case StudentSortOption.gpaAsc:
      list.sort((a, b) => a.gpa.compareTo(b.gpa));
      break;
    case StudentSortOption.dateAsc:
      break; // no date field on student
    case StudentSortOption.none:
      break;
  }

  return list;
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
  void updateSort(StudentSortOption option) {
  state = state.copyWith(sortOption: option);
}
  
}
