
//new opportunities screen with save program feature and better error handling

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
  int? _profileId;

  final VacancyService _vacancyService = VacancyService();
  List<Vacancy> _vacancies = [];
  List<Map<String, dynamic>> _applications = [];
  List<String> _savedVacancyIds = [];
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
      _currentUserId = 5; // temp hardcode
      // fetch profileId
      final supabase = Supabase.instance.client;
      final profile = await supabase
          .from('profile')
          .select('profileid')
          .eq('userid', _currentUserId!)
          .maybeSingle();
      _profileId = profile?['profileid'];

      // load vacancies
      final vacancies = await _vacancyService.getStudentVacancies();

      // load user applications
      _applications = await _vacancyService.getUserApplications(_currentUserId!);

      // load saved programs
      await _loadSavedPrograms();

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

  Future<void> _loadSavedPrograms() async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('saved_programs')
          .select('vacancyid')
          .eq('studentid', _currentUserId ?? 5);
      setState(() {
        _savedVacancyIds = List<String>.from(
          data.map((row) => row['vacancyid'].toString()),
        );
      });
    } catch (e) {
      print('Error loading saved programs: $e');
    }
  }

  Future<void> _toggleSave(String vacancyId) async {
    try {
      final supabase = Supabase.instance.client;
      final isSaved = _savedVacancyIds.contains(vacancyId);

      if (isSaved) {
        await supabase
            .from('saved_programs')
            .delete()
            .eq('studentid', _currentUserId ?? 5)
            .eq('vacancyid', vacancyId);
        setState(() => _savedVacancyIds.remove(vacancyId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Removed from saved programs")),
        );
      } else {
        await supabase.from('saved_programs').insert({
          'studentid': _currentUserId ?? 5,
          'vacancyid': vacancyId,
        });
        setState(() => _savedVacancyIds.add(vacancyId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Saved to your programs!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredPrograms {
    return _vacancies
        .where((vacancy) {
      final program = vacancy.toDisplayMap();
      final matchesSearch =
          _searchQuery.isEmpty ||
              program['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
              program['company'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
              program['category'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter =
          _selectedFilter == 'All' ||
              program['category'] == _selectedFilter;

      return matchesSearch && matchesFilter;
    })
        .map((vacancy) {
      final program = vacancy.toDisplayMap();
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

  // void _showApplyModal(BuildContext context, Map<String, dynamic> program) {
  //   StudentOpportunitiesApplyModal.show(
  //     context,
  //     program,
  //         () => _submitApplication(program),
  //   );
  // }
  void _showApplyModal(BuildContext context, Map<String, dynamic> program) {
    StudentOpportunitiesApplyModal.show(
      context,
      program,
          () => _loadData(),
      profileId: _profileId, // need to add this variable
      studentId: _currentUserId,
      collegeId: 'STD2023005', // temp hardcode
      studentName: 'Mohamed Tarek', // temp hardcode
    );
  }


  Future<void> _submitApplication(Map<String, dynamic> program) async {
    try {
      await _vacancyService.submitApplication(
        vacancyId: program['vacancyId'],
        applicantId: _currentUserId ?? 5,
        applicantName: 'Current User',
        collegeId: 'STD2023005',
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
      program,
      () => _showApplyModal(context, program),
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
          StudentOpportunitiesSearchBar(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            onClearSearch: () => setState(() {
              _searchController.clear();
              _searchQuery = '';
            }),
            onToggleFilters: () => setState(() => _showFilters = !_showFilters),
            showFilters: _showFilters,
          ),

          if (_showFilters) ...[
            StudentOpportunitiesFilterChips(
              categories: _categories,
              selectedFilter: _selectedFilter,
              onFilterSelected: (category) =>
                  setState(() => _selectedFilter = category),
            ),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_filteredPrograms.length} programs available",
                  style: const TextStyle(color: Colors.grey),
                ),
                if (_searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    }),
                    child: const Text('Clear Search'),
                  ),
              ],
            ),
          ),

          Expanded(
            child: _filteredPrograms.isEmpty
                ? const Center(
              child: Text(
                "No programs found",
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredPrograms.length,
              itemBuilder: (context, index) {
                final program = _filteredPrograms[index];
                return StudentOpportunitiesProgramCard(
                  program: program,
                  onViewDetails: () => _showDetailsModal(context, program),
                  onApply: () => _showApplyModal(context, program),
                  isSaved: _savedVacancyIds.contains(program['vacancyId']),
                  onSave: () => _toggleSave(program['vacancyId']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}