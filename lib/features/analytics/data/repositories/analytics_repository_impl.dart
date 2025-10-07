import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/features/analytics/data/models/analytics_data_model.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/network/error_handling/models/api_call_failure_model.dart';
import '../../../../core/network/models/api_result.dart';
import '../../../../core/network/repository/base_api_repository.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_local_datasource.dart';
import '../datasources/analytics_remote_datasource.dart';

@Injectable(as: AnalyticsRepository)
class AnalyticsRepositoryImpl extends BaseApiRepository
    implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remoteDataSource;
  final AnalyticsLocalDataSource _localDataSource;

  AnalyticsRepositoryImpl(
    super.errorHandler,
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  Future<ApiResult<AnalyticsData>> getAnalyticsData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    AppLogger.d(
      message: '🏁 getAnalyticsData called for range: $startDate to $endDate',
    );

    // Try to get cached data first
    try {
      final cachedData = await _localDataSource.getCachedAnalyticsData(
        startDate,
        endDate,
      );

      if (cachedData != null) {
        AppLogger.i(message: '📦 Returning cached analytics data');
        return ApiSuccess(cachedData.toEntity());
      }
    } catch (e) {
      AppLogger.w(message: '⚠️ Error checking cache: $e');
    }

    // Fetch fresh data from remote
    AppLogger.d(message: '🌐 Starting API call...');
    return safeApiCall(() async {
      AppLogger.d(message: '🌐 Fetching fresh analytics data from remote...');
      final remoteData = await _remoteDataSource.getAnalyticsData(
        startDate,
        endDate,
      );

      // Cache the fresh data
      try {
        await _localDataSource.cacheAnalyticsData(
          remoteData,
          startDate,
          endDate,
        );
        AppLogger.i(message: '💾 Analytics data cached successfully');
      } catch (e) {
        AppLogger.w(message: '⚠️ Failed to cache analytics data: $e');
      }

      return remoteData.toEntity();
    });
  }

  @override
  Future<ApiResult<AnalyticsData>> getCachedAnalyticsData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    AppLogger.d(message: '🏁 getCachedAnalyticsData called');

    try {
      final cachedData = await _localDataSource.getCachedAnalyticsData(
        startDate,
        endDate,
      );

      if (cachedData == null) {
        AppLogger.w(message: '⚠️ No cached analytics data available');
        return ApiFailure(
          ApiCallFailureModel(
            code: 404,
            translatedMessage: 'No cached analytics data available',
          ),
        );
      }

      AppLogger.i(message: '📦 Returning cached analytics data');
      return ApiSuccess(cachedData.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e(
        message: '❌ Error fetching cached analytics data',
        error: e,
        stackTrace: stackTrace,
      );
      return ApiFailure(
        ApiCallFailureModel(
          code: 500,
          translatedMessage: 'Failed to load cached analytics data',
          technicalMessage: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<ApiResult<AnalyticsData>> refreshAnalyticsData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    AppLogger.d(message: '🔄 refreshAnalyticsData called');

    // Clear existing cache
    try {
      await _localDataSource.clearCache();
      AppLogger.i(message: '🗑️ Analytics cache cleared');
    } catch (e) {
      AppLogger.w(message: '⚠️ Failed to clear cache: $e');
    }

    // Fetch fresh data
    return safeApiCall(() async {
      AppLogger.d(message: '🌐 Fetching fresh analytics data...');
      final remoteData = await _remoteDataSource.getAnalyticsData(
        startDate,
        endDate,
      );

      // Cache the fresh data
      try {
        await _localDataSource.cacheAnalyticsData(
          remoteData,
          startDate,
          endDate,
        );
        AppLogger.i(message: '💾 Fresh analytics data cached');
      } catch (e) {
        AppLogger.w(message: '⚠️ Failed to cache fresh data: $e');
      }

      return remoteData.toEntity();
    });
  }
}
