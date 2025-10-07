import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/domain/repositories/transaction_repository.dart';

/// Updates an existing transaction with new data
@injectable
class UpdateTransactionUseCase {
  final TransactionRepository _repository;

  UpdateTransactionUseCase(this._repository);

  Future<ApiResult<Transaction>> call(Transaction transaction) {
    return _repository.updateTransaction(transaction);
  }
}
