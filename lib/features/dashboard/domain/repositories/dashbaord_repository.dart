import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/entities/balance_summary.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/entities/dashboard_data.dart';

/// Interface for dashboard data operations.
///
/// The actual implementation lives in the data layer where it handles
/// API calls, caching, error handling, etc. This just defines what's available.
abstract class DashboardRepository {
  /// Gets the full dashboard - balance, spending breakdown, recent transactions
  Future<ApiResult<DashboardData>> getDashboardData();

  /// Quick balance check without loading everything
  Future<ApiResult<BalanceSummary>> getBalanceSummary();

  /// Pull-to-refresh - forces fresh data from server, ignores cache
  Future<ApiResult<DashboardData>> refreshDashboardData();

  /// Tries to load from cache - works offline
  Future<ApiResult<DashboardData>> getCachedDashboardData();
}
