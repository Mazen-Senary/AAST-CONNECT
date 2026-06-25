import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../../services/app_refresh_service.dart';
import '../../services/fresh_grad_vacancy_service.dart';
import '../../services/user_session.dart';

class OpportunitiesProvider extends ChangeNotifier {
  List<JobOpportunity> _opportunities = [];
  Set<String> _appliedVacancyIds = {};
  bool _isLoading = false;
  String? _error;

  OpportunitiesProvider() {
    AppRefreshService.instance.addListener(_handleRefreshSignal);
  }

  List<JobOpportunity> get opportunities => _opportunities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isApplied(String vacancyId) => _appliedVacancyIds.contains(vacancyId);

  @override
  void dispose() {
    AppRefreshService.instance.removeListener(_handleRefreshSignal);
    super.dispose();
  }

  void reset() {
    _opportunities = [];
    _appliedVacancyIds = {};
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void _handleRefreshSignal() {
    if (UserSession.instance.role != 'FRESH_GRAD' ||
        UserSession.instance.userId == null) {
      return;
    }
    if (_isLoading) return;
    if (_opportunities.isEmpty && _appliedVacancyIds.isEmpty) return;
    load();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        FreshGradVacancyService.fetchAll(),
        FreshGradVacancyService.fetchAppliedVacancyIds(),
      ]);
      _opportunities = results[0] as List<JobOpportunity>;
      _appliedVacancyIds = results[1] as Set<String>;
    } catch (e) {
      _error = 'Failed to load. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Call this immediately after a successful application submission
  /// so the UI updates without waiting for a full reload.
  void markApplied(String vacancyId) {
    _appliedVacancyIds.add(vacancyId);
    notifyListeners();
  }
}
