import 'package:grad_project/Admin/domain/repositories/approval_repository.dart';

class RejectTraining {
  final ApprovalRepository repo;
  RejectTraining(this.repo);

  Future<void> call(int id, String? reason) =>
      repo.rejectTraining(id, reason);
}