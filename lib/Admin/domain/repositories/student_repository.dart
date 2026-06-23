import '../../domain/entities/student.dart';

abstract class StudentRepository {
  Future<List<Student>> getStudents({int page = 0});
}