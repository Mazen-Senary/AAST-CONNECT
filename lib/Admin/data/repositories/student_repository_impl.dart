import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_datasource.dart';
import '../models/student_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource remote;

  StudentRepositoryImpl(this.remote);

  @override
  Future<List<Student>> getStudents({int page = 0}) async {
  final data = await remote.fetchStudents(page: page);
  return data.map((e) => StudentModel.fromJson(e)).toList();
}
}