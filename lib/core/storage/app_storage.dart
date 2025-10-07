import 'package:techcare_assessment_app/core/storage/secure_storage_manager.dart';
import 'package:techcare_assessment_app/core/storage/preferences_manager.dart';
import 'package:techcare_assessment_app/core/storage/hive_manager.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AppStorage {
  final SecureStorageManager _secureStorage;
  final PreferencesManager _preferences;
  final HiveManager _hiveManager;

  AppStorage(this._secureStorage, this._preferences, this._hiveManager);

  SecureStorageManager get secure => _secureStorage;
  PreferencesManager get preferences => _preferences;
  HiveManager get hive => _hiveManager;

  // Cleanup method
  Future<void> clearAllData() async {
    await _secureStorage.deleteAllSecureData();
    await _preferences.clearAll();
    await _hiveManager.clearDashboardCache();
  }
}
