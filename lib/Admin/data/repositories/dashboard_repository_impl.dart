import 'package:grad_project/Admin/data/datasources/dashboard_remote_datasource.dart';
import 'package:grad_project/Admin/domain/entities/dashboard_state_entity.dart';
import 'package:grad_project/Admin/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remote;

  DashboardRepositoryImpl(this.remote);

  @override
  Future<DashboardStateEntity> getDashboard() async {
    return await remote.getDashboard();
    
  }
}