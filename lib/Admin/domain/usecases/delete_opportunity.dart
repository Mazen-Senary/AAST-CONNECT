import 'package:grad_project/Admin/domain/repositories/opportunity_repository.dart';
class DeleteOpportunity {
  final OpportunityRepository repository;

  DeleteOpportunity(this.repository);

  Future<void> call(String id) {
    return repository.delete(id);
  }
}