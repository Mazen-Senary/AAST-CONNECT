import '../entities/application.dart';
import '../entities/training.dart';

abstract class ApprovalRepository {
  Future<List<Application>> getApplications();
  Future<List<Training>> getTraining();

  Future<void> approveApplication(int id);
  Future<void> rejectApplication(int id, String? reason);

  Future<void> approveTraining(int id);
  Future<void> rejectTraining(int id, String? reason);
}