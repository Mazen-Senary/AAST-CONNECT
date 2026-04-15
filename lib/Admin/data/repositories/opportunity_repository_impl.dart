
import 'package:grad_project/Admin/data/datasources/opportunity_remote_datasource.dart';
import 'package:grad_project/Admin/domain/repositories/opportunity_repository.dart';
import '../../domain/entities/opportunity.dart';
import '../../data/models/opportunity_model.dart';
class OpportunityRepositoryImpl implements OpportunityRepository {
  final OpportunityRemoteDataSource remote;

  OpportunityRepositoryImpl(this.remote);

  @override
  Future<List<Opportunity>> getOpportunities() async {
    final result = await remote.fetchOpportunitiesData();

    final vacancies = result['vacancies'] as List;
    final counts = result['counts'] as List;

    final applicantMap = {
      for (var row in counts)
        row['vacancyid'].toString(): row['applicant_count'] as int
    };

    return vacancies.map((row) {
      final id = row['vacancyid'].toString();

      return OpportunityModel.fromJson(
        row,
        applicantMap[id] ?? 0,
      );
    }).toList();
  }

  @override
  Future<void> delete(String id) => remote.delete(id);

  @override
  Future<void> add(Map<String, dynamic> data) => remote.add(data);

  @override
  Future<void> update(String id, Map<String, dynamic> data) =>
      remote.update(id, data);
}