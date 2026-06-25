import 'package:supabase_flutter/supabase_flutter.dart';
import '../fresh_grads/models/app_models.dart';
import 'user_session.dart';

/// Vacancy service for Fresh Graduates.
///
/// Fetches vacancies targeted at GRADUATE or BOTH audiences,
/// and handles internal applications using the logged-in user's data.
class FreshGradVacancyService {
  static final _client = Supabase.instance.client;

  static Future<int?> resolveOrCreateProfileId() async {
    final userData = await fetchCurrentUserData();
    final userId = userData['userid'] is int
        ? userData['userid'] as int
        : int.parse(userData['userid'].toString());

    final existing = await _client
        .from('profile')
        .select('profileid')
        .eq('userid', userId)
        .maybeSingle();

    if (existing != null) {
      return existing['profileid'] as int?;
    }

    final created = await _client
        .from('profile')
        .insert({'userid': userId})
        .select('profileid')
        .single();

    return created['profileid'] as int?;
  }

  static String _extractStoragePath(String publicUrl) {
    final uri = Uri.parse(publicUrl);
    return uri.pathSegments
        .skipWhile((segment) => segment != 'documents')
        .skip(1)
        .join('/');
  }

  static String _extractFileName(String publicUrl) {
    final uri = Uri.parse(publicUrl);
    return uri.pathSegments.isEmpty ? 'document.pdf' : uri.pathSegments.last;
  }

  static Future<String?> _createApplicationDocumentSnapshot({
    required String documentId,
    required int applicantId,
  }) async {
    final sourceDocument = await _client
        .from('document')
        .select('documentid, documenttype, filepath')
        .eq('documentid', documentId)
        .maybeSingle();

    if (sourceDocument == null) {
      throw Exception('Selected document was not found.');
    }

    final sourceUrl = sourceDocument['filepath']?.toString() ?? '';
    if (sourceUrl.isEmpty) {
      throw Exception('Selected document has no file path.');
    }

    final sourceBytes = await _client.storage
        .from('documents')
        .download(_extractStoragePath(sourceUrl));

    final fileName = _extractFileName(sourceUrl)
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final snapshotPath =
        'applications/$applicantId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await _client.storage
        .from('documents')
        .uploadBinary(snapshotPath, sourceBytes);

    final snapshotUrl =
        _client.storage.from('documents').getPublicUrl(snapshotPath);

    final inserted = await _client
        .from('document')
        .insert({
          'ownerprofileid': null,
          'documenttype': sourceDocument['documenttype'],
          'filepath': snapshotUrl,
        })
        .select('documentid')
        .single();

    return inserted['documentid']?.toString();
  }

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
    if (session.userId != null) {
      final byUserId = await _client
          .from('users')
          .select('userid, name, college_id')
          .eq('userid', session.userId!)
          .maybeSingle();
      if (byUserId != null) {
        return byUserId;
      }
    }

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
    final applicantId = userData['userid'] is int
        ? userData['userid'] as int
        : int.parse(userData['userid'].toString());

    String? snapshotDocumentId;
    if (documentId != null && documentId.isNotEmpty) {
      snapshotDocumentId = await _createApplicationDocumentSnapshot(
        documentId: documentId,
        applicantId: applicantId,
      );
    }

    await _client.from('application').insert({
      'vacancyid': vacancyId,
      'applicantid': applicantId,
      'coverletter': coverLetter,
      'status': 'PENDING',
      'submissiondate': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'college_id': userData['college_id'],
      'applicant_name': userData['name'],
      'document_id': snapshotDocumentId,
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
