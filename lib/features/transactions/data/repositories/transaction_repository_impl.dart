import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/logger/app_logger.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/core/network/repository/base_api_repository.dart';
import 'package:techcare_assessment_app/features/dashboard/data/models/category_model.dart';
import 'package:techcare_assessment_app/features/dashboard/data/models/transaction_model.dart';
import 'package:techcare_assessment_app/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:techcare_assessment_app/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/category.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/paginated_transactions.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction_filters.dart';
import 'package:techcare_assessment_app/features/transactions/domain/repositories/transaction_repository.dart';

/// Implementation of TransactionRepository with comprehensive caching strategy
///
/// Caching Strategy:
/// - Transaction list cache validity: 5 minutes
/// - Separate cache for each page and filter combination
/// - Cache-first approach: Try cache first, then fetch from API
/// - Offline support: Return cached data when network unavailable
/// - Cache invalidation: On pull-to-refresh or cache expiry
@Injectable(as: TransactionRepository)
class TransactionRepositoryImpl extends BaseApiRepository
    implements TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;
  final TransactionLocalDataSource _localDataSource;

  TransactionRepositoryImpl(
    super.errorHandler,
    this._remoteDataSource,
    this._localDataSource,
  );

  /// Generate cache key from filters
  String _generateFilterKey(TransactionFilters? filters) {
    if (filters == null || !filters.hasActiveFilters) {
      return 'default';
    }

    final parts = <String>[];
    if (filters.startDate != null) {
      parts.add('start_${filters.startDate!.millisecondsSinceEpoch}');
    }
    if (filters.endDate != null) {
      parts.add('end_${filters.endDate!.millisecondsSinceEpoch}');
    }
    if (filters.categoryIds.isNotEmpty) {
      parts.add('cat_${filters.categoryIds.join('_')}');
    }
    if (filters.minAmount != null) parts.add('min_${filters.minAmount}');
    if (filters.maxAmount != null) parts.add('max_${filters.maxAmount}');
    if (filters.type != null) parts.add('type_${filters.type!.name}');
    if (filters.searchQuery.isNotEmpty) {
      parts.add('search_${filters.searchQuery}');
    }

    return parts.join('|');
  }

  @override
  Future<ApiResult<PaginatedTransactions>> getTransactions({
    required int page,
    required int pageSize,
    TransactionFilters? filters,
  }) async {
    AppLogger.d(message: '🏁 getTransactions called in repository');

    final filterKey = _generateFilterKey(filters);

    // Check if cache is valid
    try {
      AppLogger.d(message: '🔍 Checking cache validity...');
      final isCacheValid = await _localDataSource.isTransactionsCacheValid(
        page,
        filterKey,
      );
      AppLogger.d(message: '✅ Cache valid check complete: $isCacheValid');

      if (isCacheValid) {
        // Return cached data if valid
        final cachedData = await _localDataSource.getCachedTransactions(
          page,
          filterKey,
        );
        if (cachedData != null) {
          AppLogger.i(
            message: '📦 Returning cached transactions for page $page',
          );
          return ApiSuccess(cachedData.toEntity());
        }
      }
    } catch (e) {
      AppLogger.w(message: '⚠️ Error checking cache: $e');
      // Continue to fetch fresh data
    }

    // Try to fetch fresh data from API
    AppLogger.d(message: '🌐 Starting API call...');
    return safeApiCall(() async {
      AppLogger.d(
        message:
            '🌐 Inside safeApiCall - Fetching fresh transactions from remote...',
      );
      final model = await _remoteDataSource.getTransactions(
        page: page,
        pageSize: pageSize,
        filters: filters,
      );

      // Cache the fresh data (don't let caching failures stop the data flow)
      try {
        AppLogger.d(message: '💾 Caching transactions...');
        await _localDataSource.cacheTransactions(model, page, filterKey);
        AppLogger.d(message: '✅ Transactions cached successfully');
      } catch (e) {
        AppLogger.w(message: '⚠️ Failed to cache transactions: $e');
        // Continue anyway - caching is not critical
      }

      AppLogger.d(message: '🔄 Converting model to entity...');
      final entity = model.toEntity();
      AppLogger.d(message: '✅ Model converted to entity successfully');

      return entity;
    }).then((result) async {
      // If API call fails, try to return cached data (offline support)
      if (result is ApiFailure) {
        AppLogger.w(
          message: '❌ API call failed, trying to load cached data...',
        );
        final cachedData = await _localDataSource.getCachedTransactions(
          page,
          filterKey,
        );
        if (cachedData != null) {
          AppLogger.i(message: '📦 Returning cached data as fallback');
          return ApiSuccess(cachedData.toEntity());
        }
      }
      return result;
    });
  }

  @override
  Future<ApiResult<Transaction>> getTransactionById(String id) async {
    AppLogger.d(message: '🏁 getTransactionById called in repository');

    return safeApiCall(() async {
      final model = await _remoteDataSource.getTransactionById(id);
      return model.toEntity();
    });
  }

  @override
  Future<ApiResult<Transaction>> createTransaction(
    Transaction transaction,
  ) async {
    AppLogger.d(message: '🏁 createTransaction called in repository');

    return safeApiCall(() async {
      // Convert entity to model
      final model = TransactionModel(
        id: transaction.id,
        title: transaction.title,
        amount: transaction.amount,
        type: transaction.type,
        category: _categoryEntityToModel(transaction.category),
        date: transaction.date,
        description: transaction.description,
      );

      final result = await _remoteDataSource.createTransaction(model);

      // Clear cache to force refresh
      await _localDataSource.clearTransactionCache();

      return result.toEntity();
    });
  }

  @override
  Future<ApiResult<Transaction>> updateTransaction(
    Transaction transaction,
  ) async {
    AppLogger.d(message: '🏁 updateTransaction called in repository');

    return safeApiCall(() async {
      // Convert entity to model
      final model = TransactionModel(
        id: transaction.id,
        title: transaction.title,
        amount: transaction.amount,
        type: transaction.type,
        category: _categoryEntityToModel(transaction.category),
        date: transaction.date,
        description: transaction.description,
      );

      final result = await _remoteDataSource.updateTransaction(model);

      // Clear cache to force refresh
      await _localDataSource.clearTransactionCache();

      return result.toEntity();
    });
  }

  @override
  Future<ApiResult<void>> deleteTransaction(String id) async {
    AppLogger.d(message: '🏁 deleteTransaction called in repository');

    return safeApiCall(() async {
      await _remoteDataSource.deleteTransaction(id);

      // Clear cache to force refresh
      await _localDataSource.clearTransactionCache();
    });
  }

  @override
  Future<ApiResult<PaginatedTransactions>> refreshTransactions({
    required int page,
    required int pageSize,
    TransactionFilters? filters,
  }) async {
    AppLogger.d(message: '🏁 refreshTransactions called in repository');

    final filterKey = _generateFilterKey(filters);

    // Clear cache for this specific page and filter
    try {
      await _localDataSource.clearTransactionCache();
    } catch (e) {
      AppLogger.w(message: '⚠️ Failed to clear cache: $e');
    }

    // Fetch fresh data
    return safeApiCall(() async {
      final model = await _remoteDataSource.getTransactions(
        page: page,
        pageSize: pageSize,
        filters: filters,
      );

      // Cache the fresh data
      try {
        await _localDataSource.cacheTransactions(model, page, filterKey);
      } catch (e) {
        AppLogger.w(message: '⚠️ Failed to cache refreshed transactions: $e');
      }

      return model.toEntity();
    });
  }

  @override
  Future<ApiResult<List<Category>>> getCategories() async {
    AppLogger.d(message: '🏁 getCategories called in repository');

    return safeApiCall(() async {
      final categories = await _remoteDataSource.getCategories();
      return categories.map((model) => model.toEntity()).toList();
    });
  }

  /// Helper method to convert Category entity to CategoryModel
  CategoryModel _categoryEntityToModel(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      color: category.color,
      budget: category.budget,
    );
  }
}
