import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techcare_assessment_app/core/logger/app_logger.dart';
import 'dart:convert';
import 'package:techcare_assessment_app/features/transactions/data/models/paginated_transactions_model.dart';

/// Local data source for caching transaction data
/// Uses SharedPreferences for lightweight caching
abstract class TransactionLocalDataSource {
  /// Cache transactions data
  Future<void> cacheTransactions(
    PaginatedTransactionsModel data,
    int page,
    String filterKey,
  );

  /// Get cached transactions
  Future<PaginatedTransactionsModel?> getCachedTransactions(
    int page,
    String filterKey,
  );

  /// Check if transactions cache is valid
  Future<bool> isTransactionsCacheValid(int page, String filterKey);

  /// Clear all transaction caches
  Future<void> clearTransactionCache();
}

@Injectable(as: TransactionLocalDataSource)
class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final SharedPreferences _prefs;

  // Cache validity duration (5 minutes)
  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  TransactionLocalDataSourceImpl(this._prefs);

  String _getCacheKey(int page, String filterKey) =>
      'transactions_cache_page_${page}_filter_$filterKey';

  String _getTimestampKey(int page, String filterKey) =>
      'transactions_timestamp_page_${page}_filter_$filterKey';

  @override
  Future<void> cacheTransactions(
    PaginatedTransactionsModel data,
    int page,
    String filterKey,
  ) async {
    try {
      final cacheKey = _getCacheKey(page, filterKey);
      final timestampKey = _getTimestampKey(page, filterKey);

      final jsonString = json.encode(data.toJson());
      await _prefs.setString(cacheKey, jsonString);
      await _prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);

      AppLogger.d(
        message: '💾 Cached transactions for page $page, filter: $filterKey',
      );
    } catch (e) {
      AppLogger.w(message: '⚠️ Failed to cache transactions: $e');
      // Don't throw - caching failures shouldn't stop the app
    }
  }

  @override
  Future<PaginatedTransactionsModel?> getCachedTransactions(
    int page,
    String filterKey,
  ) async {
    try {
      final cacheKey = _getCacheKey(page, filterKey);
      final jsonString = _prefs.getString(cacheKey);

      if (jsonString == null) {
        AppLogger.d(
          message:
              '📦 No cached transactions for page $page, filter: $filterKey',
        );
        return null;
      }

      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final model = PaginatedTransactionsModel.fromJson(jsonData);

      AppLogger.d(
        message:
            '📦 Retrieved cached transactions for page $page, filter: $filterKey',
      );
      return model;
    } catch (e) {
      AppLogger.w(message: '⚠️ Failed to retrieve cached transactions: $e');
      return null;
    }
  }

  @override
  Future<bool> isTransactionsCacheValid(int page, String filterKey) async {
    try {
      final timestampKey = _getTimestampKey(page, filterKey);
      final timestamp = _prefs.getInt(timestampKey);

      if (timestamp == null) {
        return false;
      }

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheTime);

      final isValid = difference < _cacheValidityDuration;
      AppLogger.d(
        message:
            '📦 Cache validity for page $page, filter $filterKey: $isValid (age: ${difference.inMinutes} minutes)',
      );

      return isValid;
    } catch (e) {
      AppLogger.w(message: '⚠️ Error checking cache validity: $e');
      return false;
    }
  }

  @override
  Future<void> clearTransactionCache() async {
    try {
      final keys = _prefs.getKeys();
      final transactionKeys = keys.where(
        (key) =>
            key.startsWith('transactions_cache_') ||
            key.startsWith('transactions_timestamp_'),
      );

      for (final key in transactionKeys) {
        await _prefs.remove(key);
      }

      AppLogger.i(message: '🗑️ Cleared transaction cache');
    } catch (e) {
      AppLogger.w(message: '⚠️ Failed to clear transaction cache: $e');
    }
  }
}
