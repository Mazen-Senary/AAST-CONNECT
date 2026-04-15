import 'package:supabase_flutter/supabase_flutter.dart';

class OpportunityRemoteDataSource {
  final SupabaseClient client;

  OpportunityRemoteDataSource(this.client);

  Future<Map<String, dynamic>> fetchOpportunitiesData() async {
    final vacancies = await client.from('vacancies').select('*');
    final counts =
        await client.from('vacancy_applicant_counts').select();

    return {
      'vacancies': vacancies,
      'counts': counts,
    };
  }

  Future<void> delete(String id) async {
    await client.from('vacancies').delete().eq('vacancyid', id);
  }

  Future<void> add(Map<String, dynamic> data) async {
    await client.from('vacancies').insert(data);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await client.from('vacancies').update(data).eq('vacancyid', id);
  }
}