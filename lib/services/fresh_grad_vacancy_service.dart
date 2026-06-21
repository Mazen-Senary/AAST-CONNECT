import 'package:supabase_flutter/supabase_flutter.dart';
import '../fresh_grads/models/app_models.dart';
import 'user_session.dart';

/// Vacancy service for Fresh Graduates.
///
/// Fetches vacancies targeted at GRADUATE or BOTH audiences,
/// and handles internal applications using the logged-in user's data.
class FreshGradVacancyService {
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

  /// Looks up the logged-in user's row in `users` by college_id.
  /// Returns the raw map so callers can grab `userid`, `name`, etc.
  static Future<Map<String, dynamic>> fetchCurrentUserData() async {
    final session = UserSession.instance;
    final collegeId = session.collegeId ?? '';

    final userData = await _client
        .from('users')
        .select('userid, name, college_id')
        .eq('college_id', collegeId)
        .single();

    return userData;
  }

  static Future<void> applyInternal({
    required String vacancyId,
    required String coverLetter,
    String? documentId,
  }) async {
    final userData = await fetchCurrentUserData();

    await _client.from('application').insert({
      'vacancyid': vacancyId,
      'applicantid': userData['userid'],
      'coverletter': coverLetter,
      'status': 'PENDING',
      'submissiondate': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'college_id': userData['college_id'],
      'applicant_name': userData['name'],
      // Note: 'documentid' column does not exist on 'application' yet.
      // The CV itself is still uploaded and saved in the 'document' table,
      // it's just not linked to this specific application row for now.
    });
  }

  /// Returns the set of vacancyIds this user has already applied to.
  static Future<Set<String>> fetchAppliedVacancyIds() async {
    try {
      final userData = await fetchCurrentUserData();
      final response = await _client
          .from('application')
          .select('vacancyid')
          .eq('applicantid', userData['userid']);

      return (response as List)
          .map((row) => row['vacancyid'].toString())
          .toSet();
    } catch (e) {
      return {};
    }
  }
}
