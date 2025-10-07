import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/exceptions/storage_exception.dart';

/// Manages Hive database operations for local data caching.
///
/// Hive is our NoSQL database for storing things like dashboard data
/// that we want to cache locally. It's faster than hitting the API
/// every time and works great for offline support.
@lazySingleton
class HiveManager {
  // Box names - think of these as table names
  static const String _dashboardCacheBoxName = 'dashboard_cache';
  static const String _metadataBoxName = 'cache_metadata';

  Box<Map>? _dashboardBox;
  Box<int>? _timestampBox;

  /// Opens up the Hive database when the app starts
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // Open our storage boxes
      _dashboardBox = await Hive.openBox<Map>(_dashboardCacheBoxName);
      _timestampBox = await Hive.openBox<int>(_metadataBoxName);
    } catch (e) {
      throw HiveException('Failed to initialize Hive: $e');
    }
  }

  /// Access the box where we store dashboard data
  Box<Map> get dashboardBox {
    if (_dashboardBox == null || !_dashboardBox!.isOpen) {
      throw HiveException(
        'Dashboard box is not initialized or has been closed',
      );
    }
    return _dashboardBox!;
  }

  /// Access the box where we store timestamps and other metadata
  Box<int> get metadataBox {
    if (_timestampBox == null || !_timestampBox!.isOpen) {
      throw HiveException('Metadata box is not initialized or has been closed');
    }
    return _timestampBox!;
  }

  /// Saves dashboard data to the cache
  Future<void> saveDashboardData(String key, Map<String, dynamic> data) async {
    try {
      await dashboardBox.put(key, data);
    } catch (e) {
      throw HiveException('Failed to save dashboard data: $e');
    }
  }

  /// Gets cached dashboard data if it exists
  Map<String, dynamic>? getDashboardData(String key) {
    try {
      final data = dashboardBox.get(key);
      if (data == null) return null;

      // Hive returns Map<dynamic, dynamic> but we want proper types
      return Map<String, dynamic>.from(data);
    } catch (e) {
      throw HiveException('Failed to get dashboard data: $e');
    }
  }

  /// Removes a specific piece of cached data
  Future<void> deleteDashboardData(String key) async {
    try {
      await dashboardBox.delete(key);
    } catch (e) {
      throw HiveException('Failed to delete dashboard data: $e');
    }
  }

  /// Saves a timestamp - useful for knowing when we last cached something
  Future<void> saveTimestamp(String key, int timestamp) async {
    try {
      await metadataBox.put(key, timestamp);
    } catch (e) {
      throw HiveException('Failed to save timestamp: $e');
    }
  }

  /// Gets a saved timestamp
  int? getTimestamp(String key) {
    try {
      return metadataBox.get(key);
    } catch (e) {
      throw HiveException('Failed to get timestamp: $e');
    }
  }

  /// Deletes a timestamp
  Future<void> deleteTimestamp(String key) async {
    try {
      await metadataBox.delete(key);
    } catch (e) {
      throw HiveException('Failed to delete timestamp: $e');
    }
  }

  /// Clear all dashboard cache
  Future<void> clearDashboardCache() async {
    try {
      await Future.wait([dashboardBox.clear(), metadataBox.clear()]);
    } catch (e) {
      throw HiveException('Failed to clear dashboard cache: $e');
    }
  }

  /// Close all boxes
  Future<void> close() async {
    try {
      await Future.wait([
        if (_dashboardBox?.isOpen ?? false) _dashboardBox!.close(),
        if (_timestampBox?.isOpen ?? false) _timestampBox!.close(),
      ]);
    } catch (e) {
      throw HiveException('Failed to close Hive boxes: $e');
    }
  }

  /// Compact boxes to reduce storage size
  Future<void> compact() async {
    try {
      await Future.wait([
        if (_dashboardBox?.isOpen ?? false) _dashboardBox!.compact(),
        if (_timestampBox?.isOpen ?? false) _timestampBox!.compact(),
      ]);
    } catch (e) {
      throw HiveException('Failed to compact Hive boxes: $e');
    }
  }
}

/// Custom exception for Hive-related errors
class HiveException extends StorageException {
  HiveException(String message) : super(message, null);
}
