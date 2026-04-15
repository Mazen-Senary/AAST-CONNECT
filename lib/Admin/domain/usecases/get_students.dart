import 'package:grad_project/Admin/domain/repositories/student_repository.dart';

import '../../domain/entities/student.dart';

class GetStudents {
  final StudentRepository repository;

  GetStudents(this.repository);

  Future<List<Student>> call() async {
    return await repository.getStudents();
  }
}