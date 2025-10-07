import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/paginated_transactions.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction_filters.dart';
import 'package:techcare_assessment_app/features/transactions/domain/repositories/transaction_repository.dart';

/// Refreshes transactions from the network (bypasses cache, used for pull-to-refresh)
@injectable
class RefreshTransactionsUseCase {
  final TransactionRepository _repository;

  RefreshTransactionsUseCase(this._repository);

  Future<ApiResult<PaginatedTransactions>> call({
    required int page,
    required int pageSize,
    TransactionFilters? filters,
  }) {
    return _repository.refreshTransactions(
      page: page,
      pageSize: pageSize,
      filters: filters,
    );
  }
}
