import 'package:injectable/injectable.dart';

import '../../../../core/network/models/api_result.dart';
import '../entities/paginated_transactions.dart';
import '../entities/transaction_filters.dart';
import '../repositories/transaction_repository.dart';

/// Fetches a page of transactions with optional filtering/searching
///
/// Returns paginated results so you can do infinite scrolling.
/// Supports filtering by date, category, amount, type, and search query.
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
