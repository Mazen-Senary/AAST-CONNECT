import 'package:grad_project/Admin/data/datasources/opportunity_remote_datasource.dart';
import 'package:grad_project/Admin/domain/entities/opportunity_page.dart';
import 'package:grad_project/Admin/domain/repositories/opportunity_repository.dart';
import '../../domain/entities/opportunity.dart';
import '../../data/models/opportunity_model.dart';

class OpportunityRepositoryImpl implements OpportunityRepository {
  final OpportunityRemoteDataSource remote;

  OpportunityRepositoryImpl(this.remote);

  @override
  Future<OpportunityPage> getOpportunitiesPage({
    required int page,
    required int pageSize,
    String? search,
    String? type,
  }) async {
    final rows = await remote.fetchVacanciesPage(
      page: page,
      pageSize: pageSize,
      search: search,
      type: type,
    );
    if (rows.isEmpty)
      return const OpportunityPage(opportunities: [], hasMore: false);
    final ids = rows.map((r) => r['vacancyid'].toString()).toList();
    final counts = await remote.fetchApplicantsCounts(ids);
    final applicantMap = {
      for (var c in counts)
        c['vacancyid'].toString(): c['applicant_count'] as int,
    };
    final items = rows
        .map(
          (r) => OpportunityModel.fromJson(
            r,
            applicantMap[r['vacancyid'].toString()] ?? 0,
          ),
        )
        .toList();

    // If we got a full page back, assume there's more. Cheap heuristic,
    // avoids a separate count() query.
    return OpportunityPage(
      opportunities: items,
      hasMore: rows.length == pageSize,
    );
  }

  @override
  Future<void> delete(String id) => remote.delete(id);

  @override
  Future<void> add(Map<String, dynamic> data) => remote.add(data);

  @override
  Future<void> update(String id, Map<String, dynamic> data) =>
      remote.update(id, data);
}
