import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/core/network/repository/base_api_repository.dart';
import 'package:techcare_assessment_app/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:techcare_assessment_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/entities/balance_summary.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/repositories/dashbaord_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/logger/app_logger.dart';

/// Implementation of DashboardRepository with comprehensive caching strategy
///
/// Caching Strategy:
/// - Dashboard data cache validity: 5 minutes
/// - Balance summary cache validity: 2 minutes (more frequent updates)
/// - Cache-first approach: Try cache first, then fetch from API
/// - Offline support: Return cached data when network unavailable
/// - Concurrent requests: Load dashboard components in parallel
/// - Cache invalidation: On pull-to-refresh or cache expiry
@Injectable(as: DashboardRepository)
class DashboardRepositoryImpl extends BaseApiRepository
    implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;
  final DashboardLocalDataSource _localDataSource;

  DashboardRepositoryImpl(
    super.errorHandler,
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  Future<ApiResult<DashboardData>> getDashboardData() async {
    AppLogger.d(message: '🏁 getDashboardData called in repository');

    // Check if cache is valid
    try {
      AppLogger.d(message: '🔍 Checking cache validity...');
      final isCacheValid = await _localDataSource.isDashboardCacheValid();
      AppLogger.d(message: '✅ Cache valid check complete: $isCacheValid');

      if (isCacheValid) {
        // Return cached data if valid
        final cachedData = await _localDataSource.getCachedDashboardData();
        if (cachedData != null) {
          AppLogger.i(message: '📦 Returning cached dashboard data');
          return ApiSuccess(cachedData.toEntity());
        }
      }
    } catch (e) {
      AppLogger.w(message: '⚠️ Error checking cache: $e');
      // Continue to fetch fresh data
    }

    // Try to fetch fresh data from API
    AppLogger.d(message: '🌐 Starting API call...');
    return safeApiCall(() async {
      AppLogger.d(
        message:
            '🌐 Inside safeApiCall - Fetching fresh dashboard data from remote...',
      );
      final model = await _remoteDataSource.getDashboardData();

      // Cache the fresh data (don't let caching failures stop the data flow)
      try {
        AppLogger.d(message: '💾 Caching dashboard data...');
        await _localDataSource.cacheDashboardData(model);
        AppLogger.d(message: '✅ Dashboard data cached successfully');
      } catch (e) {
        AppLogger.w(message: '⚠️ Failed to cache dashboard data: $e');
        // Continue anyway - caching is not critical
      }

      AppLogger.d(message: '🔄 Converting model to entity...');
      final entity = model.toEntity();
      AppLogger.d(message: '✅ Model converted to entity successfully');

      return entity;
    }).then((result) async {
      // If API call fails, try to return cached data (offline support)
      if (result is ApiFailure) {
        AppLogger.w(
          message: '❌ API call failed, trying to load cached data...',
        );
        final cachedData = await _localDataSource.getCachedDashboardData();
        if (cachedData != null) {
          AppLogger.i(message: '📦 Returning cached data as fallback');
          return ApiSuccess(cachedData.toEntity());
        }
      }
      return result;
    });
  }

  @override
  Future<ApiResult<BalanceSummary>> getBalanceSummary() async {
    // Check if cache is valid
    final isCacheValid = await _localDataSource.isBalanceSummaryCacheValid();

    if (isCacheValid) {
      // Return cached data if valid
      final cachedSummary = await _localDataSource.getCachedBalanceSummary();
      if (cachedSummary != null) {
        return ApiSuccess(cachedSummary.toEntity());
      }
    }

    // Try to fetch fresh data from API
    return safeApiCall(() async {
      final model = await _remoteDataSource.getBalanceSummary();

      // Cache the fresh data
      await _localDataSource.cacheBalanceSummary(model);

      return model.toEntity();
    }).then((result) async {
      // If API call fails, try to return cached data (offline support)
      if (result is ApiFailure) {
        final cachedSummary = await _localDataSource.getCachedBalanceSummary();
        if (cachedSummary != null) {
          return ApiSuccess(cachedSummary.toEntity());
        }
      }
      return result;
    });
  }

  @override
  Future<ApiResult<DashboardData>> refreshDashboardData() async {
    // Force fresh data fetch, bypassing cache
    return safeApiCall(() async {
      final model = await _remoteDataSource.getDashboardData();

      // Update cache with fresh data
      await _localDataSource.cacheDashboardData(model);

      return model.toEntity();
    }).then((result) async {
      // Even on refresh failure, return cached data if available
      if (result is ApiFailure) {
        final cachedData = await _localDataSource.getCachedDashboardData();
        if (cachedData != null) {
          return ApiSuccess(cachedData.toEntity());
        }
      }
      return result;
    });
  }

  @override
  Future<ApiResult<DashboardData>> getCachedDashboardData() {
    return safeApiCall(() async {
      final cachedData = await _localDataSource.getCachedDashboardData();

      if (cachedData == null) {
        throw Exception('No cached data available');
      }

      return cachedData.toEntity();
    });
  }

  /// Additional method: Clear dashboard cache
  /// Useful for logout or data reset scenarios
  Future<void> clearCache() async {
    await _localDataSource.clearDashboardCache();
  }
}
