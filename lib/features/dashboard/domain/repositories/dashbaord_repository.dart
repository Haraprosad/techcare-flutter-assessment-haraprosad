import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/entities/balance_summary.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/entities/dashboard_data.dart';

/// Repository interface for dashboard data operations
/// Implementation will be in data layer
abstract class DashboardRepository {
  /// Fetches complete dashboard data including balance, spending, and recent transactions
  /// Returns [ApiSuccess(DashboardData)] on success
  /// Returns [ApiFailure(ApiCallFailureModel)] on error
  Future<ApiResult<DashboardData>> getDashboardData();

  /// Fetches only balance summary for quick refresh
  /// Returns [ApiSuccess(BalanceSummary)] on success
  /// Returns [ApiFailure(ApiCallFailureModel)] on error
  Future<ApiResult<BalanceSummary>> getBalanceSummary();


  /// Refreshes dashboard data (pull-to-refresh)
  /// Forces fresh data fetch, bypassing cache
  /// Returns [ApiSuccess(DashboardData)] on success
  /// Returns [ApiFailure(ApiCallFailureModel)] on error
  Future<ApiResult<DashboardData>> refreshDashboardData();

  /// Gets cached dashboard data if available
  /// Returns [ApiSuccess(DashboardData)] if cache exists
  /// Returns [ApiFailure(ApiCallFailureModel)] if no cache available
  Future<ApiResult<DashboardData>> getCachedDashboardData();
}
