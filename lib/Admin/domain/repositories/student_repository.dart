import '../../domain/entities/student.dart';

abstract class StudentRepository {
  Future<List<Student>> getStudents();
}