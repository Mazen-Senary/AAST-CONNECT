
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_project/Admin/domain/entities/application.dart';
import 'package:grad_project/Admin/domain/entities/training.dart';
import 'package:grad_project/Admin/domain/usecases/approve_application.dart';
import 'package:grad_project/Admin/domain/usecases/approve_training.dart';
import 'package:grad_project/Admin/domain/usecases/get_applications.dart';
import 'package:grad_project/Admin/domain/usecases/get_training.dart';
import 'package:grad_project/Admin/domain/usecases/reject_application.dart';
import 'package:grad_project/Admin/domain/usecases/reject_training.dart';

class ApprovalsState {
  final String selectedSection;
  final String applicationsFilter;
  final String trainingFilter;
  final List<Application> applications;
  final List<Training> trainingRecords;
  final bool loadingTraining;

  const ApprovalsState({
    this.selectedSection = 'applications',
    this.applicationsFilter = 'PENDING',
    this.trainingFilter = 'PENDING',
    this.applications = const [],
    this.trainingRecords = const [],
    this.loadingTraining = true,
  });

  ApprovalsState copyWith({
    String? selectedSection,
    String? applicationsFilter,
    String? trainingFilter,
    List<Application>? applications,
    List<Training>? trainingRecords,
    bool? loadingTraining,
  }) {
    return ApprovalsState(
      selectedSection: selectedSection ?? this.selectedSection,
      applicationsFilter:
          applicationsFilter ?? this.applicationsFilter,
      trainingFilter: trainingFilter ?? this.trainingFilter,
      applications: applications ?? this.applications,
      trainingRecords:
          trainingRecords ?? this.trainingRecords,
      loadingTraining:
          loadingTraining ?? this.loadingTraining,
    );
  }

  List<Application> get filteredApplications =>
      applications
          .where((a) => a.status == applicationsFilter)
          .toList();

  List<Training> get filteredTrainingHours =>
      trainingRecords
          .where((t) => t.status == trainingFilter)
          .toList();
}

class ApprovalsNotifier extends StateNotifier<ApprovalsState> {
  final GetApplications getApplications;
  final GetTraining getTraining;
  final ApproveApplication approveApp;
  final RejectApplication rejectApp;
  final ApproveTraining approveTrain;
  final RejectTraining rejectTrain;

  ApprovalsNotifier(
    this.getApplications,
    this.getTraining,
    this.approveApp,
    this.rejectApp,
    this.approveTrain,
    this.rejectTrain,
  ) : super(const ApprovalsState()) {
    loadAll();
  }

  Future<void> loadAll() async {
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

  void toggleTrainingExpanded(int id) {
    final updated = state.trainingRecords.map((r) {
      if (r.recordId == id) {
        return r.copyWith(expanded: !r.expanded);
      }
      return r;
    }).toList();

    state = state.copyWith(trainingRecords: updated);
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

  Future<void> rejectApplication(
      Application record, String? reason) async {
    await rejectApp(record.applicationId, reason);

    state = state.copyWith(
      applications: state.applications.map((a) {
        if (a.applicationId == record.applicationId) {
          return a.copyWith(
              status: 'REJECTED', rejectionReason: reason);
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

  Future<void> rejectTraining(
      Training record, String? reason) async {
    await rejectTrain(record.recordId, reason);

    state = state.copyWith(
      trainingRecords: state.trainingRecords.map((t) {
        if (t.recordId == record.recordId) {
          return t.copyWith(
              status: 'REJECTED', rejectionReason: reason);
        }
        return t;
      }).toList(),
    );
  }
}