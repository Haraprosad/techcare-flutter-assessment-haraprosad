import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/analytics_data_model.dart';

abstract class AnalyticsLocalDataSource {
  Future<AnalyticsDataModel?> getCachedAnalyticsData(
    DateTime startDate,
    DateTime endDate,
  );
  Future<void> cacheAnalyticsData(
    AnalyticsDataModel data,
    DateTime startDate,
    DateTime endDate,
  );
  Future<void> clearCache();
}

@LazySingleton(as: AnalyticsLocalDataSource)
class AnalyticsLocalDataSourceImpl implements AnalyticsLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _analyticsDataKey = 'ANALYTICS_DATA';
  static const String _cacheTimestampKey = 'ANALYTICS_CACHE_TIMESTAMP';
  static const String _cacheDateRangeKey = 'ANALYTICS_DATE_RANGE';
  static const Duration _cacheValidity = Duration(minutes: 30);

  AnalyticsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<AnalyticsDataModel?> getCachedAnalyticsData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final timestamp = sharedPreferences.getInt(_cacheTimestampKey);
      final dateRange = sharedPreferences.getString(_cacheDateRangeKey);
      final cachedData = sharedPreferences.getString(_analyticsDataKey);

      if (timestamp == null || cachedData == null || dateRange == null) {
        return null;
      }

      // Check if cache is still valid
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cacheTime) > _cacheValidity) {
        return null;
      }

      // Check if date range matches
      final requestedRange =
          '${startDate.toIso8601String()}_${endDate.toIso8601String()}';
      if (dateRange != requestedRange) {
        return null;
      }

      final jsonData = json.decode(cachedData) as Map<String, dynamic>;
      return AnalyticsDataModel.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheAnalyticsData(
    AnalyticsDataModel data,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final jsonData = json.encode(data.toJson());
      final dateRange =
          '${startDate.toIso8601String()}_${endDate.toIso8601String()}';

      await sharedPreferences.setString(_analyticsDataKey, jsonData);
      await sharedPreferences.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      await sharedPreferences.setString(_cacheDateRangeKey, dateRange);
    } catch (e) {
      // Fail silently - caching is not critical
    }
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_analyticsDataKey);
    await sharedPreferences.remove(_cacheTimestampKey);
    await sharedPreferences.remove(_cacheDateRangeKey);
  }
}
