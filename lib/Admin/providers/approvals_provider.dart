import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_record.dart';
import '../models/training_record.dart';

final approvalsProvider =
    StateNotifierProvider<ApprovalsNotifier, ApprovalsState>(
  (ref) => ApprovalsNotifier(),
);

class ApprovalsState {
  final String selectedSection;
  final String applicationsFilter;
  final String trainingFilter;
  final List<ApplicationRecord> applications;
  final List<TrainingRecord> trainingRecords;
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
    List<ApplicationRecord>? applications,
    List<TrainingRecord>? trainingRecords,
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

  List<ApplicationRecord> get filteredApplications =>
      applications
          .where((a) => a.status == applicationsFilter)
          .toList();

  List<TrainingRecord> get filteredTrainingHours =>
      trainingRecords
          .where((t) => t.status == trainingFilter)
          .toList();
}
class ApprovalsNotifier extends StateNotifier<ApprovalsState> {
  ApprovalsNotifier() : super(const ApprovalsState()) {
    loadApplications();
    loadTrainingRecords();
  }

  final supabase = Supabase.instance.client;
Future<void> loadApplications() async {
  final response = await supabase.from('application').select();

  final apps = response
      .map<ApplicationRecord>(
          (e) => ApplicationRecord.fromMap(e))
      .toList();

  state = state.copyWith(applications: apps);
}
Future<void> loadTrainingRecords() async {
  final response =
      await supabase.from('trainingrecord').select();

  final records = response.map<TrainingRecord>((row) {
    return TrainingRecord.fromMap({
      ...row,
      'studentname': row['name'],
    });
  }).toList();

  state = state.copyWith(
    trainingRecords: records,
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
Future<void> approveTraining(TrainingRecord record) async {
  final supabase = Supabase.instance.client;

  await supabase
      .from('trainingrecord')
      .update({'status': 'APPROVED'})
      .eq('recordid', record.recordId);

  state = state.copyWith(
    trainingRecords: state.trainingRecords.map((r) {
      if (r.recordId == record.recordId) {
        return r.copyWith(status: 'APPROVED');
      }
      return r;
    }).toList(),
  );
}
Future<void> rejectTraining(
  TrainingRecord record,
  String? reason,
) async {
  final supabase = Supabase.instance.client;

  await supabase
      .from('trainingrecord')
      .update({
        'status': 'REJECTED',
        'rejectionreason': reason,
      })
      .eq('recordid', record.recordId);

  state = state.copyWith(
    trainingRecords: state.trainingRecords.map((r) {
      if (r.recordId == record.recordId) {
        return r.copyWith(
          status: 'REJECTED',
          rejectionReason: reason,
        );
      }
      return r;
    }).toList(),
  );
}
Future<void> approveApplication(ApplicationRecord record) async {
  final supabase = Supabase.instance.client;

  await supabase
      .from('application')
      .update({'status': 'APPROVED'})
      .eq('applicationid', record.applicationId);

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
  ApplicationRecord record,
  String? reason,
) async {
  final supabase = Supabase.instance.client;

  await supabase
      .from('application')
      .update({
        'status': 'REJECTED',
        'rejectionreason': reason,
      })
      .eq('applicationid', record.applicationId);

  state = state.copyWith(
    applications: state.applications.map((a) {
      if (a.applicationId == record.applicationId) {
        return a.copyWith(
          status: 'REJECTED',
          rejectionReason: reason,
        );
      }
      return a;
    }).toList(),
  );
}
}