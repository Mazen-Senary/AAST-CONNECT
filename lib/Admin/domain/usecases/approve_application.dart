
import 'package:grad_project/Admin/domain/repositories/approval_repository.dart';

class ApproveApplication {
  final ApprovalRepository repo;
  ApproveApplication(this.repo);

  Future<void> call(int id) => repo.approveApplication(id);
}