import 'package:grad_project/Admin/domain/repositories/opportunity_repository.dart';
import 'package:grad_project/Admin/domain/entities/opportunity.dart';
class GetOpportunities {
  final OpportunityRepository repository;

  GetOpportunities(this.repository);

  Future<List<Opportunity>> call() {
    return repository.getOpportunities();
  }
}