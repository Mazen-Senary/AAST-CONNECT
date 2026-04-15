import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_datasource.dart';
import '../models/student_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource remote;

  StudentRepositoryImpl(this.remote);

  @override
  Future<List<Student>> getStudents() async {
    final response = await remote.fetchStudents();

    return response.map((e) {
      return StudentModel.fromJson(e);
    }).toList();
  }
}