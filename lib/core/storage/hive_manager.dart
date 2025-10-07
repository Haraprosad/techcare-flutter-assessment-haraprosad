import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/exceptions/storage_exception.dart';

/// Manager for Hive database operations
/// Provides type-safe access to Hive boxes with JSON serialization
@lazySingleton
class HiveManager {
  // Box names
  static const String _dashboardCacheBoxName = 'dashboard_cache';
  static const String _metadataBoxName = 'cache_metadata';

  Box<Map>? _dashboardBox;
  Box<int>? _timestampBox;

  /// Initialize Hive and open all required boxes
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // Open boxes
      _dashboardBox = await Hive.openBox<Map>(_dashboardCacheBoxName);
      _timestampBox = await Hive.openBox<int>(_metadataBoxName);
    } catch (e) {
      throw HiveException('Failed to initialize Hive: $e');
    }
  }

  /// Get the dashboard cache box
  Box<Map> get dashboardBox {
    if (_dashboardBox == null || !_dashboardBox!.isOpen) {
      throw HiveException(
        'Dashboard box is not initialized or has been closed',
      );
    }
    return _dashboardBox!;
  }

  /// Get the metadata box (for timestamps and other metadata)
  Box<int> get metadataBox {
    if (_timestampBox == null || !_timestampBox!.isOpen) {
      throw HiveException('Metadata box is not initialized or has been closed');
    }
    return _timestampBox!;
  }

  /// Save data to dashboard box
  Future<void> saveDashboardData(String key, Map<String, dynamic> data) async {
    try {
      await dashboardBox.put(key, data);
    } catch (e) {
      throw HiveException('Failed to save dashboard data: $e');
    }
  }

  /// Get data from dashboard box
  Map<String, dynamic>? getDashboardData(String key) {
    try {
      final data = dashboardBox.get(key);
      if (data == null) return null;

      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      return Map<String, dynamic>.from(data);
    } catch (e) {
      throw HiveException('Failed to get dashboard data: $e');
    }
  }

  /// Delete data from dashboard box
  Future<void> deleteDashboardData(String key) async {
    try {
      await dashboardBox.delete(key);
    } catch (e) {
      throw HiveException('Failed to delete dashboard data: $e');
    }
  }

  /// Save timestamp to metadata box
  Future<void> saveTimestamp(String key, int timestamp) async {
    try {
      await metadataBox.put(key, timestamp);
    } catch (e) {
      throw HiveException('Failed to save timestamp: $e');
    }
  }

  /// Get timestamp from metadata box
  int? getTimestamp(String key) {
    try {
      return metadataBox.get(key);
    } catch (e) {
      throw HiveException('Failed to get timestamp: $e');
    }
  }

  /// Delete timestamp from metadata box
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
