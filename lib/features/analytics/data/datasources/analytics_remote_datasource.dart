import 'package:injectable/injectable.dart';
import '../../../../core/network/services/mock_dashboard_service.dart';
import '../models/analytics_data_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<AnalyticsDataModel> getAnalyticsData(
    DateTime startDate,
    DateTime endDate,
  );
}

@LazySingleton(as: AnalyticsRemoteDataSource)
class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final MockDashboardService mockService;

  AnalyticsRemoteDataSourceImpl({required this.mockService});

  @override
  Future<AnalyticsDataModel> getAnalyticsData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // In a real app, this would make an API call with date parameters
    // For now, we'll use the mock service and transform the data
    final response = await mockService.getAnalyticsData();

    final data = response['data'] as Map<String, dynamic>;

    return AnalyticsDataModel.fromJson(data);
  }
}
