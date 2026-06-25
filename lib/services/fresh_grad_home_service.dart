import 'package:supabase_flutter/supabase_flutter.dart';

import '../fresh_grads/models/app_models.dart';
import 'fresh_grad_vacancy_service.dart';
import 'user_session.dart';

class FreshGradRecentActivity {
  final String title;
  final String company;
  final String status;
  final String? imageUrl;

  const FreshGradRecentActivity({
    required this.title,
    required this.company,
    required this.status,
    this.imageUrl,
  });
}

class FreshGradHomeData {
  final int totalApplications;
  final int pendingApplications;
  final int approvedApplications;
  final int rejectedApplications;
  final int jobMatches;
  final Set<String> appliedVacancyIds;
  final List<FreshGradRecentActivity> recentActivities;
  final List<JobOpportunity> latestOpportunities;

  const FreshGradHomeData({
    required this.totalApplications,
    required this.pendingApplications,
    required this.approvedApplications,
    required this.rejectedApplications,
    required this.jobMatches,
    required this.appliedVacancyIds,
    required this.recentActivities,
    required this.latestOpportunities,
  });

  FreshGradHomeData copyWith({
    int? totalApplications,
    int? pendingApplications,
    int? approvedApplications,
    int? rejectedApplications,
    int? jobMatches,
    Set<String>? appliedVacancyIds,
    List<FreshGradRecentActivity>? recentActivities,
    List<JobOpportunity>? latestOpportunities,
  }) {
    return FreshGradHomeData(
      totalApplications: totalApplications ?? this.totalApplications,
      pendingApplications: pendingApplications ?? this.pendingApplications,
      approvedApplications: approvedApplications ?? this.approvedApplications,
      rejectedApplications: rejectedApplications ?? this.rejectedApplications,
      jobMatches: jobMatches ?? this.jobMatches,
      appliedVacancyIds: appliedVacancyIds ?? this.appliedVacancyIds,
      recentActivities: recentActivities ?? this.recentActivities,
      latestOpportunities: latestOpportunities ?? this.latestOpportunities,
    );
  }
}

class FreshGradHomeService {
  FreshGradHomeService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static FreshGradHomeData? _cachedData;
  static DateTime? _cachedAt;
  static int? _cachedUserId;
  static const Duration _cacheTtl = Duration(minutes: 2);

  Future<FreshGradHomeData> load({bool forceRefresh = false}) async {
    final userId = UserSession.instance.userId;
    if (userId == null) {
      throw Exception('No logged-in user found');
    }

    if (!forceRefresh &&
        _cachedData != null &&
        _cachedUserId == userId &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _cacheTtl) {
      return _cachedData!;
    }

    final results = await Future.wait<dynamic>([
      _supabase
          .from('application')
          .select(
            'status, vacancy:vacancyid(*)',
          )
          .eq('applicantid', userId)
          .order('submissiondate', ascending: false),
      FreshGradVacancyService.fetchAll(),
      FreshGradVacancyService.fetchLatest(limit: 3),
    ]);

    final applicationRows = (results[0] as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
    final allOpportunities = results[1] as List<JobOpportunity>;
    final latestOpportunities = results[2] as List<JobOpportunity>;

    final totalApplications = applicationRows.length;
    final pendingApplications = applicationRows
        .where((row) => _normalizeStatus(row['status']) == 'PENDING')
        .length;
    final approvedApplications = applicationRows
        .where((row) => _normalizeStatus(row['status']) == 'APPROVED')
        .length;
    final rejectedApplications = applicationRows
        .where((row) => _normalizeStatus(row['status']) == 'REJECTED')
        .length;

    final recentActivities = applicationRows.take(3).map((row) {
      final vacancy = row['vacancy'] == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(row['vacancy'] as Map);

      final vacancyImageUrl = [
        vacancy['vacancy_photo_url'],
        vacancy['vacancy_image_url'],
        vacancy['image_url'],
        vacancy['photo_url'],
        vacancy['thumbnail_url'],
        vacancy['cover_image_url'],
        vacancy['banner_url'],
        vacancy['company_logo_url'],
      ].whereType<Object?>().map((value) => value?.toString() ?? '').firstWhere(
            (value) => value.trim().isNotEmpty,
            orElse: () => '',
          );

      return FreshGradRecentActivity(
        title: vacancy['title']?.toString() ?? 'Untitled opportunity',
        company: vacancy['company_name']?.toString() ?? 'Unknown company',
        status: _normalizeStatus(row['status']),
        imageUrl: vacancyImageUrl.isEmpty ? null : vacancyImageUrl,
      );
    }).toList();

    final homeData = FreshGradHomeData(
      totalApplications: totalApplications,
      pendingApplications: pendingApplications,
      approvedApplications: approvedApplications,
      rejectedApplications: rejectedApplications,
      jobMatches: allOpportunities.length,
      appliedVacancyIds: applicationRows
          .map((row) => row['vacancy'] == null
              ? null
              : Map<String, dynamic>.from(row['vacancy'] as Map))
          .whereType<Map<String, dynamic>>()
          .map((vacancy) => vacancy['vacancyid']?.toString())
          .whereType<String>()
          .toSet(),
      recentActivities: recentActivities,
      latestOpportunities: latestOpportunities,
    );

    _cachedData = homeData;
    _cachedAt = DateTime.now();
    _cachedUserId = userId;
    return homeData;
  }

  static void invalidateCache() {
    _cachedData = null;
    _cachedAt = null;
    _cachedUserId = null;
  }

  static String _normalizeStatus(dynamic status) {
    return (status?.toString().toUpperCase() ?? 'PENDING');
  }
}
