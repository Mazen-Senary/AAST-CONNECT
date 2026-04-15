import 'package:grad_project/Admin/domain/entities/dashboard_state_entity.dart';
import 'package:grad_project/Admin/domain/repositories/dashboard_repository.dart';

class GetDashboard {
  final DashboardRepository repository;

  GetDashboard(this.repository);

  Future<DashboardStateEntity> call() {
    return repository.getDashboard();
  }
}