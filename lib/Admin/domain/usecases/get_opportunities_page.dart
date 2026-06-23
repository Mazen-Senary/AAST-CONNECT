// domain/usecases/get_opportunities_page.dart
import '../entities/opportunity_page.dart';
import '../repositories/opportunity_repository.dart';

class GetOpportunitiesPage {
  final OpportunityRepository repository;
  GetOpportunitiesPage(this.repository);

  Future<OpportunityPage> call({
    required int page,
    required int pageSize,
    String? search,
    String? type,
  }) {
    return repository.getOpportunitiesPage(
      page: page,
      pageSize: pageSize,
      search: search,
      type: type,
    );
  }
}