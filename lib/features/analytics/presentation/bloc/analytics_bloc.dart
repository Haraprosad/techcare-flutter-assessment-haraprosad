import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/network/bloc/base_bloc.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/usecases/get_analytics_data_usecase.dart';
import '../../domain/usecases/get_cached_analytics_data_usecase.dart';
import '../../domain/usecases/refresh_analytics_data_usecase.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

/// Manages analytics screen state - spending trends, category breakdowns, etc.
///
/// Handles loading analytics data for different time periods, caching to reduce
/// API calls, and filtering by categories. Uses the cache-first approach so
/// users see data instantly even when offline.
@lazySingleton
class AnalyticsBloc extends BaseBloc<AnalyticsEvent, AnalyticsState> {
  final GetAnalyticsDataUseCase _getAnalyticsDataUseCase;
  final GetCachedAnalyticsDataUseCase _getCachedAnalyticsDataUseCase;
  final RefreshAnalyticsDataUseCase _refreshAnalyticsDataUseCase;

  // Keep track of current time period selection
  AnalyticsPeriod _currentPeriod = AnalyticsPeriod.thisMonth;
  DateTimeRange _currentDateRange = AnalyticsPeriod.thisMonth.dateRange;

  AnalyticsBloc(
    this._getAnalyticsDataUseCase,
    this._getCachedAnalyticsDataUseCase,
    this._refreshAnalyticsDataUseCase,
  ) : super(AnalyticsState.initial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
    on<LoadAnalyticsIfNeeded>(_onLoadAnalyticsIfNeeded);
    on<UpdateDateRange>(_onUpdateDateRange);
    on<UpdatePeriod>(_onUpdatePeriod);
    on<FilterByCategory>(_onFilterByCategory);
    on<RefreshAnalytics>(_onRefreshAnalytics);
    on<LoadCachedAnalytics>(_onLoadCachedAnalytics);
  }

  /// Loads analytics data from the server for the current date range
  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    AppLogger.i(message: '📊 Loading analytics data...');

    await handleApiCall(
      apiCall: () => _getAnalyticsDataUseCase(
        startDate: _currentDateRange.start,
        endDate: _currentDateRange.end,
      ),
      onSuccess: (AnalyticsData data) {
        AppLogger.i(message: '✅ Analytics data loaded successfully');
        emit(
          state.copyWith(
            data: data,
            selectedPeriod: _currentPeriod,
            dateRange: _currentDateRange,
            isLoading: false,
            isCached: false,
            lastUpdated: DateTime.now(),
            clearFailure: true,
          ),
        );
      },
      onError: (failure) {
        AppLogger.e(
          message: '❌ Failed to load analytics: ${failure.translatedMessage}',
        );
        // API failed, try to show cached data instead
        add(const LoadCachedAnalytics());
      },
      emit: emit,
      showLoader: !state.hasData, // Skip loader if we already have data showing
    );
  }

  /// Smart loading - only fetches if cache is stale or missing.
  ///
  /// Checks if we have recent data (less than 5 min old). If yes, skips the API call.
  /// This saves bandwidth and makes the app feel snappier.
  Future<void> _onLoadAnalyticsIfNeeded(
    LoadAnalyticsIfNeeded event,
    Emitter<AnalyticsState> emit,
  ) async {
    AppLogger.i(message: '🔍 Checking if analytics data needs refresh...');

    // Got fresh data already? Don't waste an API call
    if (state.hasData && !state.needsRefresh) {
      AppLogger.i(
        message:
            'Analytics data is fresh (${DateTime.now().difference(state.lastUpdated!).inMinutes} minutes old), skipping reload',
      );
      return;
    }

    // Data is old or missing, time to reload
    AppLogger.i(message: 'Analytics data is stale or empty, loading...');
    add(const LoadAnalytics());
  }

  /// Updates the date range when user picks custom dates
  Future<void> _onUpdateDateRange(
    UpdateDateRange event,
    Emitter<AnalyticsState> emit,
  ) async {
    AppLogger.d(
      message: '📅 Updating date range: ${event.startDate} - ${event.endDate}',
    );

    _currentDateRange = DateTimeRange(
      start: event.startDate,
      end: event.endDate,
    );
    _currentPeriod = AnalyticsPeriod.custom;

    await handleApiCall(
      apiCall: () => _getAnalyticsDataUseCase(
        startDate: event.startDate,
        endDate: event.endDate,
      ),
      onSuccess: (AnalyticsData data) {
        AppLogger.i(message: '✅ Analytics data loaded for custom range');
        emit(
          state.copyWith(
            data: data,
            selectedPeriod: _currentPeriod,
            dateRange: _currentDateRange,
            isLoading: false,
            lastUpdated: DateTime.now(),
          ),
        );
      },
      onError: (failure) {
        AppLogger.e(
          message:
              '❌ Failed to load analytics for date range: ${failure.translatedMessage}',
        );
      },
      emit: emit,
      showLoader: true,
    );
  }

  Future<void> _onUpdatePeriod(
    UpdatePeriod event,
    Emitter<AnalyticsState> emit,
  ) async {
    AppLogger.d(message: '🔄 Updating period to: ${event.period.displayName}');

    _currentPeriod = event.period;
    _currentDateRange = event.period.dateRange;

    await handleApiCall(
      apiCall: () => _getAnalyticsDataUseCase(
        startDate: _currentDateRange.start,
        endDate: _currentDateRange.end,
      ),
      onSuccess: (AnalyticsData data) {
        AppLogger.i(
          message: '✅ Analytics loaded for period: ${event.period.displayName}',
        );
        emit(
          state.copyWith(
            data: data,
            selectedPeriod: _currentPeriod,
            dateRange: _currentDateRange,
            isLoading: false,
            lastUpdated: DateTime.now(),
          ),
        );
      },
      onError: (failure) {
        AppLogger.e(
          message:
              '❌ Failed to load analytics for period: ${failure.translatedMessage}',
        );
      },
      emit: emit,
      showLoader: true,
    );
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<AnalyticsState> emit,
  ) async {
    if (!state.hasData) return;

    AppLogger.d(
      message: '🔍 Filtering by category: ${event.categoryId ?? "All"}',
    );

    emit(state.copyWith(selectedCategoryId: event.categoryId));
  }

  Future<void> _onRefreshAnalytics(
    RefreshAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    AppLogger.i(message: '🔄 Refreshing analytics data...');

    // Set refreshing state
    emit(state.copyWith(isRefreshing: true, clearFailure: true));

    await handleApiCall(
      apiCall: () => _refreshAnalyticsDataUseCase(
        startDate: _currentDateRange.start,
        endDate: _currentDateRange.end,
      ),
      onSuccess: (AnalyticsData data) {
        AppLogger.i(message: '✅ Analytics data refreshed successfully');
        emit(
          state.copyWith(
            data: data,
            selectedPeriod: _currentPeriod,
            dateRange: _currentDateRange,
            isRefreshing: false,
            isCached: false,
            lastUpdated: DateTime.now(),
            clearFailure: true,
          ),
        );
      },
      onError: (failure) {
        AppLogger.e(
          message:
              '❌ Failed to refresh analytics: ${failure.translatedMessage}',
        );
        emit(state.copyWith(isRefreshing: false));
      },
      emit: emit,
      showLoader: false, // Don't show full loader for refresh
    );
  }

  Future<void> _onLoadCachedAnalytics(
    LoadCachedAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    AppLogger.d(message: '💾 Loading cached analytics data...');

    await handleApiCall(
      apiCall: () => _getCachedAnalyticsDataUseCase(
        startDate: _currentDateRange.start,
        endDate: _currentDateRange.end,
      ),
      onSuccess: (AnalyticsData data) {
        AppLogger.i(message: '✅ Cached analytics data loaded');
        emit(
          state.copyWith(
            data: data,
            selectedPeriod: _currentPeriod,
            dateRange: _currentDateRange,
            isCached: true,
            clearFailure: true,
          ),
        );
      },
      onError: (failure) {
        AppLogger.w(message: '⚠️ No cached data available');
      },
      emit: emit,
      showLoader: false, // Don't show loader when loading from cache
    );
  }
}
