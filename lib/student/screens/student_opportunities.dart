import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/vacancy_service.dart';
import '../../models/vacancy.dart';
import '../../widgets/app_bar_with_logout.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/student_opportunities_search_bar.dart';
import '../../widgets/student_opportunities_filter_chips.dart';
import '../../widgets/student_opportunities_program_card.dart';
import '../../widgets/student_opportunities_apply_modal.dart';
import '../../widgets/student_opportunities_details_modal.dart';

class StudentOpportunities extends StatefulWidget {
  const StudentOpportunities({super.key});

  @override
  State<StudentOpportunities> createState() => _StudentOpportunitiesState();
}

class _StudentOpportunitiesState extends State<StudentOpportunities> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _showFilters = false;
  bool _isLoading = true;
  String? _error;

  final VacancyService _vacancyService = VacancyService();
  List<Vacancy> _vacancies = [];
  List<Map<String, dynamic>> _applications = [];
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // For now, we'll use a mock user ID. In a real app, you'd get this from your user table
        _currentUserId = 1; // This should come from your users table
      }

      // Load vacancies
      final vacancies = await _vacancyService.getStudentVacancies();

      // Load user applications if user is logged in
      if (_currentUserId != null) {
        _applications = await _vacancyService.getUserApplications(
          _currentUserId!,
        );
      }

      setState(() {
        _vacancies = vacancies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load opportunities: $e';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredPrograms {
    return _vacancies
        .where((vacancy) {
          final program = vacancy.toDisplayMap();
          final matchesSearch =
              _searchQuery.isEmpty ||
              program['title'].toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              program['company'].toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              program['category'].toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );

          final matchesFilter =
              _selectedFilter == 'All' ||
              program['category'] == _selectedFilter;

          return matchesSearch && matchesFilter;
        })
        .map((vacancy) {
          final program = vacancy.toDisplayMap();
          // Check if user has applied to this vacancy
          final hasApplied = _applications.any(
            (app) => app['vacancyid'] == vacancy.vacancyId,
          );
          program['applied'] = hasApplied;
          return program;
        })
        .toList();
  }

  List<String> get _categories {
    if (_vacancies.isEmpty) return ['All'];
    final categories = _vacancies
        .map((v) => v.toDisplayMap()['category'] as String)
        .toSet()
        .toList();
    categories.insert(0, 'All');
    return categories;
  }

  void _showApplyModal(BuildContext context, Map<String, dynamic> program) {
    StudentOpportunitiesApplyModal.show(
      context,
      program,
      () => _submitApplication(program),
    );
  }

  Future<void> _submitApplication(Map<String, dynamic> program) async {
    try {
      await _vacancyService.submitApplication(
        vacancyId: program['vacancyId'],
        applicantId: _currentUserId ?? 1,
        applicantName: 'Current User',
        collegeId: 'STUDENT001',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Application Submitted Successfully!")),
      );

      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to submit application: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDetailsModal(BuildContext context, Map<String, dynamic> program) {
    StudentOpportunitiesDetailsModal.show(
      context,
      program['title'],
      program['company'],
      program['hours'],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          title: Text(
            "AAST Connect",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        body: const LoadingWidget(),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          title: Text(
            "AAST Connect",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const AppBarWithLogout(title: "AAST Connect"),
      body: Column(
        children: [
          // Search Bar
          StudentOpportunitiesSearchBar(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onClearSearch: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
              });
            },
            onToggleFilters: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            showFilters: _showFilters,
          ),

          // Filters
          if (_showFilters) ...[
            StudentOpportunitiesFilterChips(
              categories: _categories,
              selectedFilter: _selectedFilter,
              onFilterSelected: (category) {
                setState(() {
                  _selectedFilter = category;
                });
              },
            ),
          ],

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${_filteredPrograms.length} programs available",
                style: const TextStyle(color: Colors.grey),
              ),
              if (_searchQuery.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                  child: const Text('Clear Search'),
                ),
            ],
          ),

          // Programs List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredPrograms.length,
              itemBuilder: (context, index) {
                final program = _filteredPrograms[index];
                return StudentOpportunitiesProgramCard(
                  program: program,
                  onViewDetails: () => _showDetailsModal(context, program),
                  onApply: () => _showApplyModal(context, program),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
