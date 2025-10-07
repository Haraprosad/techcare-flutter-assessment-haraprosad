import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/logger/app_logger.dart';
import 'package:techcare_assessment_app/core/network/enums/custom_error_type.dart';
import 'package:techcare_assessment_app/core/network/error_handling/models/custom_exception.dart';
import 'package:techcare_assessment_app/core/network/services/mock_transaction_service.dart';
import 'package:techcare_assessment_app/features/dashboard/data/models/transaction_model.dart';
import 'package:techcare_assessment_app/features/transactions/data/models/paginated_transactions_model.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction_filters.dart';

/// Remote data source for fetching transaction data
/// Uses MockTransactionService to provide data without external server dependency
abstract class TransactionRemoteDataSource {
  /// Fetches paginated transactions
  Future<PaginatedTransactionsModel> getTransactions({
    required int page,
    required int pageSize,
    TransactionFilters? filters,
  });

  /// Fetches a single transaction by ID
  Future<TransactionModel> getTransactionById(String id);

  /// Creates a new transaction
  Future<TransactionModel> createTransaction(TransactionModel transaction);

  /// Updates an existing transaction
  Future<TransactionModel> updateTransaction(TransactionModel transaction);

  /// Deletes a transaction
  Future<void> deleteTransaction(String id);
}

@Injectable(as: TransactionRemoteDataSource)
class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final MockTransactionService _mockService;

  TransactionRemoteDataSourceImpl(this._mockService);

  @override
  Future<PaginatedTransactionsModel> getTransactions({
    required int page,
    required int pageSize,
    TransactionFilters? filters,
  }) async {
    try {
      AppLogger.d(
        message:
            '📥 Fetching transactions (page: $page, pageSize: $pageSize)...',
      );
      final data = await _mockService.getTransactions(
        page: page,
        pageSize: pageSize,
        filters: filters,
      );
      AppLogger.d(message: '✅ Transactions data received');

      final model = PaginatedTransactionsModel.fromJson(data);
      AppLogger.d(message: '✅ Successfully parsed paginated transactions');

      return model;
    } catch (e, stackTrace) {
      AppLogger.e(
        message: '❌ Error in getTransactions',
        error: e,
        stackTrace: stackTrace,
      );
      throw CustomException(
        type: CustomErrorType.parsingError,
        originalError: e,
      );
    }
  }

  @override
  Future<TransactionModel> getTransactionById(String id) async {
    try {
      AppLogger.d(message: '📥 Fetching transaction by ID: $id');
      final data = await _mockService.getTransactionById(id);

      if (data == null) {
        throw CustomException(
          type: CustomErrorType.parsingError,
          originalError: Exception('Transaction not found: $id'),
        );
      }

      final model = TransactionModel.fromJson(data);
      AppLogger.d(message: '✅ Successfully fetched transaction: $id');

      return model;
    } catch (e, stackTrace) {
      AppLogger.e(
        message: '❌ Error in getTransactionById',
        error: e,
        stackTrace: stackTrace,
      );
      if (e is CustomException) rethrow;
      throw CustomException(
        type: CustomErrorType.parsingError,
        originalError: e,
      );
    }
  }

  @override
  Future<TransactionModel> createTransaction(
    TransactionModel transaction,
  ) async {
    try {
      AppLogger.d(message: '📤 Creating new transaction...');
      final transactionJson = transaction.toJson();
      final data = await _mockService.createTransaction(transactionJson);

      final model = TransactionModel.fromJson(data);
      AppLogger.i(message: '✅ Transaction created successfully');

      return model;
    } catch (e, stackTrace) {
      AppLogger.e(
        message: '❌ Error in createTransaction',
        error: e,
        stackTrace: stackTrace,
      );
      throw CustomException(
        type: CustomErrorType.parsingError,
        originalError: e,
      );
    }
  }

  @override
  Future<TransactionModel> updateTransaction(
    TransactionModel transaction,
  ) async {
    try {
      AppLogger.d(message: '📤 Updating transaction: ${transaction.id}');
      final transactionJson = transaction.toJson();
      final data = await _mockService.updateTransaction(transactionJson);

      if (data == null) {
        throw CustomException(
          type: CustomErrorType.parsingError,
          originalError: Exception('Transaction not found: ${transaction.id}'),
        );
      }

      final model = TransactionModel.fromJson(data);
      AppLogger.i(message: '✅ Transaction updated successfully');

      return model;
    } catch (e, stackTrace) {
      AppLogger.e(
        message: '❌ Error in updateTransaction',
        error: e,
        stackTrace: stackTrace,
      );
      if (e is CustomException) rethrow;
      throw CustomException(
        type: CustomErrorType.parsingError,
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      AppLogger.d(message: '📤 Deleting transaction: $id');
      final success = await _mockService.deleteTransaction(id);

      if (!success) {
        throw CustomException(
          type: CustomErrorType.parsingError,
          originalError: Exception('Transaction not found: $id'),
        );
      }

      AppLogger.i(message: '✅ Transaction deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.e(
        message: '❌ Error in deleteTransaction',
        error: e,
        stackTrace: stackTrace,
      );
      if (e is CustomException) rethrow;
      throw CustomException(
        type: CustomErrorType.parsingError,
        originalError: e,
      );
    }
  }
}
