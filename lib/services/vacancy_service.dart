import 'package:supabase_flutter/supabase_flutter.dart';
import '../fresh_grads/models/app_models.dart';

class VacancyService {
  static final _client = Supabase.instance.client;

  static Future<List<JobOpportunity>> fetchAll() async {
    final response = await _client
        .from('vacancies')
        .select()
        .or('target_audience.eq.BOTH,target_audience.eq.GRADUATE')
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => JobOpportunity.fromMap(row))
        .toList();
  }

  static Future<List<JobOpportunity>> fetchLatest({int limit = 3}) async {
    final response = await _client
        .from('vacancies')
        .select()
        .or('target_audience.eq.BOTH,target_audience.eq.GRADUATE')
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((row) => JobOpportunity.fromMap(row))
        .toList();
  }

  static Future<void> applyInternal({
    required String vacancyId,
    required String coverLetter,
    required String collegeId,
  }) async {
    final userData = await _client
        .from('users')
        .select('userid, name, college_id')
        .eq('college_id', collegeId)
        .single();

    await _client.from('application').insert({
      'vacancyid': vacancyId,
      'applicantid': userData['userid'],
      'coverletter': coverLetter,
      'status': 'PENDING',
      'submissiondate': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'college_id': userData['college_id'],
      'applicant_name': userData['name'],
    });
  }
}
