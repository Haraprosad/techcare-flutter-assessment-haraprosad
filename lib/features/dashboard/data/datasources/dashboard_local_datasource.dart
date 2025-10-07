import 'package:techcare_assessment_app/core/storage/hive_manager.dart';
import 'package:techcare_assessment_app/core/storage/storage_keys.dart';
import 'package:techcare_assessment_app/features/dashboard/data/models/balance_summary_model.dart';
import 'package:techcare_assessment_app/features/dashboard/data/models/dashboard_data_model.dart';
import 'package:injectable/injectable.dart';

/// Local data source for caching dashboard data
/// Handles persistence using Hive with direct Map storage (more efficient than JSON strings)
abstract class DashboardLocalDataSource {
  /// Cache dashboard data with timestamp
  Future<void> cacheDashboardData(DashboardDataModel data);

  /// Get cached dashboard data
  /// Returns null if cache doesn't exist or is invalid
  Future<DashboardDataModel?> getCachedDashboardData();

  /// Cache balance summary with timestamp
  Future<void> cacheBalanceSummary(BalanceSummaryModel summary);

  /// Get cached balance summary
  /// Returns null if cache doesn't exist or is invalid
  Future<BalanceSummaryModel?> getCachedBalanceSummary();

  /// Check if dashboard cache is valid (not expired)
  /// Cache validity period: 5 minutes
  Future<bool> isDashboardCacheValid();

  /// Check if balance summary cache is valid (not expired)
  /// Cache validity period: 2 minutes (more frequent updates for balance)
  Future<bool> isBalanceSummaryCacheValid();

  /// Clear all dashboard caches
  Future<void> clearDashboardCache();
}

@Injectable(as: DashboardLocalDataSource)
class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final HiveManager _hiveManager;

  // Cache validity durations
  static const Duration _dashboardCacheValidity = Duration(minutes: 5);
  static const Duration _balanceCacheValidity = Duration(minutes: 2);

  DashboardLocalDataSourceImpl(this._hiveManager);

  @override
  Future<void> cacheDashboardData(DashboardDataModel data) async {
    try {
      final jsonMap = data.toJson();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await Future.wait([
        _hiveManager.saveDashboardData(
          StorageKeys.cachedDashboardData,
          jsonMap,
        ),
        _hiveManager.saveTimestamp(
          StorageKeys.dashboardCacheTimestamp,
          timestamp,
        ),
      ]);
    } catch (e) {
      throw HiveException('Failed to cache dashboard data: $e');
    }
  }

  @override
  Future<DashboardDataModel?> getCachedDashboardData() async {
    try {
      final jsonMap = _hiveManager.getDashboardData(
        StorageKeys.cachedDashboardData,
      );
      if (jsonMap == null) return null;

      return DashboardDataModel.fromJson(jsonMap);
    } catch (e) {
      // If parsing fails, clear the corrupt cache
      await _clearDashboardDataCache();
      return null;
    }
  }

  @override
  Future<void> cacheBalanceSummary(BalanceSummaryModel summary) async {
    try {
      final jsonMap = summary.toJson();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await Future.wait([
        _hiveManager.saveDashboardData(
          StorageKeys.cachedBalanceSummary,
          jsonMap,
        ),
        _hiveManager.saveTimestamp(
          StorageKeys.balanceSummaryCacheTimestamp,
          timestamp,
        ),
      ]);
    } catch (e) {
      throw HiveException('Failed to cache balance summary: $e');
    }
  }

  @override
  Future<BalanceSummaryModel?> getCachedBalanceSummary() async {
    try {
      final jsonMap = _hiveManager.getDashboardData(
        StorageKeys.cachedBalanceSummary,
      );
      if (jsonMap == null) return null;

      return BalanceSummaryModel.fromJson(jsonMap);
    } catch (e) {
      // If parsing fails, clear the corrupt cache
      await _clearBalanceSummaryCache();
      return null;
    }
  }

  @override
  Future<bool> isDashboardCacheValid() async {
    final timestamp = _hiveManager.getTimestamp(
      StorageKeys.dashboardCacheTimestamp,
    );
    if (timestamp == null) return false;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(cacheTime);

    return difference < _dashboardCacheValidity;
  }

  @override
  Future<bool> isBalanceSummaryCacheValid() async {
    final timestamp = _hiveManager.getTimestamp(
      StorageKeys.balanceSummaryCacheTimestamp,
    );
    if (timestamp == null) return false;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(cacheTime);

    return difference < _balanceCacheValidity;
  }

  @override
  Future<void> clearDashboardCache() async {
    try {
      await Future.wait([
        _clearDashboardDataCache(),
        _clearBalanceSummaryCache(),
      ]);
    } catch (e) {
      throw HiveException('Failed to clear dashboard cache: $e');
    }
  }

  // Private helper methods
  Future<void> _clearDashboardDataCache() async {
    await Future.wait([
      _hiveManager.deleteDashboardData(StorageKeys.cachedDashboardData),
      _hiveManager.deleteTimestamp(StorageKeys.dashboardCacheTimestamp),
    ]);
  }

  Future<void> _clearBalanceSummaryCache() async {
    await Future.wait([
      _hiveManager.deleteDashboardData(StorageKeys.cachedBalanceSummary),
      _hiveManager.deleteTimestamp(StorageKeys.balanceSummaryCacheTimestamp),
    ]);
  }
}
