import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techcare_assessment_app/core/exceptions/storage_exception.dart';
import 'package:techcare_assessment_app/core/storage/preferences_manager.dart';
import 'package:techcare_assessment_app/core/storage/storage_keys.dart';

/// Mock class for SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

/// Unit tests for PreferencesManager
///
/// This test suite validates:
/// 1. Theme settings (dark mode)
/// 2. Language preferences
/// 3. Authentication state
/// 4. User information (ID, email, phone, role)
/// 5. Cart token management
/// 6. Generic storage methods (string, int)
/// 7. Clear operations
/// 8. Error handling
///
/// Testing Strategy:
/// - Mock SharedPreferences to isolate from platform
/// - Test all getter/setter pairs
/// - Verify default values
/// - Test exception handling
/// - Validate key usage
void main() {
  group('PreferencesManager', () {
    late PreferencesManager preferencesManager;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      preferencesManager = PreferencesManager(mockPrefs);
    });

    group('Theme settings', () {
      test('should set dark mode to true', () async {
        // Arrange
        when(
          () => mockPrefs.setBool(StorageKeys.isDarkMode, true),
        ).thenAnswer((_) async => true);

        // Act
        await preferencesManager.setDarkMode(true);

        // Assert
        verify(() => mockPrefs.setBool(StorageKeys.isDarkMode, true)).called(1);
      });

      test('should set dark mode to false', () async {
        // Arrange
        when(
          () => mockPrefs.setBool(StorageKeys.isDarkMode, false),
        ).thenAnswer((_) async => true);

        // Act
        await preferencesManager.setDarkMode(false);

        // Assert
        verify(
          () => mockPrefs.setBool(StorageKeys.isDarkMode, false),
        ).called(1);
      });

      test('should get dark mode when set to true', () {
        // Arrange
        when(() => mockPrefs.getBool(StorageKeys.isDarkMode)).thenReturn(true);

        // Act
        final result = preferencesManager.getDarkMode();

        // Assert
        expect(result, true);
        verify(() => mockPrefs.getBool(StorageKeys.isDarkMode)).called(1);
      });

      test('should get dark mode when set to false', () {
        // Arrange
        when(() => mockPrefs.getBool(StorageKeys.isDarkMode)).thenReturn(false);

        // Act
        final result = preferencesManager.getDarkMode();

        // Assert
        expect(result, false);
      });

      test('should return false as default when dark mode not set', () {
        // Arrange
        when(() => mockPrefs.getBool(StorageKeys.isDarkMode)).thenReturn(null);

        // Act
        final result = preferencesManager.getDarkMode();

        // Assert
        expect(result, false); // Default value
      });

      test(
        'should throw PreferencesException when setting dark mode fails',
        () async {
          // Arrange
          when(
            () => mockPrefs.setBool(StorageKeys.isDarkMode, true),
          ).thenThrow(Exception('Storage error'));

          // Act & Assert
          expect(
            () => preferencesManager.setDarkMode(true),
            throwsA(isA<PreferencesException>()),
          );
        },
      );
    });

    group('Language preferences', () {
      test('should set language preference', () async {
        // Arrange
        when(
          () => mockPrefs.setString(StorageKeys.language, 'es'),
        ).thenAnswer((_) async => true);

        // Act
        await preferencesManager.setLanguage('es');

        // Assert
        verify(() => mockPrefs.setString(StorageKeys.language, 'es')).called(1);
      });

      test('should get language preference', () {
        // Arrange
        when(() => mockPrefs.getString(StorageKeys.language)).thenReturn('fr');

        // Act
        final result = preferencesManager.getLanguage();

        // Assert
        expect(result, 'fr');
        verify(() => mockPrefs.getString(StorageKeys.language)).called(1);
      });

      test('should return "en" as default language', () {
        // Arrange
        when(() => mockPrefs.getString(StorageKeys.language)).thenReturn(null);

        // Act
        final result = preferencesManager.getLanguage();

        // Assert
        expect(result, 'en'); // Default value
      });

      test(
        'should throw PreferencesException when setting language fails',
        () async {
          // Arrange
          when(
            () => mockPrefs.setString(StorageKeys.language, 'es'),
          ).thenThrow(Exception('Storage error'));

          // Act & Assert
          expect(
            () => preferencesManager.setLanguage('es'),
            throwsA(isA<PreferencesException>()),
          );
        },
      );
    });

    group('Authentication state', () {
      test('should set authentication state to true', () async {
        // Arrange
        when(
          () => mockPrefs.setBool(StorageKeys.isAuthenticated, true),
        ).thenAnswer((_) async => true);

        // Act
        await preferencesManager.setIsAuthenticated(true);

        // Assert
        verify(
          () => mockPrefs.setBool(StorageKeys.isAuthenticated, true),
        ).called(1);
      });

      test('should get authentication state', () {
        // Arrange
        when(
          () => mockPrefs.getBool(StorageKeys.isAuthenticated),
        ).thenReturn(true);

        // Act
        final result = preferencesManager.getIsAuthenticated();

        // Assert
        expect(result, true);
      });

      test('should return false as default authentication state', () {
        // Arrange
        when(
          () => mockPrefs.getBool(StorageKeys.isAuthenticated),
        ).thenReturn(null);

        // Act
        final result = preferencesManager.getIsAuthenticated();

        // Assert
        expect(result, false); // Default value
      });

      test(
        'should throw PreferencesException when setting auth state fails',
        () async {
          // Arrange
          when(
            () => mockPrefs.setBool(StorageKeys.isAuthenticated, true),
          ).thenThrow(Exception('Storage error'));

          // Act & Assert
          expect(
            () => preferencesManager.setIsAuthenticated(true),
            throwsA(isA<PreferencesException>()),
          );
        },
      );
    });

    group('User role', () {
      test('should set user role', () async {
        // Arrange
        when(
          () => mockPrefs.setString(StorageKeys.userRole, 'admin'),
        ).thenAnswer((_) async => true);

        // Act
        await preferencesManager.setUserRole('admin');

        // Assert
        verify(
          () => mockPrefs.setString(StorageKeys.userRole, 'admin'),
        ).called(1);
      });

      test('should get user role', () {
        // Arrange
        when(
          () => mockPrefs.getString(StorageKeys.userRole),
        ).thenReturn('user');

        // Act
        final result = preferencesManager.getUserRole();

        // Assert
        expect(result, 'user');
      });

      test('should return null when user role not set', () {
        // Arrange
        when(() => mockPrefs.getString(StorageKeys.userRole)).thenReturn(null);

        // Act
        final result = preferencesManager.getUserRole();

        // Assert
        expect(result, null);
      });

      test(
        'should throw PreferencesException when setting user role fails',
        () async {
          // Arrange
          when(
            () => mockPrefs.setString(StorageKeys.userRole, 'admin'),
          ).thenThrow(Exception('Storage error'));

          // Act & Assert
          expect(
            () => preferencesManager.setUserRole('admin'),
            throwsA(isA<PreferencesException>()),
          );
        },
      );
    });

    group('User ID', () {
      test('should set user ID', () async {
        // Arrange
        when(
          () => mockPrefs.setString(StorageKeys.userId, '12345'),
        ).thenAnswer((_) async => true);

        // Act
        await preferencesManager.setUserId('12345');

        // Assert
        verify(
          () => mockPrefs.setString(StorageKeys.userId, '12345'),
        ).called(1);
      });

      test('should get user ID', () {
        // Arrange
        when(() => mockPrefs.getString(StorageKeys.userId)).thenReturn('67890');

        // Act
        final result = preferencesManager.getUserId();

        // Assert
        expect(result, '67890');
      });

      test('should return null when user ID not set', () {
        // Arrange
        when(() => mockPrefs.getString(StorageKeys.userId)).thenReturn(null);

        // Act
        final result = preferencesManager.getUserId();

        // Assert
        expect(result, null);
      });

      test(
        'should throw PreferencesException when setting user ID fails',
        () async {
          // Arrange
          when(
            () => mockPrefs.setString(StorageKeys.userId, '12345'),
          ).thenThrow(Exception('Storage error'));

          // Act & Assert
          expect(
            () => preferencesManager.setUserId('12345'),
            throwsA(isA<PreferencesException>()),
          );
        },
      );
    });

    group('User email', () {
      test('should set user email', () async {
        // Arrange
        when(
          () => mockPrefs.setString(StorageKeys.userEmail, 'test@example.com'),
        ).thenAnswer((_) async => true);

        // Act
        await preferencesManager.setUserEmail('test@example.com');

        // Assert
        verify(
          () => mockPrefs.setString(StorageKeys.userEmail, 'test@example.com'),
        ).called(1);
      });

      test('should get user email', () {
        // Arrange
        when(
          () => mockPrefs.getString(StorageKeys.userEmail),
        ).thenReturn('user@example.com');

        // Act
        final result = preferencesManager.getUserEmail();

        // Assert
        expect(result, 'user@example.com');
      });

      test('should return null when user email not set', () {
        // Arrange
        when(() => mockPrefs.getString(StorageKeys.userEmail)).thenReturn(null);

        // Act
        final result = preferencesManager.getUserEmail();

        // Assert
        expect(result, null);
      });

      test(
        'should throw PreferencesException when setting user email fails',
        () async {
          // Arrange
          when(
            () =>
                mockPrefs.setString(StorageKeys.userEmail, 'test@example.com'),
          ).thenThrow(Exception('Storage error'));

          // Act & Assert
          expect(
            () => preferencesManager.setUserEmail('test@example.com'),
            throwsA(isA<PreferencesException>()),
          );
        },
      );
    });

    group('User phone', () {
      test('should set user phone', () async {
        // Arrange
        when(
          () => mockPrefs.setString(StorageKeys.userPhone, '+1234567890'),
        ).thenAnswer((_) async => true);

        // Act
        await preferencesManager.setUserPhone('+1234567890');

        // Assert
        verify(
          () => mockPrefs.setString(StorageKeys.userPhone, '+1234567890'),
        ).called(1);
      });

      test('should get user phone', () {
        // Arrange
        when(
          () => mockPrefs.getString(StorageKeys.userPhone),
        ).thenReturn('+9876543210');

        // Act
        final result = preferencesManager.getUserPhone();

        // Assert
        expect(result, '+9876543210');
      });

      test('should return null when user phone not set', () {
        // Arrange
        when(() => mockPrefs.getString(StorageKeys.userPhone)).thenReturn(null);

        // Act
        final result = preferencesManager.getUserPhone();

        // Assert
        expect(result, null);
      });

      test(
        'should throw PreferencesException when setting user phone fails',
        () async {
          // Arrange
          when(
            () => mockPrefs.setString(StorageKeys.userPhone, '+1234567890'),
          ).thenThrow(Exception('Storage error'));

          // Act & Assert
          expect(
            () => preferencesManager.setUserPhone('+1234567890'),
            throwsA(isA<PreferencesException>()),
          );
        },
      );
    });

    group('Cart token', () {
      test('should set cart token', () async {
        // Arrange
        when(
          () => mockPrefs.setString(StorageKeys.cartToken, 'token123'),
        ).thenAnswer((_) async => true);

        // Act
        await preferencesManager.setCartToken('token123');

        // Assert
        verify(
          () => mockPrefs.setString(StorageKeys.cartToken, 'token123'),
        ).called(1);
      });

      test('should get cart token', () {
        // Arrange
        when(
          () => mockPrefs.getString(StorageKeys.cartToken),
        ).thenReturn('token456');

        // Act
        final result = preferencesManager.getCartToken();

        // Assert
        expect(result, 'token456');
      });

      test('should return null when cart token not set', () {
        // Arrange
        when(() => mockPrefs.getString(StorageKeys.cartToken)).thenReturn(null);

        // Act
        final result = preferencesManager.getCartToken();

        // Assert
        expect(result, null);
      });

      test('should clear cart token', () async {
        // Arrange
        when(
          () => mockPrefs.remove(StorageKeys.cartToken),
        ).thenAnswer((_) async => true);

        // Act
        await preferencesManager.clearCartToken();

        // Assert
        verify(() => mockPrefs.remove(StorageKeys.cartToken)).called(1);
      });

      test(
        'should throw PreferencesException when setting cart token fails',
        () async {
          // Arrange
          when(
            () => mockPrefs.setString(StorageKeys.cartToken, 'token123'),
          ).thenThrow(Exception('Storage error'));

          // Act & Assert
          expect(
            () => preferencesManager.setCartToken('token123'),
            throwsA(isA<PreferencesException>()),
          );
        },
      );

      test(
        'should throw PreferencesException when clearing cart token fails',
        () async {
          // Arrange
          when(
            () => mockPrefs.remove(StorageKeys.cartToken),
          ).thenThrow(Exception('Storage error'));

          // Act & Assert
          expect(
            () => preferencesManager.clearCartToken(),
            throwsA(isA<PreferencesException>()),
          );
        },
      );
    });

    group('Generic string methods', () {
      test('should set string value', () async {
        // Arrange
        when(
          () => mockPrefs.setString('custom_key', 'custom_value'),
        ).thenAnswer((_) async => true);

        // Act
        await preferencesManager.setString('custom_key', 'custom_value');

        // Assert
        verify(
          () => mockPrefs.setString('custom_key', 'custom_value'),
        ).called(1);
      });

      test('should get string value', () {
        // Arrange
        when(() => mockPrefs.getString('custom_key')).thenReturn('my_value');

        // Act
        final result = preferencesManager.getString('custom_key');

        // Assert
        expect(result, 'my_value');
      });

      test('should return null when string key not found', () {
        // Arrange
        when(() => mockPrefs.getString('unknown_key')).thenReturn(null);

        // Act
        final result = preferencesManager.getString('unknown_key');

        // Assert
        expect(result, null);
      });

      test(
        'should throw PreferencesException when setting string fails',
        () async {
          // Arrange
          when(
            () => mockPrefs.setString('key', 'value'),
          ).thenThrow(Exception('Storage error'));

          // Act & Assert
          expect(
            () => preferencesManager.setString('key', 'value'),
            throwsA(isA<PreferencesException>()),
          );
        },
      );
    });

    group('Generic int methods', () {
      test('should set int value', () async {
        // Arrange
        when(
          () => mockPrefs.setInt('counter', 42),
        ).thenAnswer((_) async => true);

        // Act
        await preferencesManager.setInt('counter', 42);

        // Assert
        verify(() => mockPrefs.setInt('counter', 42)).called(1);
      });

      test('should get int value', () {
        // Arrange
        when(() => mockPrefs.getInt('counter')).thenReturn(100);

        // Act
        final result = preferencesManager.getInt('counter');

        // Assert
        expect(result, 100);
      });

      test('should return null when int key not found', () {
        // Arrange
        when(() => mockPrefs.getInt('unknown_counter')).thenReturn(null);

        // Act
        final result = preferencesManager.getInt('unknown_counter');

        // Assert
        expect(result, null);
      });

      test(
        'should throw PreferencesException when setting int fails',
        () async {
          // Arrange
          when(
            () => mockPrefs.setInt('counter', 42),
          ).thenThrow(Exception('Storage error'));

          // Act & Assert
          expect(
            () => preferencesManager.setInt('counter', 42),
            throwsA(isA<PreferencesException>()),
          );
        },
      );
    });

    group('Remove operations', () {
      test('should remove key', () async {
        // Arrange
        when(() => mockPrefs.remove('temp_key')).thenAnswer((_) async => true);

        // Act
        await preferencesManager.remove('temp_key');

        // Assert
        verify(() => mockPrefs.remove('temp_key')).called(1);
      });

      test('should throw PreferencesException when remove fails', () async {
        // Arrange
        when(
          () => mockPrefs.remove('temp_key'),
        ).thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => preferencesManager.remove('temp_key'),
          throwsA(isA<PreferencesException>()),
        );
      });
    });

    group('Clear all preferences', () {
      test('should clear all preferences', () async {
        // Arrange
        when(() => mockPrefs.clear()).thenAnswer((_) async => true);

        // Act
        await preferencesManager.clearAll();

        // Assert
        verify(() => mockPrefs.clear()).called(1);
      });

      test('should throw PreferencesException when clear fails', () async {
        // Arrange
        when(() => mockPrefs.clear()).thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => preferencesManager.clearAll(),
          throwsA(isA<PreferencesException>()),
        );
      });
    });

    group('Integration scenarios', () {
      test('should handle complete user session flow', () async {
        // Arrange
        when(
          () => mockPrefs.setBool(StorageKeys.isAuthenticated, true),
        ).thenAnswer((_) async => true);
        when(
          () => mockPrefs.setString(StorageKeys.userId, 'user123'),
        ).thenAnswer((_) async => true);
        when(
          () => mockPrefs.setString(StorageKeys.userEmail, 'user@test.com'),
        ).thenAnswer((_) async => true);
        when(
          () => mockPrefs.setString(StorageKeys.userRole, 'admin'),
        ).thenAnswer((_) async => true);

        when(
          () => mockPrefs.getBool(StorageKeys.isAuthenticated),
        ).thenReturn(true);
        when(
          () => mockPrefs.getString(StorageKeys.userId),
        ).thenReturn('user123');
        when(
          () => mockPrefs.getString(StorageKeys.userEmail),
        ).thenReturn('user@test.com');
        when(
          () => mockPrefs.getString(StorageKeys.userRole),
        ).thenReturn('admin');

        // Act: Set user session
        await preferencesManager.setIsAuthenticated(true);
        await preferencesManager.setUserId('user123');
        await preferencesManager.setUserEmail('user@test.com');
        await preferencesManager.setUserRole('admin');

        // Assert: Retrieve user session
        expect(preferencesManager.getIsAuthenticated(), true);
        expect(preferencesManager.getUserId(), 'user123');
        expect(preferencesManager.getUserEmail(), 'user@test.com');
        expect(preferencesManager.getUserRole(), 'admin');
      });

      test('should handle theme and language preferences together', () async {
        // Arrange
        when(
          () => mockPrefs.setBool(StorageKeys.isDarkMode, true),
        ).thenAnswer((_) async => true);
        when(
          () => mockPrefs.setString(StorageKeys.language, 'es'),
        ).thenAnswer((_) async => true);

        when(() => mockPrefs.getBool(StorageKeys.isDarkMode)).thenReturn(true);
        when(() => mockPrefs.getString(StorageKeys.language)).thenReturn('es');

        // Act
        await preferencesManager.setDarkMode(true);
        await preferencesManager.setLanguage('es');

        // Assert
        expect(preferencesManager.getDarkMode(), true);
        expect(preferencesManager.getLanguage(), 'es');
      });
    });
  });
}
