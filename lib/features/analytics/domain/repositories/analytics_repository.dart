import '../../../../core/network/models/api_result.dart';
import '../entities/analytics_data.dart';

/// Contract for fetching analytics data.
///
/// Defines what analytics operations are available. The actual implementation
/// lives in the data layer and handles API calls, caching, etc.
abstract class AnalyticsRepository {
  /// Gets analytics from the server
  Future<ApiResult<AnalyticsData>> getAnalyticsData({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Gets analytics from local cache (faster, works offline)
  Future<ApiResult<AnalyticsData>> getCachedAnalyticsData({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Forces a fresh fetch from server, bypassing cache
  Future<ApiResult<AnalyticsData>> refreshAnalyticsData({
    required DateTime startDate,
    required DateTime endDate,
  });
}
