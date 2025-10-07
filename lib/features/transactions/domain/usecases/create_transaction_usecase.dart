import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/domain/repositories/transaction_repository.dart';

/// Creates a new transaction and saves it to the backend
@injectable
class CreateTransactionUseCase {
  final TransactionRepository _repository;

  CreateTransactionUseCase(this._repository);

  Future<ApiResult<Transaction>> call(Transaction transaction) {
    return _repository.createTransaction(transaction);
  }
}
