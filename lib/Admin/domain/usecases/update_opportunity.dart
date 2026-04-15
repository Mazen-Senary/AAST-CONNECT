import 'package:grad_project/Admin/domain/repositories/opportunity_repository.dart';

class UpdateOpportunity {
  final OpportunityRepository repository;

  UpdateOpportunity(this.repository);

  Future<void> call(String id, Map<String, dynamic> data) {
    return repository.update(id, data);
  }
}