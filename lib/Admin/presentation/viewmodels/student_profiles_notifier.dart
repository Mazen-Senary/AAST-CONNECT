import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/student.dart';
import '../../domain/usecases/get_students.dart';
import '../../data/datasources/student_remote_datasource.dart';

enum StudentSortOption { none, gpaDesc, gpaAsc, dateAsc }

class StudentProfilesState {
  final List<Student> students;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String searchTerm;
  final String? error;
  final StudentSortOption sortOption;

  const StudentProfilesState({
    this.students = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.searchTerm = '',
    this.error,
    this.sortOption = StudentSortOption.none,
  });

  StudentProfilesState copyWith({
    List<Student>? students,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? searchTerm,
    String? error,
    StudentSortOption? sortOption,
  }) {
    return StudentProfilesState(
      students: students ?? this.students,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
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
      bool idMatch = isNumericQuery
          ? collegeId.replaceAll(RegExp(r'[^0-9]'), '').contains(query)
          : collegeId.contains(query);
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
      default:
        break;
    }
    return list;
  }
}

class StudentProfilesNotifier extends StateNotifier<StudentProfilesState> {
  final GetStudents getStudents;
  Timer? _debounce;
  DateTime? _lastFetch;

  StudentProfilesNotifier(this.getStudents)
      : super(const StudentProfilesState()) {
    loadStudents();
  }

  Future<void> loadStudents({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < const Duration(minutes: 2) &&
        state.students.isNotEmpty) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final students = await getStudents(page: 0);
      _lastFetch = DateTime.now();
      state = state.copyWith(
        students: students,
        isLoading: false,
        currentPage: 0,
        hasMore: students.length == StudentRemoteDataSource.pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    print('🔄 loadMore called — page: ${state.currentPage}, hasMore: ${state.hasMore}, isLoadingMore: ${state.isLoadingMore}');
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final more = await getStudents(page: state.currentPage + 1);
      state = state.copyWith(
        students: [...state.students, ...more],
        currentPage: state.currentPage + 1,
        hasMore: more.length == StudentRemoteDataSource.pageSize,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void updateSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      state = state.copyWith(searchTerm: value);
    });
  }

  void updateSort(StudentSortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void toggleExpanded(String id) {
    final updated = state.students.map((s) {
      if (s.id == id) return s.copyWith(expanded: !s.expanded);
      return s;
    }).toList();
    state = state.copyWith(students: updated);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}