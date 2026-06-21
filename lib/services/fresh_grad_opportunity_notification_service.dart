import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FreshGradOpportunityNotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchUnreadOpportunityNotifications(
    int userId,
  ) async {
    final seenIds = await _loadSeenVacancyIds(userId);
    final vacancies = await _supabase
        .from('vacancies')
        .select(
          'vacancyid, title, company_name, created_at, target_audience',
        )
        .inFilter('target_audience', ['GRADUATE', 'BOTH'])
        .order('created_at', ascending: false)
        .limit(20);

    return List<Map<String, dynamic>>.from(vacancies)
        .where((vacancy) => !seenIds.contains(vacancy['vacancyid'].toString()))
        .map(_toNotification)
        .toList();
  }

  Future<int> unreadOpportunityCount(int userId) async {
    return (await fetchUnreadOpportunityNotifications(userId)).length;
  }

  Future<void> markOpportunityAsRead(int userId, String vacancyId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _seenKey(userId);
    final seenIds = prefs.getStringList(key) ?? <String>[];
    if (!seenIds.contains(vacancyId)) {
      await prefs.setStringList(key, [...seenIds, vacancyId]);
    }
  }

  Future<void> markAllOpportunitiesAsRead(int userId) async {
    final vacancies = await _supabase
        .from('vacancies')
        .select('vacancyid')
        .inFilter('target_audience', ['GRADUATE', 'BOTH']);
    final allIds = List<Map<String, dynamic>>.from(vacancies)
        .map((vacancy) => vacancy['vacancyid'].toString())
        .toSet()
        .toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_seenKey(userId), allIds);
  }

  Future<Set<String>> _loadSeenVacancyIds(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_seenKey(userId)) ?? <String>[]).toSet();
  }

  String _seenKey(int userId) => 'fresh_grad_seen_opportunity_ids_$userId';

  Map<String, dynamic> _toNotification(Map<String, dynamic> vacancy) {
    final vacancyId = vacancy['vacancyid'].toString();
    final title = vacancy['title']?.toString() ?? 'New opportunity';
    final company = vacancy['company_name']?.toString() ?? 'AAST Connect';

    return {
      'notificationid': 'vacancy:$vacancyId',
      'message': 'New graduate opportunity posted: $title at $company',
      'isread': false,
      'createdat': vacancy['created_at'],
      'is_virtual_opportunity': true,
      'vacancyid': vacancyId,
    };
  }
}
