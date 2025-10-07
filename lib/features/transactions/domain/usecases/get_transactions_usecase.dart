import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/paginated_transactions.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction_filters.dart';
import 'package:techcare_assessment_app/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case for fetching paginated transactions
@injectable
class GetTransactionsUseCase {
  final TransactionRepository _repository;

  GetTransactionsUseCase(this._repository);

  Future<ApiResult<PaginatedTransactions>> call({
    required int page,
    required int pageSize,
    TransactionFilters? filters,
  }) {
    return _repository.getTransactions(
      page: page,
      pageSize: pageSize,
      filters: filters,
    );
  }
}
