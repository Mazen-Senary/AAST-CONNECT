import 'package:grad_project/Admin/domain/repositories/approval_repository.dart';

class ApproveTraining {
  final ApprovalRepository repo;
  ApproveTraining(this.repo);

  Future<void> call(int id) => repo.approveTraining(id);
}