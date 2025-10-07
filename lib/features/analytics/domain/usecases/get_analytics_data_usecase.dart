import 'package:injectable/injectable.dart';
import '../../../../core/network/models/api_result.dart';
import '../entities/analytics_data.dart';
import '../repositories/analytics_repository.dart';

/// Fetches analytics data for a given date range.
///
/// Simple use case that just wraps the repository call. The real work
/// happens in the repository - this is just the clean architecture layer.
@injectable
class GetAnalyticsDataUseCase {
  final AnalyticsRepository _repository;

  GetAnalyticsDataUseCase(this._repository);

  Future<ApiResult<AnalyticsData>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _repository.getAnalyticsData(startDate: startDate, endDate: endDate);
  }
}
