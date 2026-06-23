import 'package:supabase_flutter/supabase_flutter.dart';

class OpportunityRemoteDataSource {
  final SupabaseClient client;

  OpportunityRemoteDataSource(this.client);
//pagination
  Future<List<Map<String,dynamic>>> fetchVacanciesPage({
    required int page,
    required int pageSize,
    String? search,
    String? type,
  })async{
    final from = page * pageSize;
    final to = from + pageSize-1;
    var query = client.from('vacancies').select('*'); //1 query to fetch all batch processing
    if(search!=null && search.trim().isNotEmpty){
      final term = search.trim();
      query = query.or('title.ilike.%$term%,company_name.ilike.%$term%');
    }
    if(type!=null && type.trim().isNotEmpty && type != 'all'){
      query = query.eq('type', type);
    }
    final todayDate = DateTime.now();
    final dateOnly = '${todayDate.year.toString().padLeft(4, '0')}-'
        '${todayDate.month.toString().padLeft(2, '0')}-'
        '${todayDate.day.toString().padLeft(2, '0')}';
    return await query
        .gte('deadline', dateOnly)
        .order('created_at', ascending: false)
        .range(from, to);
  }
  Future<List<Map<String,dynamic>>> fetchApplicantsCounts(
    List<String> vacancyIds,
  ) async{
    if (vacancyIds.isEmpty) return [];
    return await client
      .from('vacancy_applicant_counts')
      .select()
      .inFilter('vacancyid', vacancyIds);
  }
/*
  Future<Map<String, dynamic>> fetchOpportunitiesData() async {
    final vacancies = await client.from('vacancies').select('*');
    final counts =
        await client.from('vacancy_applicant_counts').select();

    return {
      'vacancies': vacancies,
      'counts': counts,
    };
  }
*/
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