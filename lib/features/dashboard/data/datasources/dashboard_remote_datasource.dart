import 'package:techcare_assessment_app/core/network/services/mock_dashboard_service.dart';
import 'package:techcare_assessment_app/core/network/enums/custom_error_type.dart';
import 'package:techcare_assessment_app/core/network/error_handling/models/custom_exception.dart';
import 'package:techcare_assessment_app/features/dashboard/data/models/balance_summary_model.dart';
import 'package:techcare_assessment_app/features/dashboard/data/models/dashboard_data_model.dart';
import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/logger/app_logger.dart';

/// Remote data source for fetching dashboard data
/// Uses MockDashboardService to provide data without external server dependency
/// This approach is ideal for assessment/demo purposes and easy to switch to real API
abstract class DashboardRemoteDataSource {
  /// Fetches complete dashboard data
  Future<DashboardDataModel> getDashboardData();

  /// Fetches only balance summary
  Future<BalanceSummaryModel> getBalanceSummary();
}

@Injectable(as: DashboardRemoteDataSource)
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final MockDashboardService _mockService;

  DashboardRemoteDataSourceImpl(this._mockService);

  @override
  Future<DashboardDataModel> getDashboardData() async {
    try {
      AppLogger.d(message: '📥 Fetching dashboard data from mock service...');
      final data = await _mockService.getDashboardData();
      AppLogger.d(message: '✅ Mock data received: ${data.keys}');

      AppLogger.d(message: '🔄 Parsing JSON to model...');
      final model = DashboardDataModel.fromJson(data);
      AppLogger.d(message: '✅ Successfully parsed dashboard data model');

      AppLogger.d(message: '🚀 Returning model from datasource...');
      return model;
    } catch (e, stackTrace) {
      AppLogger.e(
        message: '❌ Error in getDashboardData',
        error: e,
        stackTrace: stackTrace,
      );
      throw CustomException(
        type: CustomErrorType.parsingError,
        originalError: e,
      );
    }
  }

  @override
  Future<BalanceSummaryModel> getBalanceSummary() async {
    try {
      final data = await _mockService.getBalanceSummary();
      return BalanceSummaryModel.fromJson(data);
    } catch (e) {
      throw CustomException(
        type: CustomErrorType.parsingError,
        originalError: e,
      );
    }
  }
}
