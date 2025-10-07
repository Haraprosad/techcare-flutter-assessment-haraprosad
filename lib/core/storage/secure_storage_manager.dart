import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:techcare_assessment_app/core/exceptions/storage_exception.dart';
import 'package:techcare_assessment_app/core/storage/storage_keys.dart';
import 'package:injectable/injectable.dart';

/// Handles encrypted storage for sensitive data like auth tokens.
///
/// Uses the device's secure storage (Keychain on iOS, KeyStore on Android)
/// to keep sensitive info safe. Don't use this for regular data - it's
/// slower than SharedPreferences but much more secure.
@lazySingleton
class SecureStorageManager {
  final FlutterSecureStorage _storage;

  SecureStorageManager(this._storage);

  /// Saves encrypted data with the given key
  Future<void> writeSecureData(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw SecureStorageException(
        'Failed to write secure data for key "$key": $e',
      );
    }
  }

  /// Retrieves encrypted data by key
  Future<String?> readSecureData(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw SecureStorageException(
        'Failed to read secure data for key "$key": $e',
      );
    }
  }

  /// Deletes a specific encrypted value
  Future<void> deleteSecureData(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw SecureStorageException(
        'Failed to delete secure data for key "$key": $e',
      );
    }
  }

  /// Wipes all encrypted storage - use carefully!
  Future<void> deleteAllSecureData() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw SecureStorageException('Failed to delete all secure data: $e');
    }
  }

  /// Convenience method to save both access and refresh tokens at once
  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await writeSecureData(StorageKeys.authToken, accessToken);
    await writeSecureData(StorageKeys.refreshToken, refreshToken);
  }

  /// Gets both tokens in one go
  Future<Map<String, String?>> getAuthTokens() async {
    return {
      'accessToken': await readSecureData(StorageKeys.authToken),
      'refreshToken': await readSecureData(StorageKeys.refreshToken),
    };
  }
}
