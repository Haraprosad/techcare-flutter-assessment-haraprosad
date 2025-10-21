import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:techcare_assessment_app/core/network/constants/error_messages_key.dart';
import 'package:techcare_assessment_app/core/network/constants/response_code.dart';
import 'package:techcare_assessment_app/core/network/enums/custom_error_type.dart';
import 'package:techcare_assessment_app/core/network/error_handling/models/custom_exception.dart';
import 'package:techcare_assessment_app/core/network/error_handling/network_error_handler.dart';
import 'package:techcare_assessment_app/core/network/services/localization_service/localization_service.dart';

/// Mock class for LocalizationService to simulate translation behavior in tests
class MockLocalizationService extends Mock implements LocalizationService {}

/// Unit tests for NetworkErrorHandler
void main() {
  group('NetworkErrorHandler', () {
    late NetworkErrorHandler handler;
    late MockLocalizationService mockLocalizationService;

    /// Setup runs before each test to ensure fresh instances
    /// This prevents test pollution and ensures test isolation
    setUp(() {
      mockLocalizationService = MockLocalizationService();
      handler = NetworkErrorHandler(mockLocalizationService);
    });

    group('DioException - Connection errors', () {
      test('should handle no internet connection error correctly', () {
        // Arrange: Setup mock translation and create error
        const expectedMessage =
            'No internet connection. Please check your settings.';
        when(
          () => mockLocalizationService.translate(ErrorMessagesKey.noInternet),
        ).thenReturn(expectedMessage);

        final error = DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          error: CustomErrorType.noInternet,
        );

        // Act: Process the error through the handler
        final result = handler.handleError(error);

        // Assert: Verify correct code, message, and method call
        expect(result.code, ResponseCode.NO_INTERNET);
        expect(result.translatedMessage, expectedMessage);
        expect(result.technicalMessage, 'No internet connection');
        verify(
          () => mockLocalizationService.translate(ErrorMessagesKey.noInternet),
        ).called(1);
      });

      test('should handle connection error with proper error code', () {
        // Arrange
        const expectedMessage = 'Connection error. Please try again.';
        when(
          () => mockLocalizationService.translate(
            ErrorMessagesKey.connectionError,
          ),
        ).thenReturn(expectedMessage);

        final error = DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          type: DioExceptionType.connectionError,
        );

        // Act
        final result = handler.handleError(error);

        // Assert
        expect(result.code, ResponseCode.CONNECTION_ERROR);
        expect(result.translatedMessage, expectedMessage);
        expect(result.technicalMessage, 'Connection error occurred');
      });

      test('should handle bad certificate error', () {
        // Arrange
        const expectedMessage = 'Security certificate error.';
        when(
          () => mockLocalizationService.translate(
            ErrorMessagesKey.badCertificate,
          ),
        ).thenReturn(expectedMessage);

        final error = DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          type: DioExceptionType.badCertificate,
        );

        // Act
        final result = handler.handleError(error);

        // Assert
        expect(result.code, ResponseCode.CONNECTION_ERROR);
        expect(result.translatedMessage, expectedMessage);
        expect(result.technicalMessage, 'Bad Certificate error occurred');
      });
    });

    group('DioException - Timeout errors', () {
      test('should handle connection timeout correctly', () {
        // Arrange
        const expectedMessage = 'Connection timed out. Please try again.';
        when(
          () => mockLocalizationService.translate(
            ErrorMessagesKey.connectionTimeout,
          ),
        ).thenReturn(expectedMessage);

        final error = DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          type: DioExceptionType.connectionTimeout,
        );

        // Act
        final result = handler.handleError(error);

        // Assert
        expect(result.code, ResponseCode.TIMEOUT);
        expect(result.translatedMessage, expectedMessage);
        expect(result.technicalMessage, 'Connection timed out');
        verify(
          () => mockLocalizationService.translate(
            ErrorMessagesKey.connectionTimeout,
          ),
        ).called(1);
      });

      test('should handle send timeout correctly', () {
        // Arrange
        const expectedMessage = 'Send timeout. Please try again.';
        when(
          () => mockLocalizationService.translate(ErrorMessagesKey.sendTimeout),
        ).thenReturn(expectedMessage);

        final error = DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          type: DioExceptionType.sendTimeout,
        );

        // Act
        final result = handler.handleError(error);

        // Assert
        expect(result.code, ResponseCode.TIMEOUT);
        expect(result.translatedMessage, expectedMessage);
        expect(result.technicalMessage, 'Send timed out');
      });

      test('should handle receive timeout correctly', () {
        // Arrange
        const expectedMessage = 'Server response timeout.';
        when(
          () => mockLocalizationService.translate(
            ErrorMessagesKey.receiveTimeout,
          ),
        ).thenReturn(expectedMessage);

        final error = DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          type: DioExceptionType.receiveTimeout,
        );

        // Act
        final result = handler.handleError(error);

        // Assert
        expect(result.code, ResponseCode.TIMEOUT);
        expect(result.translatedMessage, expectedMessage);
        expect(result.technicalMessage, 'Receive timed out');
      });
    });

    group('DioException - Request cancellation', () {
      test('should handle cancel exception correctly', () {
        // Arrange
        const expectedMessage = 'Request was cancelled.';
        when(
          () => mockLocalizationService.translate(ErrorMessagesKey.cancel),
        ).thenReturn(expectedMessage);

        final error = DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          type: DioExceptionType.cancel,
        );

        // Act
        final result = handler.handleError(error);

        // Assert
        expect(result.code, ResponseCode.CONNECTION_ERROR);
        expect(result.translatedMessage, expectedMessage);
        expect(result.technicalMessage, 'Cancel error occurred');
      });
    });

    group('DioException - HTTP status codes (badResponse)', () {
      test('should handle 400 Bad Request correctly', () {
        // Arrange
        const expectedMessage = 'Bad request. Please check your input.';
        when(
          () => mockLocalizationService.translate(ErrorMessagesKey.badRequest),
        ).thenReturn(expectedMessage);

        final error = DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/api/test'),
            statusCode: 400,
          ),
        );

        // Act
        final result = handler.handleError(error);

        // Assert
        expect(result.code, 400);
        expect(result.translatedMessage, expectedMessage);
      });

      test('should handle 401 Unauthorized correctly', () {
        // Arrange
        const expectedMessage = 'Unauthorized. Please login again.';
        when(
          () =>
              mockLocalizationService.translate(ErrorMessagesKey.unauthorized),
        ).thenReturn(expectedMessage);

        final error = DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/api/test'),
            statusCode: 401,
          ),
        );

        // Act
        final result = handler.handleError(error);

        // Assert
        expect(result.code, 401);
        expect(result.translatedMessage, expectedMessage);
      });

      test('should handle 403 Forbidden correctly', () {
        // Arrange
        const expectedMessage = 'Access forbidden. You do not have permission.';
        when(
          () => mockLocalizationService.translate(ErrorMessagesKey.forbidden),
        ).thenReturn(expectedMessage);

        final error = DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/api/test'),
            statusCode: 403,
          ),
        );

        // Act
        final result = handler.handleError(error);

        // Assert
        expect(result.code, 403);
        expect(result.translatedMessage, expectedMessage);
      });

      test('should handle 404 Not Found correctly', () {
        // Arrange
        const expectedMessage = 'The requested resource was not found.';
        when(
          () => mockLocalizationService.translate(ErrorMessagesKey.notFound),
        ).thenReturn(expectedMessage);

        final error = DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/api/test'),
            statusCode: 404,
          ),
        );

        // Act
        final result = handler.handleError(error);

        // Assert
        expect(result.code, 404);
        expect(result.translatedMessage, expectedMessage);
      });

      test('should handle 500 Internal Server Error correctly', () {
        // Arrange
        const expectedMessage =
            'Internal server error. Please try again later.';
        when(
          () => mockLocalizationService.translate(ErrorMessagesKey.serverError),
        ).thenReturn(expectedMessage);

        final error = DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/api/test'),
            statusCode: 500,
          ),
        );

        // Act
        final result = handler.handleError(error);

        // Assert
        expect(result.code, 500);
        expect(result.translatedMessage, expectedMessage);
      });

      test('should handle backend error response with error code', () {
        // Arrange: Backend sends structured error response
        const expectedMessage = 'Transaction amount must be positive';
        when(
          () =>
              mockLocalizationService.translate(ErrorMessagesKey.amountInvalid),
        ).thenReturn(expectedMessage);

        final error = DioException(
          requestOptions: RequestOptions(path: '/api/transactions'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/api/transactions'),
            statusCode: 400,
            data: {
              'success': false,
              'error': {
                'code': 'AMOUNT_INVALID',
                'message': 'Amount must be greater than zero',
                'field': 'amount',
              },
            },
          ),
        );

        // Act
        final result = handler.handleError(error);

        // Assert: Should use backend error code and include field info
        expect(result.code, 400);
        expect(result.translatedMessage, contains(expectedMessage));
        expect(result.translatedMessage, contains('Field: amount'));
        expect(result.errorCode, 'AMOUNT_INVALID');
        expect(result.field, 'amount');
      });

      test(
        'should fall back to backend message when translation not found',
        () {
          // Arrange: Backend sends error we don't have translation for
          const backendMessage = 'Custom business rule violation';
          const unknownCode = 'CUSTOM_ERROR_123';

          // Return the key itself to simulate missing translation
          when(
            () => mockLocalizationService.translate(any()),
          ).thenReturn(unknownCode.toLowerCase());

          final error = DioException(
            requestOptions: RequestOptions(path: '/api/test'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: '/api/test'),
              statusCode: 400,
              data: {
                'success': false,
                'error': {'code': unknownCode, 'message': backendMessage},
              },
            ),
          );

          // Act
          final result = handler.handleError(error);

          // Assert: Should use backend message when translation fails
          expect(result.code, 400);
          expect(result.translatedMessage, backendMessage);
          expect(result.errorCode, unknownCode);
        },
      );

      test('should handle response with string data instead of map', () {
        // Arrange: Backend sends plain string instead of structured JSON
        const serverMessage = 'Something went wrong';
        const expectedTranslation = 'Bad request';

        when(
          () => mockLocalizationService.translate(ErrorMessagesKey.badRequest),
        ).thenReturn(expectedTranslation);

        final error = DioException(
          requestOptions: RequestOptions(path: '/api/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/api/test'),
            statusCode: 400,
            data: serverMessage,
          ),
        );

        // Act
        final result = handler.handleError(error);

        // Assert: When backend sends string without error structure,
        // the translated message based on status code is used
        expect(result.code, 400);
        expect(result.translatedMessage, expectedTranslation);
        expect(result.errorData, {'message': serverMessage});
        expect(result.backendMessage, isNull); // No backend message extracted
      });
    });

    group('CustomException handling', () {
      test('should handle preCallError exception correctly', () {
        // Arrange
        const expectedMessage = 'Pre-call validation failed';
        when(
          () => mockLocalizationService.translate(ErrorMessagesKey.preCall),
        ).thenReturn(expectedMessage);

        final error = CustomException(
          type: CustomErrorType.preCallError,
          originalError: 'Invalid parameters',
        );

        // Act
        final result = handler.handleError(error);

        // Assert
        expect(result.code, ResponseCode.DEFAULT);
        expect(result.translatedMessage, expectedMessage);
        expect(result.technicalMessage, 'CustomErrorType.preCallError');
      });

      test('should handle parsingError exception correctly', () {
        // Arrange
        const expectedMessage = 'Failed to parse server response';
        when(
          () => mockLocalizationService.translate(ErrorMessagesKey.parsing),
        ).thenReturn(expectedMessage);

        final error = CustomException(
          type: CustomErrorType.parsingError,
          originalError: FormatException('Invalid JSON'),
        );

        // Act
        final result = handler.handleError(error);

        // Assert
        expect(result.code, ResponseCode.DEFAULT);
        expect(result.translatedMessage, expectedMessage);
        expect(result.technicalMessage, 'CustomErrorType.parsingError');
      });

      test('should handle noInternet custom exception', () {
        // Arrange
        const expectedMessage = 'No internet connection';
        when(
          () => mockLocalizationService.translate(any()),
        ).thenReturn(expectedMessage);

        final error = CustomException(type: CustomErrorType.noInternet);

        // Act
        final result = handler.handleError(error);

        // Assert
        expect(result.code, ResponseCode.DEFAULT);
        expect(result.translatedMessage, expectedMessage);
      });
    });

    group('Unknown error handling', () {
      test('should handle generic exception', () {
        // Arrange
        const expectedMessage =
            'An unknown error occurred. Please try again later.';
        when(
          () => mockLocalizationService.translate(ErrorMessagesKey.unknown),
        ).thenReturn(expectedMessage);

        final error = Exception('Something went wrong');

        // Act
        final result = handler.handleError(error);

        // Assert
        expect(result.code, ResponseCode.DEFAULT);
        expect(result.translatedMessage, expectedMessage);
        expect(
          result.technicalMessage,
          'Exception throwing has not been perfectly implemented',
        );
      });

      test('should include stack trace when provided', () {
        // Arrange
        const expectedMessage = 'Unknown error';
        when(
          () => mockLocalizationService.translate(any()),
        ).thenReturn(expectedMessage);

        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        // Act
        final result = handler.handleError(error, stackTrace);

        // Assert
        expect(result.stackTrace, isNotNull);
        expect(result.stackTrace, equals(stackTrace));
      });
    });
  });
}
