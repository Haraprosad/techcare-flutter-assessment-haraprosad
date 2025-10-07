import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/entities/balance_summary.dart';
import 'package:techcare_assessment_app/features/dashboard/domain/repositories/dashbaord_repository.dart';

@injectable
class GetBalanceSummaryUseCase {
  final DashboardRepository _repository;

  GetBalanceSummaryUseCase(this._repository);

  Future<ApiResult<BalanceSummary>> call() {
    return _repository.getBalanceSummary();
  }
}
