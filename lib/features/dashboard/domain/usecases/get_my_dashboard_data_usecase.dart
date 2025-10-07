import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/repositories/dashbaord_repository.dart';

@injectable
class GetDashboardDataUseCase {
  final DashboardRepository _repository;

  GetDashboardDataUseCase(this._repository);

  Future<ApiResult<DashboardData>> call() {
    return _repository.getDashboardData();
  }
}
