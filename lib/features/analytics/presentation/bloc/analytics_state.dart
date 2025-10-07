import 'package:equatable/equatable.dart';
import '../../../../core/network/bloc/base_bloc_state.dart';
import '../../../../core/network/error_handling/models/api_call_failure_model.dart';
import '../../domain/entities/analytics_data.dart';
import 'analytics_event.dart';

/// State for Analytics BLoC
class AnalyticsState extends Equatable implements BaseBlocState {
  // Loading states
  @override
  final bool isLoading;
  final bool isRefreshing;

  // Error handling
  @override
  final ApiCallFailureModel? failure;

  // Analytics data
  final AnalyticsData? data;

  // Period and date range
  final AnalyticsPeriod selectedPeriod;
  final DateTimeRange dateRange;

  // Filter state
  final String? selectedCategoryId;

  // Cache status
  final bool isCached;

  const AnalyticsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.failure,
    this.data,
    this.selectedPeriod = AnalyticsPeriod.thisMonth,
    required this.dateRange,
    this.selectedCategoryId,
    this.isCached = false,
  });

  /// Factory for initial state
  factory AnalyticsState.initial() {
    final period = AnalyticsPeriod.thisMonth;
    return AnalyticsState(dateRange: period.dateRange, selectedPeriod: period);
  }

  @override
  AnalyticsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    ApiCallFailureModel? failure,
    AnalyticsData? data,
    AnalyticsPeriod? selectedPeriod,
    DateTimeRange? dateRange,
    String? selectedCategoryId,
    bool? isCached,
    bool clearFailure = false,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: clearFailure ? null : (failure ?? this.failure),
      data: data ?? this.data,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      dateRange: dateRange ?? this.dateRange,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      isCached: isCached ?? this.isCached,
    );
  }

  bool get hasData => data != null;
  bool get hasError => failure != null;
  bool get isEmpty => !hasData && !isLoading && !hasError;

  @override
  List<Object?> get props => [
    isLoading,
    isRefreshing,
    failure,
    data,
    selectedPeriod,
    dateRange,
    selectedCategoryId,
    isCached,
  ];
}
