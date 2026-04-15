import '../../domain/entities/dashboard_state_entity.dart';

class DashboardState {
  final bool isLoading;
  final String? error;
  final DashboardStateEntity? data;

  DashboardState({
    this.isLoading = false,
    this.error,
    this.data,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    DashboardStateEntity? data,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      data: data ?? this.data,
    );
  }
}