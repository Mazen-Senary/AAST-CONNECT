import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/student_remote_datasource.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/usecases/get_students.dart';
import '../../presentation/viewmodels/student_profiles_notifier.dart';

/// Repository
final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  final client = Supabase.instance.client;

  return StudentRepositoryImpl(
    StudentRemoteDataSource(client),
  );
});

/// UseCase
final getStudentsProvider = Provider<GetStudents>((ref) {
  return GetStudents(ref.read(studentRepositoryProvider));
});

/// ViewModel
final studentProfilesProvider =
    StateNotifierProvider<StudentProfilesNotifier, StudentProfilesState>((ref) {
  return StudentProfilesNotifier(
    ref.read(getStudentsProvider),
  );
});