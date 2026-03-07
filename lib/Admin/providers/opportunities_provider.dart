import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/opportunity.dart';

final opportunitiesProvider =
    StateNotifierProvider<OpportunitiesNotifier,
        AsyncValue<List<Opportunity>>>(
  (ref) => OpportunitiesNotifier(),
);

class OpportunitiesNotifier
    extends StateNotifier<AsyncValue<List<Opportunity>>> {
  OpportunitiesNotifier() : super(const AsyncLoading()) {
    fetchOpportunities();
  }

  final supabase = Supabase.instance.client;

  // ✅ FETCH
  Future<void> fetchOpportunities() async {
    try {
      final vacancies = await supabase.from('vacancies').select('*');
      final counts =
          await supabase.from('vacancy_applicant_counts').select();

      final Map<String, int> applicantMap = {
        for (var row in counts)
          row['vacancyid'].toString(): row['applicant_count'] as int
      };

      final data = (vacancies as List).map((row) {
        final id = row['vacancyid'].toString();

        return Opportunity(
          id: id,
          title: row['title'] ?? '',
          company: row['company_name'] ?? '',
          type: row['type'] ?? '',
          applicationMethod: row['application_method'] ?? 'INTERNAL',
          applicants: applicantMap[id] ?? 0,
          posted: DateTime.parse(row['created_at']),
          deadline: DateTime.parse(row['deadline']),
          location: row['location'],
          workMode: row['work_mode'],
          paidStatus: row['paidstatus'] ?? false,
          targetAudience: row['target_audience'] ?? 'STUDENT',
          externalApplyUrl: row['external_apply_url'],
          description: row['description'],
          requiredSkills: row['requiredskills'],
        );
      }).toList();

      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ✅ DELETE
  Future<void> deleteOpportunity(String id) async {
    await supabase.from('vacancies').delete().eq('vacancyid', id);
    await fetchOpportunities();
  }

  // ✅ ADD
  Future<void> addOpportunity(Map<String, dynamic> data) async {
    await supabase.from('vacancies').insert(data);
    await fetchOpportunities();
  }

  // ✅ UPDATE
  Future<void> updateOpportunity(
      String id, Map<String, dynamic> data) async {
    await supabase.from('vacancies').update(data).eq('vacancyid', id);
    await fetchOpportunities();
  }
}