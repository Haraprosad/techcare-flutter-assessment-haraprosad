import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/logger/app_logger.dart';
import 'package:techcare_assessment_app/core/network/bloc/base_bloc.dart';
import 'package:techcare_assessment_app/core/network/bloc/base_bloc_state.dart';
import 'package:techcare_assessment_app/core/network/error_handling/models/api_call_failure_model.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/entities/balance_summary.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/entities/spending_category.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/usecases/get_cached_dashboard_data_usecase.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/usecases/get_my_dashboard_data_usecase.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/usecases/refresh_dashboard_data_usecase.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// BLoC for managing Dashboard screen state and business logic
///
/// Features:
/// - Load dashboard data with caching support
/// - Pull-to-refresh functionality
/// - Balance visibility toggle with animation
/// - Category-wise transaction filtering
/// - Offline support with cached data
/// - Real-time notification count updates
@lazySingleton
class DashboardBloc extends BaseBloc<DashboardEvent, DashboardState> {
  final GetDashboardDataUseCase _getDashboardDataUseCase;
  final RefreshDashboardDataUseCase _refreshDashboardDataUseCase;
  final GetCachedDashboardDataUseCase _getCachedDashboardDataUseCase;

  DashboardBloc(
    this._getDashboardDataUseCase,
    this._refreshDashboardDataUseCase,
    this._getCachedDashboardDataUseCase,
  ) : super(const DashboardState()) {
    on<LoadDashboardDataEvent>(_onLoadDashboardData);
    on<LoadDashboardDataIfNeededEvent>(_onLoadDashboardDataIfNeeded);
    on<RefreshDashboardDataEvent>(_onRefreshDashboardData);
    on<LoadCachedDataEvent>(_onLoadCachedData);
    on<ToggleBalanceVisibilityEvent>(_onToggleBalanceVisibility);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<UpdateNotificationCountEvent>(_onUpdateNotificationCount);
    on<ClearErrorEvent>(_onClearError);
  }

  /// Load dashboard data (initial load or retry)
  Future<void> _onLoadDashboardData(
    LoadDashboardDataEvent event,
    Emitter<DashboardState> emit,
  ) async {
    AppLogger.i(message: 'Loading dashboard data...');

    await handleApiCall(
      apiCall: () => _getDashboardDataUseCase.call(),
      onSuccess: (DashboardData data) {
        AppLogger.i(message: 'Dashboard data loaded successfully');
        emit(
          state.copyWith(
            dashboardData: data,
            isFromCache: false,
            lastUpdated: DateTime.now(),
            failure: null,
          ),
        );
      },
      onError: (failure) {
        AppLogger.e(
          message:
              'Failed to load dashboard data: ${failure.translatedMessage}',
        );
        // Try to load cached data as fallback
        add(const LoadCachedDataEvent());
      },
      emit: emit,
      showLoader: true,
    );
  }

  /// Load dashboard data only if needed (cache is stale or empty)
  Future<void> _onLoadDashboardDataIfNeeded(
    LoadDashboardDataIfNeededEvent event,
    Emitter<DashboardState> emit,
  ) async {
    AppLogger.i(message: 'Checking if dashboard data needs refresh...');

    // If we have fresh data (less than 5 minutes old), don't reload
    if (state.hasData && !state.needsRefresh) {
      AppLogger.i(
        message:
            'Dashboard data is fresh (${DateTime.now().difference(state.lastUpdated!).inMinutes} minutes old), skipping reload',
      );
      return;
    }

    // If cache is stale or empty, load data
    AppLogger.i(message: 'Dashboard data is stale or empty, loading...');
    add(const LoadDashboardDataEvent());
  }

  /// Refresh dashboard data (pull-to-refresh)
  Future<void> _onRefreshDashboardData(
    RefreshDashboardDataEvent event,
    Emitter<DashboardState> emit,
  ) async {
    AppLogger.i(message: 'Refreshing dashboard data...');

    // Set refreshing state
    emit(state.copyWith(isRefreshing: true, failure: null));

    await handleApiCall(
      apiCall: () => _refreshDashboardDataUseCase.call(),
      onSuccess: (DashboardData data) {
        AppLogger.i(message: 'Dashboard data refreshed successfully');
        emit(
          state.copyWith(
            dashboardData: data,
            isRefreshing: false,
            isFromCache: false,
            lastUpdated: DateTime.now(),
            failure: null,
          ),
        );
      },
      onError: (failure) {
        AppLogger.e(
          message:
              'Failed to refresh dashboard data: ${failure.translatedMessage}',
        );
        emit(state.copyWith(isRefreshing: false, failure: failure));
      },
      emit: emit,
      showLoader: false, // Don't show main loader during refresh
    );
  }

  /// Load cached dashboard data (offline mode)
  Future<void> _onLoadCachedData(
    LoadCachedDataEvent event,
    Emitter<DashboardState> emit,
  ) async {
    AppLogger.i(message: 'Loading cached dashboard data...');

    await handleApiCall(
      apiCall: () => _getCachedDashboardDataUseCase.call(),
      onSuccess: (DashboardData data) {
        AppLogger.i(message: 'Cached dashboard data loaded');
        emit(
          state.copyWith(dashboardData: data, isFromCache: true, failure: null),
        );
      },
      onError: (failure) {
        AppLogger.w(message: 'No cached data available');
        emit(state.copyWith(failure: failure));
      },
      emit: emit,
      showLoader: false,
    );
  }

  /// Toggle balance visibility (for privacy)
  void _onToggleBalanceVisibility(
    ToggleBalanceVisibilityEvent event,
    Emitter<DashboardState> emit,
  ) {
    AppLogger.d(message: 'Toggling balance visibility');
    emit(state.copyWith(isBalanceVisible: !state.isBalanceVisible));
  }

  /// Filter transactions by category
  void _onFilterByCategory(
    FilterByCategoryEvent event,
    Emitter<DashboardState> emit,
  ) {
    AppLogger.d(message: 'Filtering by category: ${event.categoryId ?? "All"}');

    if (event.categoryId == null) {
      // Clear filter - show all transactions
      emit(
        state.copyWith(selectedCategoryId: null, filteredTransactions: null),
      );
    } else {
      // Filter transactions by selected category
      final filtered = state.dashboardData?.recentTransactions
          .where((transaction) => transaction.category.id == event.categoryId)
          .toList();

      emit(
        state.copyWith(
          selectedCategoryId: event.categoryId,
          filteredTransactions: filtered,
        ),
      );
    }
  }

  /// Update notification count
  void _onUpdateNotificationCount(
    UpdateNotificationCountEvent event,
    Emitter<DashboardState> emit,
  ) {
    AppLogger.d(message: 'Updating notification count: ${event.count}');

    if (state.dashboardData != null) {
      final updatedData = state.dashboardData!.copyWith(
        unreadNotifications: event.count,
      );

      emit(state.copyWith(dashboardData: updatedData));
    }
  }

  /// Clear error state
  void _onClearError(ClearErrorEvent event, Emitter<DashboardState> emit) {
    AppLogger.d(message: 'Clearing error state');
    emit(state.copyWith(failure: null));
  }
}
