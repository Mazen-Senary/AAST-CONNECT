import '../entities/opportunity.dart';

abstract class OpportunityRepository {
  Future<List<Opportunity>> getOpportunities();
  Future<void> delete(String id);
  Future<void> add(Map<String, dynamic> data);
  Future<void> update(String id, Map<String, dynamic> data);
}