import '../entities/opportunity_page.dart';
abstract class OpportunityRepository {
  Future<void> delete(String id);
  Future<void> add(Map<String, dynamic> data);
  Future<void> update(String id, Map<String, dynamic> data);
  Future<OpportunityPage> getOpportunitiesPage({
    required int page,
    required int pageSize,
    String? search,
    String? type,
  });
}