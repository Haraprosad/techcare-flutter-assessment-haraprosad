import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/repositories/dashbaord_repository.dart';

/// Grabs all the dashboard data - balance, spending, recent transactions.
///
/// Just a simple wrapper around the repository. The clean architecture
/// pattern wants us to keep business logic separate from data access.
@injectable
class GetDashboardDataUseCase {
  final DashboardRepository _repository;

  GetDashboardDataUseCase(this._repository);

  Future<ApiResult<DashboardData>> call() {
    return _repository.getDashboardData();
  }
}
