import '../../../../core/network/models/api_result.dart';
import '../entities/analytics_data.dart';

abstract class AnalyticsRepository {
  Future<ApiResult<AnalyticsData>> getAnalyticsData({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<ApiResult<AnalyticsData>> getCachedAnalyticsData({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<ApiResult<AnalyticsData>> refreshAnalyticsData({
    required DateTime startDate,
    required DateTime endDate,
  });
}
