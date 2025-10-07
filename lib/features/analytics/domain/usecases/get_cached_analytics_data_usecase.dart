import 'package:injectable/injectable.dart';
import '../../../../core/network/models/api_result.dart';
import '../entities/analytics_data.dart';
import '../repositories/analytics_repository.dart';

@injectable
class GetCachedAnalyticsDataUseCase {
  final AnalyticsRepository _repository;

  GetCachedAnalyticsDataUseCase(this._repository);

  Future<ApiResult<AnalyticsData>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _repository.getCachedAnalyticsData(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
