import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../../services/fresh_grad_vacancy_service.dart';

class OpportunitiesProvider extends ChangeNotifier {
  List<JobOpportunity> _opportunities = [];
  Set<String> _appliedVacancyIds = {};
  bool _isLoading = false;
  String? _error;

  List<JobOpportunity> get opportunities => _opportunities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isApplied(String vacancyId) => _appliedVacancyIds.contains(vacancyId);

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
