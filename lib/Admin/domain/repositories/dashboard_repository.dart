import 'package:grad_project/Admin/domain/entities/dashboard_state_entity.dart';

abstract class DashboardRepository {
  Future<DashboardStateEntity> getDashboard();
}