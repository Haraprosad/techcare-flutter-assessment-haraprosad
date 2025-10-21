import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:techcare_assessment_app/core/exceptions/storage_exception.dart';
import 'package:techcare_assessment_app/core/storage/secure_storage_manager.dart';
import 'package:techcare_assessment_app/core/storage/storage_keys.dart';

/// Mock class for FlutterSecureStorage
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

/// Unit tests for SecureStorageManager
///
/// This test suite validates:
/// 1. Writing secure data (encryption)
/// 2. Reading secure data (decryption)
/// 3. Deleting specific secure data
/// 4. Deleting all secure data
/// 5. Auth token management (save/retrieve both tokens)
/// 6. Error handling for all operations
///
/// Testing Strategy:
/// - Mock FlutterSecureStorage to isolate from platform
/// - Test all CRUD operations (Create, Read, Delete)
/// - Verify correct key usage
/// - Test exception handling
/// - Validate convenience methods for auth tokens
void main() {
  group('SecureStorageManager', () {
    late SecureStorageManager secureStorageManager;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      secureStorageManager = SecureStorageManager(mockStorage);
    });

    group('Write secure data', () {
      test('should write secure data successfully', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        when(
          () => mockStorage.write(key: key, value: value),
        ).thenAnswer((_) async => {});

        // Act
        await secureStorageManager.writeSecureData(key, value);

        // Assert
        verify(() => mockStorage.write(key: key, value: value)).called(1);
      });

      test('should write sensitive data like passwords', () async {
        // Arrange
        const key = 'user_password';
        const value = 'SecureP@ssw0rd123!';
        when(
          () => mockStorage.write(key: key, value: value),
        ).thenAnswer((_) async => {});

        // Act
        await secureStorageManager.writeSecureData(key, value);

        // Assert
        verify(() => mockStorage.write(key: key, value: value)).called(1);
      });

      test('should write auth token', () async {
        // Arrange
        const key = StorageKeys.authToken;
        const value = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
        when(
          () => mockStorage.write(key: key, value: value),
        ).thenAnswer((_) async => {});

        // Act
        await secureStorageManager.writeSecureData(key, value);

        // Assert
        verify(() => mockStorage.write(key: key, value: value)).called(1);
      });

      test('should throw SecureStorageException when write fails', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        when(
          () => mockStorage.write(key: key, value: value),
        ).thenThrow(Exception('Write error'));

        // Act & Assert
        expect(
          () => secureStorageManager.writeSecureData(key, value),
          throwsA(isA<SecureStorageException>()),
        );
      });

      test(
        'should include key in exception message when write fails',
        () async {
          // Arrange
          const key = 'sensitive_key';
          const value = 'sensitive_value';
          when(
            () => mockStorage.write(key: key, value: value),
          ).thenThrow(Exception('Write error'));

          // Act & Assert
          try {
            await secureStorageManager.writeSecureData(key, value);
            fail('Should have thrown SecureStorageException');
          } catch (e) {
            expect(e, isA<SecureStorageException>());
            expect(
              (e as SecureStorageException).message,
              contains('sensitive_key'),
            );
          }
        },
      );
    });

    group('Read secure data', () {
      test('should read secure data successfully', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        when(() => mockStorage.read(key: key)).thenAnswer((_) async => value);

        // Act
        final result = await secureStorageManager.readSecureData(key);

        // Assert
        expect(result, value);
        verify(() => mockStorage.read(key: key)).called(1);
      });

      test('should return null when key does not exist', () async {
        // Arrange
        const key = 'non_existent_key';
        when(() => mockStorage.read(key: key)).thenAnswer((_) async => null);

        // Act
        final result = await secureStorageManager.readSecureData(key);

        // Assert
        expect(result, null);
      });

      test('should read auth token', () async {
        // Arrange
        const key = StorageKeys.authToken;
        const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
        when(() => mockStorage.read(key: key)).thenAnswer((_) async => token);

        // Act
        final result = await secureStorageManager.readSecureData(key);

        // Assert
        expect(result, token);
      });

      test('should read refresh token', () async {
        // Arrange
        const key = StorageKeys.refreshToken;
        const token = 'refresh_token_xyz123';
        when(() => mockStorage.read(key: key)).thenAnswer((_) async => token);

        // Act
        final result = await secureStorageManager.readSecureData(key);

        // Assert
        expect(result, token);
      });

      test('should throw SecureStorageException when read fails', () async {
        // Arrange
        const key = 'test_key';
        when(
          () => mockStorage.read(key: key),
        ).thenThrow(Exception('Read error'));

        // Act & Assert
        expect(
          () => secureStorageManager.readSecureData(key),
          throwsA(isA<SecureStorageException>()),
        );
      });

      test('should include key in exception message when read fails', () async {
        // Arrange
        const key = 'sensitive_key';
        when(
          () => mockStorage.read(key: key),
        ).thenThrow(Exception('Read error'));

        // Act & Assert
        try {
          await secureStorageManager.readSecureData(key);
          fail('Should have thrown SecureStorageException');
        } catch (e) {
          expect(e, isA<SecureStorageException>());
          expect(
            (e as SecureStorageException).message,
            contains('sensitive_key'),
          );
        }
      });
    });

    group('Delete secure data', () {
      test('should delete secure data successfully', () async {
        // Arrange
        const key = 'test_key';
        when(() => mockStorage.delete(key: key)).thenAnswer((_) async => {});

        // Act
        await secureStorageManager.deleteSecureData(key);

        // Assert
        verify(() => mockStorage.delete(key: key)).called(1);
      });

      test('should delete auth token', () async {
        // Arrange
        const key = StorageKeys.authToken;
        when(() => mockStorage.delete(key: key)).thenAnswer((_) async => {});

        // Act
        await secureStorageManager.deleteSecureData(key);

        // Assert
        verify(() => mockStorage.delete(key: key)).called(1);
      });

      test('should delete non-existent key without error', () async {
        // Arrange
        const key = 'non_existent_key';
        when(() => mockStorage.delete(key: key)).thenAnswer((_) async => {});

        // Act
        await secureStorageManager.deleteSecureData(key);

        // Assert
        verify(() => mockStorage.delete(key: key)).called(1);
      });

      test('should throw SecureStorageException when delete fails', () async {
        // Arrange
        const key = 'test_key';
        when(
          () => mockStorage.delete(key: key),
        ).thenThrow(Exception('Delete error'));

        // Act & Assert
        expect(
          () => secureStorageManager.deleteSecureData(key),
          throwsA(isA<SecureStorageException>()),
        );
      });

      test(
        'should include key in exception message when delete fails',
        () async {
          // Arrange
          const key = 'sensitive_key';
          when(
            () => mockStorage.delete(key: key),
          ).thenThrow(Exception('Delete error'));

          // Act & Assert
          try {
            await secureStorageManager.deleteSecureData(key);
            fail('Should have thrown SecureStorageException');
          } catch (e) {
            expect(e, isA<SecureStorageException>());
            expect(
              (e as SecureStorageException).message,
              contains('sensitive_key'),
            );
          }
        },
      );
    });

    group('Delete all secure data', () {
      test('should delete all secure data successfully', () async {
        // Arrange
        when(() => mockStorage.deleteAll()).thenAnswer((_) async => {});

        // Act
        await secureStorageManager.deleteAllSecureData();

        // Assert
        verify(() => mockStorage.deleteAll()).called(1);
      });

      test(
        'should throw SecureStorageException when deleteAll fails',
        () async {
          // Arrange
          when(
            () => mockStorage.deleteAll(),
          ).thenThrow(Exception('DeleteAll error'));

          // Act & Assert
          expect(
            () => secureStorageManager.deleteAllSecureData(),
            throwsA(isA<SecureStorageException>()),
          );
        },
      );

      test(
        'should not include key in exception message for deleteAll',
        () async {
          // Arrange
          when(
            () => mockStorage.deleteAll(),
          ).thenThrow(Exception('DeleteAll error'));

          // Act & Assert
          try {
            await secureStorageManager.deleteAllSecureData();
            fail('Should have thrown SecureStorageException');
          } catch (e) {
            expect(e, isA<SecureStorageException>());
            expect(
              (e as SecureStorageException).message,
              contains('delete all'),
            );
          }
        },
      );
    });

    group('Auth tokens convenience methods', () {
      test('should save both auth tokens successfully', () async {
        // Arrange
        const accessToken = 'access_token_abc123';
        const refreshToken = 'refresh_token_xyz789';

        when(
          () =>
              mockStorage.write(key: StorageKeys.authToken, value: accessToken),
        ).thenAnswer((_) async => {});

        when(
          () => mockStorage.write(
            key: StorageKeys.refreshToken,
            value: refreshToken,
          ),
        ).thenAnswer((_) async => {});

        // Act
        await secureStorageManager.saveAuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Assert
        verify(
          () =>
              mockStorage.write(key: StorageKeys.authToken, value: accessToken),
        ).called(1);

        verify(
          () => mockStorage.write(
            key: StorageKeys.refreshToken,
            value: refreshToken,
          ),
        ).called(1);
      });

      test('should retrieve both auth tokens successfully', () async {
        // Arrange
        const accessToken = 'access_token_abc123';
        const refreshToken = 'refresh_token_xyz789';

        when(
          () => mockStorage.read(key: StorageKeys.authToken),
        ).thenAnswer((_) async => accessToken);

        when(
          () => mockStorage.read(key: StorageKeys.refreshToken),
        ).thenAnswer((_) async => refreshToken);

        // Act
        final result = await secureStorageManager.getAuthTokens();

        // Assert
        expect(result['accessToken'], accessToken);
        expect(result['refreshToken'], refreshToken);
        verify(() => mockStorage.read(key: StorageKeys.authToken)).called(1);
        verify(() => mockStorage.read(key: StorageKeys.refreshToken)).called(1);
      });

      test('should return null tokens when not set', () async {
        // Arrange
        when(
          () => mockStorage.read(key: StorageKeys.authToken),
        ).thenAnswer((_) async => null);

        when(
          () => mockStorage.read(key: StorageKeys.refreshToken),
        ).thenAnswer((_) async => null);

        // Act
        final result = await secureStorageManager.getAuthTokens();

        // Assert
        expect(result['accessToken'], null);
        expect(result['refreshToken'], null);
      });

      test('should return partial tokens when only one is set', () async {
        // Arrange
        const accessToken = 'access_token_abc123';

        when(
          () => mockStorage.read(key: StorageKeys.authToken),
        ).thenAnswer((_) async => accessToken);

        when(
          () => mockStorage.read(key: StorageKeys.refreshToken),
        ).thenAnswer((_) async => null);

        // Act
        final result = await secureStorageManager.getAuthTokens();

        // Assert
        expect(result['accessToken'], accessToken);
        expect(result['refreshToken'], null);
      });

      test('should handle error when saving access token fails', () async {
        // Arrange
        const accessToken = 'access_token_abc123';
        const refreshToken = 'refresh_token_xyz789';

        when(
          () =>
              mockStorage.write(key: StorageKeys.authToken, value: accessToken),
        ).thenThrow(Exception('Write error'));

        // Act & Assert
        expect(
          () => secureStorageManager.saveAuthTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
          throwsA(isA<SecureStorageException>()),
        );
      });

      test('should handle error when saving refresh token fails', () async {
        // Arrange
        const accessToken = 'access_token_abc123';
        const refreshToken = 'refresh_token_xyz789';

        when(
          () =>
              mockStorage.write(key: StorageKeys.authToken, value: accessToken),
        ).thenAnswer((_) async => {});

        when(
          () => mockStorage.write(
            key: StorageKeys.refreshToken,
            value: refreshToken,
          ),
        ).thenThrow(Exception('Write error'));

        // Act & Assert
        expect(
          () => secureStorageManager.saveAuthTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
          throwsA(isA<SecureStorageException>()),
        );
      });
    });

    group('Integration scenarios', () {
      test('should handle complete login flow', () async {
        // Arrange
        const accessToken = 'login_access_token';
        const refreshToken = 'login_refresh_token';

        when(
          () =>
              mockStorage.write(key: StorageKeys.authToken, value: accessToken),
        ).thenAnswer((_) async => {});

        when(
          () => mockStorage.write(
            key: StorageKeys.refreshToken,
            value: refreshToken,
          ),
        ).thenAnswer((_) async => {});

        when(
          () => mockStorage.read(key: StorageKeys.authToken),
        ).thenAnswer((_) async => accessToken);

        when(
          () => mockStorage.read(key: StorageKeys.refreshToken),
        ).thenAnswer((_) async => refreshToken);

        // Act: Save tokens (login)
        await secureStorageManager.saveAuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Act: Retrieve tokens
        final tokens = await secureStorageManager.getAuthTokens();

        // Assert
        expect(tokens['accessToken'], accessToken);
        expect(tokens['refreshToken'], refreshToken);
      });

      test('should handle complete logout flow', () async {
        // Arrange
        when(
          () => mockStorage.delete(key: StorageKeys.authToken),
        ).thenAnswer((_) async => {});

        when(
          () => mockStorage.delete(key: StorageKeys.refreshToken),
        ).thenAnswer((_) async => {});

        when(
          () => mockStorage.read(key: StorageKeys.authToken),
        ).thenAnswer((_) async => null);

        when(
          () => mockStorage.read(key: StorageKeys.refreshToken),
        ).thenAnswer((_) async => null);

        // Act: Delete tokens (logout)
        await secureStorageManager.deleteSecureData(StorageKeys.authToken);
        await secureStorageManager.deleteSecureData(StorageKeys.refreshToken);

        // Act: Try to retrieve tokens
        final tokens = await secureStorageManager.getAuthTokens();

        // Assert
        expect(tokens['accessToken'], null);
        expect(tokens['refreshToken'], null);
      });

      test('should handle complete app reset', () async {
        // Arrange
        when(() => mockStorage.deleteAll()).thenAnswer((_) async => {});

        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => null);

        // Act: Clear all secure data
        await secureStorageManager.deleteAllSecureData();

        // Act: Try to retrieve any data
        final tokens = await secureStorageManager.getAuthTokens();
        final customData = await secureStorageManager.readSecureData(
          'custom_key',
        );

        // Assert: All data should be gone
        expect(tokens['accessToken'], null);
        expect(tokens['refreshToken'], null);
        expect(customData, null);
      });

      test('should handle write-read-delete cycle', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';

        when(
          () => mockStorage.write(key: key, value: value),
        ).thenAnswer((_) async => {});

        when(() => mockStorage.read(key: key)).thenAnswer((_) async => value);

        when(() => mockStorage.delete(key: key)).thenAnswer((_) async => {});

        // Act & Assert: Write
        await secureStorageManager.writeSecureData(key, value);
        verify(() => mockStorage.write(key: key, value: value)).called(1);

        // Act & Assert: Read
        final readValue = await secureStorageManager.readSecureData(key);
        expect(readValue, value);

        // Act & Assert: Delete
        await secureStorageManager.deleteSecureData(key);
        verify(() => mockStorage.delete(key: key)).called(1);
      });
    });
  });
}
