import 'package:grad_project/Admin/domain/repositories/approval_repository.dart';
import '../../domain/entities/training.dart';

class GetTraining {
  final ApprovalRepository repo;
  GetTraining(this.repo);

  Future<List<Training>> call() => repo.getTraining();
}