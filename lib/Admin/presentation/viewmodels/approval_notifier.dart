import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_project/Admin/domain/entities/application.dart';
import 'package:grad_project/Admin/domain/entities/training.dart';
import 'package:grad_project/Admin/domain/usecases/approve_application.dart';
import 'package:grad_project/Admin/domain/usecases/approve_training.dart';
import 'package:grad_project/Admin/domain/usecases/get_applications.dart';
import 'package:grad_project/Admin/domain/usecases/get_training.dart';
import 'package:grad_project/Admin/domain/usecases/reject_application.dart';
import 'package:grad_project/Admin/domain/usecases/reject_training.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ApplicationSortOption { none, dateAsc, dateDesc, gpaDesc, gpaAsc }

class ApprovalsState {
  final bool hasNewData;
  final String selectedSection;
  final String applicationsFilter;
  final String trainingFilter;
  final List<Application> applications;
  final List<Training> trainingRecords;
  final bool loadingTraining;
  final ApplicationSortOption applicationSort;

  const ApprovalsState({
    this.hasNewData = false,
    this.selectedSection = 'applications',
    this.applicationsFilter = 'PENDING',
    this.trainingFilter = 'PENDING',
    this.applications = const [],
    this.trainingRecords = const [],
    this.loadingTraining = true,
    this.applicationSort = ApplicationSortOption.none,
  });

  ApprovalsState copyWith({
    bool? hasNewData,
    String? selectedSection,
    String? applicationsFilter,
    String? trainingFilter,
    List<Application>? applications,
    List<Training>? trainingRecords,
    bool? loadingTraining,
    ApplicationSortOption? applicationSort,
  }) {
    return ApprovalsState(
      hasNewData: hasNewData ?? this.hasNewData,
      selectedSection: selectedSection ?? this.selectedSection,
      applicationsFilter: applicationsFilter ?? this.applicationsFilter,
      trainingFilter: trainingFilter ?? this.trainingFilter,
      applications: applications ?? this.applications,
      trainingRecords: trainingRecords ?? this.trainingRecords,
      loadingTraining: loadingTraining ?? this.loadingTraining,
      applicationSort: applicationSort ?? this.applicationSort,
    );
  }
  Map<String, List<Application>> get groupedApplications {
  final map = <String, List<Application>>{};
  for (final a in filteredApplications) {
    map.putIfAbsent(a.studentName, () => []).add(a);
  }
  return map;
}

  /*
  List<Application> get filteredApplications =>
      applications.where((a) => a.status == applicationsFilter).toList();
*/
  List<Application> get filteredApplications {
    var list = applications
        .where((a) => a.status == applicationsFilter)
        .toList();

    switch (applicationSort) {
      case ApplicationSortOption.dateAsc:
        list.sort((a, b) => a.submissionDate.compareTo(b.submissionDate));
        break;
      case ApplicationSortOption.dateDesc:
        list.sort((a, b) => b.submissionDate.compareTo(a.submissionDate));
        break;
      case ApplicationSortOption.gpaDesc:
        list.sort((a, b) => (b.gpa ?? 0).compareTo(a.gpa ?? 0));
        break;
      case ApplicationSortOption.gpaAsc:
        list.sort((a, b) => (a.gpa ?? 0).compareTo(b.gpa ?? 0));
        break;
      case ApplicationSortOption.none:
        break;
    }

    return list;
  }

  List<Training> get filteredTrainingHours =>
      trainingRecords.where((t) => t.status == trainingFilter).toList();
      
  Map<String, List<Training>> get groupedTraining {
    final map = <String, List<Training>>{};
    for (final t in filteredTrainingHours) {
      map.putIfAbsent(t.studentName, () => []).add(t);
    }
    return map;
  }
}

class ApprovalsNotifier extends StateNotifier<ApprovalsState> {
  final GetApplications getApplications;
  final GetTraining getTraining;
  final ApproveApplication approveApp;
  final RejectApplication rejectApp;
  final ApproveTraining approveTrain;
  final RejectTraining rejectTrain;
  RealtimeChannel? _channel;

  ApprovalsNotifier(
    this.getApplications,
    this.getTraining,
    this.approveApp,
    this.rejectApp,
    this.approveTrain,
    this.rejectTrain,
  ) : super(const ApprovalsState()) {
    loadAll();
    _subscribeToChanges();
  }
/*
  Future<void> loadAll() async {
    final apps = await getApplications();
    final training = await getTraining();

    state = state.copyWith(
      applications: apps,
      trainingRecords: training,
      loadingTraining: false,
    );
  }
*/
Future<void> loadAll() async {
  // Load only the current filter's status to reduce data
  final apps = await getApplications();
  final training = await getTraining();

  state = state.copyWith(
    applications: apps,
    trainingRecords: training,
    loadingTraining: false,
  );
}
  void changeSection(String section) {
    state = state.copyWith(selectedSection: section);
  }

  void changeFilter(String filter) {
    if (state.selectedSection == 'applications') {
      state = state.copyWith(applicationsFilter: filter);
    } else {
      state = state.copyWith(trainingFilter: filter);
    }
  }

  void _subscribeToChanges() {
    _channel = Supabase.instance.client
        .channel('approvals_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'application',
          callback: (payload) => state = state.copyWith(hasNewData: true),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'trainingrecord',
          callback: (payload) => state = state.copyWith(hasNewData: true),
        )
        .subscribe();
  }

  void dismissNewData() {
    state = state.copyWith(hasNewData: false);
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  void toggleTrainingExpanded(int id) {
    final updated = state.trainingRecords.map((r) {
      if (r.recordId == id) {
        return r.copyWith(expanded: !r.expanded);
      }
      return r;
    }).toList();

    state = state.copyWith(trainingRecords: updated);
  }

  void updateApplicationSort(ApplicationSortOption option) {
    state = state.copyWith(applicationSort: option);
  }

  void toggleApplicationExpanded(int id) {
    final updated = state.applications.map((a) {
      if (a.applicationId == id) {
        return a.copyWith(expanded: !a.expanded);
      }
      return a;
    }).toList();

    state = state.copyWith(applications: updated);
  }

  Future<void> approveApplication(Application record) async {
    await approveApp(record.applicationId);

    state = state.copyWith(
      applications: state.applications.map((a) {
        if (a.applicationId == record.applicationId) {
          return a.copyWith(status: 'APPROVED');
        }
        return a;
      }).toList(),
    );
  }

  Future<void> rejectApplication(Application record, String? reason) async {
    await rejectApp(record.applicationId, reason);

    state = state.copyWith(
      applications: state.applications.map((a) {
        if (a.applicationId == record.applicationId) {
          return a.copyWith(status: 'REJECTED', rejectionReason: reason);
        }
        return a;
      }).toList(),
    );
  }

  Future<void> approveTraining(Training record) async {
    await approveTrain(record.recordId);

    state = state.copyWith(
      trainingRecords: state.trainingRecords.map((t) {
        if (t.recordId == record.recordId) {
          return t.copyWith(status: 'APPROVED');
        }
        return t;
      }).toList(),
    );
  }

  Future<void> rejectTraining(Training record, String? reason) async {
    await rejectTrain(record.recordId, reason);

    state = state.copyWith(
      trainingRecords: state.trainingRecords.map((t) {
        if (t.recordId == record.recordId) {
          return t.copyWith(status: 'REJECTED', rejectionReason: reason);
        }
        return t;
      }).toList(),
    );
  }
}
