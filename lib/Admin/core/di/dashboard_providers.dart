import 'package:grad_project/Admin/data/datasources/dashboard_remote_datasource.dart';
import 'package:grad_project/Admin/domain/repositories/dashboard_repository.dart';
import 'package:grad_project/Admin/domain/usecases/get_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_project/Admin/data/repositories/dashboard_repository_impl.dart';
import '../../presentation/viewmodels/dashboard_notifier.dart';
import '../../presentation/viewmodels/dashboard_state.dart';

final dashboardRepositoryProvider =
    Provider<DashboardRepository>((ref) {
  final client = Supabase.instance.client;

  return DashboardRepositoryImpl(
    DashboardRemoteDataSource(client),
  );
});

final getDashboardProvider = Provider(
  (ref) => GetDashboard(ref.read(dashboardRepositoryProvider)),
);

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(
    ref.read(getDashboardProvider),
  );
});