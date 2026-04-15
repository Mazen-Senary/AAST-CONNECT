import 'package:grad_project/Admin/domain/repositories/approval_repository.dart';
import '../../domain/entities/application.dart';

class GetApplications {
  final ApprovalRepository repo;
  GetApplications(this.repo);

  Future<List<Application>> call() => repo.getApplications();
}