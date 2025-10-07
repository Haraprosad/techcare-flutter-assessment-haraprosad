import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/domain/repositories/transaction_repository.dart';

/// Fetches a single transaction by its ID (for viewing details or editing)
@injectable
class GetTransactionByIdUseCase {
  final TransactionRepository _repository;

  GetTransactionByIdUseCase(this._repository);

  Future<ApiResult<Transaction>> call(String id) {
    return _repository.getTransactionById(id);
  }
}
