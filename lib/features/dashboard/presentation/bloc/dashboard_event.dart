part of 'dashboard_bloc.dart';

/// Base class for Dashboard BLoC events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load dashboard data (initial load or retry)
class LoadDashboardDataEvent extends DashboardEvent {
  const LoadDashboardDataEvent();
}

/// Load dashboard data only if cache is stale (older than 5 minutes) or empty
class LoadDashboardDataIfNeededEvent extends DashboardEvent {
  const LoadDashboardDataIfNeededEvent();
}

/// Refresh dashboard data (pull-to-refresh)
class RefreshDashboardDataEvent extends DashboardEvent {
  const RefreshDashboardDataEvent();
}

/// Load cached dashboard data (offline mode)
class LoadCachedDataEvent extends DashboardEvent {
  const LoadCachedDataEvent();
}

/// Toggle balance visibility
class ToggleBalanceVisibilityEvent extends DashboardEvent {
  const ToggleBalanceVisibilityEvent();
}

/// Filter transactions by category
class FilterByCategoryEvent extends DashboardEvent {
  final String? categoryId;

  const FilterByCategoryEvent({this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

/// Update notification count
class UpdateNotificationCountEvent extends DashboardEvent {
  final int count;

  const UpdateNotificationCountEvent(this.count);

  @override
  List<Object?> get props => [count];
}

/// Clear error state
class ClearErrorEvent extends DashboardEvent {
  const ClearErrorEvent();
}
