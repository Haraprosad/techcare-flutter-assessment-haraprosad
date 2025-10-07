import 'package:equatable/equatable.dart';

/// Time period options for analytics filtering
enum AnalyticsPeriod { thisWeek, thisMonth, lastThreeMonths, custom }

extension AnalyticsPeriodX on AnalyticsPeriod {
  String get displayName {
    switch (this) {
      case AnalyticsPeriod.thisWeek:
        return 'This Week';
      case AnalyticsPeriod.thisMonth:
        return 'This Month';
      case AnalyticsPeriod.lastThreeMonths:
        return 'Last 3 Months';
      case AnalyticsPeriod.custom:
        return 'Custom';
    }
  }

  /// Calculate date range based on period
  DateTimeRange get dateRange {
    final now = DateTime.now();
    switch (this) {
      case AnalyticsPeriod.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return DateTimeRange(
          start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          end: now,
        );
      case AnalyticsPeriod.thisMonth:
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
      case AnalyticsPeriod.lastThreeMonths:
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return DateTimeRange(start: threeMonthsAgo, end: now);
      case AnalyticsPeriod.custom:
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
    }
  }
}

class DateTimeRange extends Equatable {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];
}

/// Base analytics event
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Load analytics data for the current selected period
class LoadAnalytics extends AnalyticsEvent {
  const LoadAnalytics();
}

/// Update the date range and reload analytics
class UpdateDateRange extends AnalyticsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const UpdateDateRange({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Update time period selection
class UpdatePeriod extends AnalyticsEvent {
  final AnalyticsPeriod period;

  const UpdatePeriod(this.period);

  @override
  List<Object?> get props => [period];
}

/// Filter analytics by specific category
class FilterByCategory extends AnalyticsEvent {
  final String? categoryId;

  const FilterByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Refresh analytics data (pull-to-refresh)
class RefreshAnalytics extends AnalyticsEvent {
  const RefreshAnalytics();
}

/// Load cached analytics data
class LoadCachedAnalytics extends AnalyticsEvent {
  const LoadCachedAnalytics();
}
