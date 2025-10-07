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

@injectable
class AnalyticsBloc extends BaseBloc<AnalyticsEvent, AnalyticsState> {
  final GetAnalyticsDataUseCase _getAnalyticsDataUseCase;
  final GetCachedAnalyticsDataUseCase _getCachedAnalyticsDataUseCase;
  final RefreshAnalyticsDataUseCase _refreshAnalyticsDataUseCase;

  AnalyticsPeriod _currentPeriod = AnalyticsPeriod.thisMonth;
  DateTimeRange _currentDateRange = AnalyticsPeriod.thisMonth.dateRange;

  AnalyticsBloc(
    this._getAnalyticsDataUseCase,
    this._getCachedAnalyticsDataUseCase,
    this._refreshAnalyticsDataUseCase,
  ) : super(AnalyticsState.initial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
    on<UpdateDateRange>(_onUpdateDateRange);
    on<UpdatePeriod>(_onUpdatePeriod);
    on<FilterByCategory>(_onFilterByCategory);
    on<RefreshAnalytics>(_onRefreshAnalytics);
    on<LoadCachedAnalytics>(_onLoadCachedAnalytics);
  }

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
          ),
        );
      },
      onError: (failure) {
        AppLogger.e(
          message: '❌ Failed to load analytics: ${failure.translatedMessage}',
        );
      },
      emit: emit,
      showLoader: true,
    );
  }

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
            isLoading: false,
          ),
        );
      },
      onError: (failure) {
        AppLogger.e(
          message:
              '❌ Failed to refresh analytics: ${failure.translatedMessage}',
        );
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
            isLoading: false,
          ),
        );
      },
      onError: (failure) {
        AppLogger.w(message: '⚠️ No cached data available, loading fresh data');
        // If no cache, load fresh data
        add(const LoadAnalytics());
      },
      emit: emit,
      showLoader: true,
    );
  }
}
