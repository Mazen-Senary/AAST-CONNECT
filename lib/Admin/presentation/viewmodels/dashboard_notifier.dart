import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_dashboard.dart';
import 'dashboard_state.dart';

class DashboardNotifier extends StateNotifier<DashboardState> {
  final GetDashboard getDashboard;

  DashboardNotifier(this.getDashboard) : super(DashboardState()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final data = await getDashboard();

      state = state.copyWith(
        isLoading: false,
        data: data,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}