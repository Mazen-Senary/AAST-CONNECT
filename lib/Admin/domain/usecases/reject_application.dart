import 'package:grad_project/Admin/domain/repositories/approval_repository.dart';

class RejectApplication {
  final ApprovalRepository repo;
  RejectApplication(this.repo);

  Future<void> call(int id, String? reason) =>
      repo.rejectApplication(id, reason);
}