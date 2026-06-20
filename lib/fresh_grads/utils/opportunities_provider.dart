import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../../services/fresh_grad_vacancy_service.dart';

class OpportunitiesProvider extends ChangeNotifier {
  List<JobOpportunity> _opportunities = [];
  bool _isLoading = false;
  String? _error;

  List<JobOpportunity> get opportunities => _opportunities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _opportunities = await FreshGradVacancyService.fetchAll();
    } catch (e) {
      _error = 'Failed to load. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
