import 'package:techcare_assessment_app/core/storage/secure_storage_manager.dart';
import 'package:techcare_assessment_app/core/storage/preferences_manager.dart';
import 'package:techcare_assessment_app/core/storage/hive_manager.dart';
import 'package:injectable/injectable.dart';

/// Central access point for all storage mechanisms in the app.
///
/// Brings together secure storage (for sensitive data like tokens),
/// shared preferences (for simple settings), and Hive (for caching).
/// Makes it easy to access any type of storage without juggling multiple managers.
@lazySingleton
class AppStorage {
  final SecureStorageManager _secureStorage;
  final PreferencesManager _preferences;
  final HiveManager _hiveManager;

  AppStorage(this._secureStorage, this._preferences, this._hiveManager);

  /// For storing sensitive data like auth tokens
  SecureStorageManager get secure => _secureStorage;

  /// For simple key-value pairs like user preferences
  PreferencesManager get preferences => _preferences;

  /// For caching structured data like dashboard info
  HiveManager get hive => _hiveManager;

  /// Nuclear option - wipes all stored data from every storage type
  Future<void> clearAllData() async {
    await _secureStorage.deleteAllSecureData();
    await _preferences.clearAll();
    await _hiveManager.clearDashboardCache();
  }
}
