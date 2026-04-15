import 'package:grad_project/Admin/data/datasources/approval_remote_datasource.dart';

import '../../domain/entities/application.dart';
import '../../domain/entities/training.dart';
import '../../domain/repositories/approval_repository.dart';
import '../models/application_model.dart';
import '../models/training_model.dart';

class ApprovalRepositoryImpl implements ApprovalRepository {
  final ApprovalRemoteDataSource remote;

  ApprovalRepositoryImpl(this.remote);

  @override
  Future<List<Application>> getApplications() async {
    final response = await remote.fetchApplications();

    return response
        .map((e) => ApplicationModel.fromMap(e))
        .toList();
  }

  @override
  Future<List<Training>> getTraining() async {
    final response = await remote.fetchTraining();

    return response
        .map((e) => TrainingModel.fromMap({
              ...e,
              'studentname': e['name'],
            }))
        .toList();
  }

  @override
  Future<void> approveApplication(int id) =>
      remote.approveApplication(id);

  @override
  Future<void> rejectApplication(int id, String? reason) =>
      remote.rejectApplication(id, reason);

  @override
  Future<void> approveTraining(int id) =>
      remote.approveTraining(id);

  @override
  Future<void> rejectTraining(int id, String? reason) =>
      remote.rejectTraining(id, reason);
}