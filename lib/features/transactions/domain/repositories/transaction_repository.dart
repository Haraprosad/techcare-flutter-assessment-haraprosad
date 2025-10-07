import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/category.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/paginated_transactions.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction_filters.dart';

/// Contract for transaction data operations
///
/// The actual implementation lives in the data layer and handles networking,
/// caching, and error handling. This just defines what operations are available.
abstract class TransactionRepository {
  /// Fetches a page of transactions, optionally filtered
  Future<ApiResult<PaginatedTransactions>> getTransactions({
    required int page,
    required int pageSize,
    TransactionFilters? filters,
  });

  /// Fetches a single transaction by its ID
  Future<ApiResult<Transaction>> getTransactionById(String id);

  /// Creates a new transaction
  Future<ApiResult<Transaction>> createTransaction(Transaction transaction);

  /// Updates an existing transaction
  Future<ApiResult<Transaction>> updateTransaction(Transaction transaction);

  /// Deletes a transaction permanently
  Future<ApiResult<void>> deleteTransaction(String id);

  /// Refreshes transactions from the network (bypasses cache)
  Future<ApiResult<PaginatedTransactions>> refreshTransactions({
    required int page,
    required int pageSize,
    TransactionFilters? filters,
  });

  /// Fetches all available transaction categories

  /// Returns [ApiFailure(ApiCallFailureModel)] on error
  Future<ApiResult<List<Category>>> getCategories();
}
