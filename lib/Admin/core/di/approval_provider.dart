import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_project/Admin/data/datasources/approval_remote_datasource.dart';
import 'package:grad_project/Admin/domain/usecases/approve_application.dart';
import 'package:grad_project/Admin/domain/usecases/approve_training.dart';
import 'package:grad_project/Admin/domain/usecases/get_applications.dart';
import 'package:grad_project/Admin/domain/usecases/get_training.dart';
import 'package:grad_project/Admin/domain/usecases/reject_application.dart';
import 'package:grad_project/Admin/domain/usecases/reject_training.dart';
import 'package:grad_project/Admin/data/repositories/approval_repository_impl.dart';
import 'package:grad_project/Admin/presentation/viewmodels/approval_notifier.dart';

final approvalsProvider =
    StateNotifierProvider<ApprovalsNotifier, ApprovalsState>((ref) {
  final remote = ApprovalRemoteDataSource();
  final repo = ApprovalRepositoryImpl(remote);

  return ApprovalsNotifier(
    GetApplications(repo),
    GetTraining(repo),
    ApproveApplication(repo),
    RejectApplication(repo),
    ApproveTraining(repo),
    RejectTraining(repo),
  );
});