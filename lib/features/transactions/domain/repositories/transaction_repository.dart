import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/category.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/paginated_transactions.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction_filters.dart';

/// Repository interface for transaction data operations
/// Implementation will be in data layer
abstract class TransactionRepository {
  /// Fetches paginated transactions with optional filters
  /// Returns [ApiSuccess(PaginatedTransactions)] on success
  /// Returns [ApiFailure(ApiCallFailureModel)] on error
  Future<ApiResult<PaginatedTransactions>> getTransactions({
    required int page,
    required int pageSize,
    TransactionFilters? filters,
  });

  /// Fetches a single transaction by ID
  /// Returns [ApiSuccess(Transaction)] on success
  /// Returns [ApiFailure(ApiCallFailureModel)] on error
  Future<ApiResult<Transaction>> getTransactionById(String id);

  /// Creates a new transaction
  /// Returns [ApiSuccess(Transaction)] on success
  /// Returns [ApiFailure(ApiCallFailureModel)] on error
  Future<ApiResult<Transaction>> createTransaction(Transaction transaction);

  /// Updates an existing transaction
  /// Returns [ApiSuccess(Transaction)] on success
  /// Returns [ApiFailure(ApiCallFailureModel)] on error
  Future<ApiResult<Transaction>> updateTransaction(Transaction transaction);

  /// Deletes a transaction
  /// Returns [ApiSuccess(void)] on success
  /// Returns [ApiFailure(ApiCallFailureModel)] on error
  Future<ApiResult<void>> deleteTransaction(String id);

  /// Refreshes transaction list (pull-to-refresh)
  /// Forces fresh data fetch, bypassing cache
  /// Returns [ApiSuccess(PaginatedTransactions)] on success
  /// Returns [ApiFailure(ApiCallFailureModel)] on error
  Future<ApiResult<PaginatedTransactions>> refreshTransactions({
    required int page,
    required int pageSize,
    TransactionFilters? filters,
  });

  /// Fetches all available categories
  /// Returns [ApiSuccess(List<Category>)] on success
  /// Returns [ApiFailure(ApiCallFailureModel)] on error
  Future<ApiResult<List<Category>>> getCategories();
}
