import 'package:grad_project/Admin/domain/repositories/opportunity_repository.dart';

class AddOpportunity {
  final OpportunityRepository repository;

  AddOpportunity(this.repository);

  Future<void> call(Map<String, dynamic> data) {
    return repository.add(data);
  }
}