import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/transactions/domain/repositories/transaction_repository.dart';

/// Deletes a transaction permanently (make sure the UI confirms this first!)
@injectable
class DeleteTransactionUseCase {
  final TransactionRepository _repository;

  DeleteTransactionUseCase(this._repository);

  Future<ApiResult<void>> call(String id) {
    return _repository.deleteTransaction(id);
  }
}
