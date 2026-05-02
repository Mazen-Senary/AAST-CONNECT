//new opportunities screen with save program feature and better error handling
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../../services/vacancy_service.dart';
import '../../models/vacancy.dart';
import '../../widgets/app_bar_with_logout.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/opportunities_wigdet/student_opportunities_search_bar.dart';
import '../../widgets/opportunities_wigdet/student_opportunities_filter_chips.dart';
import '../../widgets/opportunities_wigdet/student_opportunities_program_card.dart';
import '../../widgets/opportunities_wigdet/student_opportunities_apply_modal.dart';
import '../../widgets/opportunities_wigdet/student_opportunities_details_modal.dart';
import 'student_tracking.dart';

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

  // Method channel for Android
  static const platform = MethodChannel('com.aastconnect.app/url_launcher');

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

      // Debug: Log external vacancies
      for (var v in vacancies) {
        if (v.applicationMethod == 'EXTERNAL') {
          print('DEBUG: Loaded external vacancy: "${v.title}"');
          print('  - Application Method: ${v.applicationMethod}');
          print('  - External URL: "${v.externalApplyUrl}"');
        }
      }

      // load user applications
      _applications = await _vacancyService.getUserApplications(
        _currentUserId!,
      );

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
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success',
            message: 'Removed from saved programs',
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        await supabase.from('saved_programs').insert({
          'studentid': _currentUserId ?? 5,
          'vacancyid': vacancyId,
        });
        setState(() => _savedVacancyIds.add(vacancyId));
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success',
            message: 'Saved to your programs!',
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error',
          message: 'Error: $e',
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          final hasApplied = _applications.any(
            (app) => app['vacancyid'] == vacancy.vacancyId,
          );
          program['applied'] = hasApplied;

          // Debug logging
          if (vacancy.applicationMethod == 'EXTERNAL') {
            print('DEBUG: External vacancy "${vacancy.title}"');
            print('  - externalApplyUrl: "${vacancy.externalApplyUrl}"');
            print(
              '  - program externalApplyUrl: "${program['externalApplyUrl']}"',
            );
          }

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
    // Check if application is external
    print('=== DEBUG: _showApplyModal ===');
    print('applicationMethod: ${program['applicationMethod']}');
    print('externalApplyUrl: ${program['externalApplyUrl']}');
    print('Program keys: ${program.keys.toList()}');

    if (program['applicationMethod'] == 'EXTERNAL' &&
        program['externalApplyUrl'] != null) {
      final url = program['externalApplyUrl'].toString().trim();
      print('URL to launch: "$url"');
      print('URL is empty: ${url.isEmpty}');
      if (url.isNotEmpty) {
        _launchExternalUrl(url);
        return;
      } else {
        print('ERROR: URL is empty string');
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: const AwesomeSnackbarContent(
            title: 'Empty URL',
            message: 'External URL is empty in database',
            contentType: ContentType.warning,
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        return;
      }
    }

    print('Not external or URL is null, showing internal apply modal');
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

  Future<void> _launchExternalUrl(String url) async {
    try {
      print('=== DEBUG: _launchExternalUrl ===');
      print('Input URL: "$url"');
      print('Input URL length: ${url.length}');

      // Ensure URL has a scheme
      String urlToLaunch = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        urlToLaunch = 'https://$url';
        print('Added https:// scheme -> "$urlToLaunch"');
      }

      final uri = Uri.parse(urlToLaunch);
      print('Parsed URI: $uri');
      print('URI scheme: ${uri.scheme}');
      print('URI host: ${uri.host}');

      // Try platform default first (works on most devices)
      print('Trying LaunchMode.platformDefault...');
      try {
        bool success = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (success) {
          print('URL launched successfully with platformDefault!');
          return;
        } else {
          print('launchUrl returned false with platformDefault');
        }
      } catch (e1) {
        print('platformDefault failed: $e1');
      }

      // Fallback 1: Try in-app browser
      print('Trying LaunchMode.inAppBrowserView...');
      try {
        bool success = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        if (success) {
          print('URL launched successfully with inAppBrowserView!');
          return;
        }
      } catch (e2) {
        print('inAppBrowserView failed: $e2');
      }

      // Fallback 2: Try Android native (for emulator)
      print('Trying Android native method...');
      try {
        await platform.invokeMethod('launchURL', {'url': urlToLaunch});
        print('URL launched successfully with Android native method!');
        return;
      } catch (e3) {
        print('Android native method failed: $e3');
      }

      // All attempts failed
      print('ERROR: All launch attempts failed');
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 4),
        content: AwesomeSnackbarContent(
          title: 'Could not open URL',
          message: urlToLaunch,
          contentType: ContentType.failure,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print('EXCEPTION in _launchExternalUrl: $e');
      print('Exception type: ${e.runtimeType}');
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error',
          message: e.toString(),
          contentType: ContentType.failure,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
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
      appBar: AppBarWithLogout(
        title: "AAST Connect",
        unreadNotificationCount: 0,
        onTimelinePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const StudentTrackingScreen(),
            ),
          );
        },
        onLogout: () {},
      ),
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
                      return FutureBuilder<bool>(
                        future: _vacancyService.hasUserApplied(
                          program['vacancyId'].toString(),
                          _currentUserId ?? 5,
                        ),
                        builder: (context, snapshot) {
                          final hasApplied = snapshot.data ?? false;
                          return StudentOpportunitiesProgramCard(
                            program: {...program, 'applied': hasApplied},
                            onViewDetails: () =>
                                _showDetailsModal(context, program),
                            onApply: () => _showApplyModal(context, program),
                            isSaved: _savedVacancyIds.contains(
                              program['vacancyId'],
                            ),
                            onSave: () => _toggleSave(program['vacancyId']),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
