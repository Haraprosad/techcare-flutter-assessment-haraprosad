import 'package:dio/dio.dart';
import 'package:techcare_assessment_app/core/network/constants/response_code.dart';
import 'package:techcare_assessment_app/core/network/enums/custom_error_type.dart';
import 'package:techcare_assessment_app/core/network/constants/error_messages_key.dart';
import 'package:techcare_assessment_app/core/network/error_handling/models/custom_exception.dart';
import 'package:techcare_assessment_app/core/network/services/localization_service/localization_service.dart';
import 'package:techcare_assessment_app/core/network/error_handling/models/api_call_failure_model.dart';
import 'package:injectable/injectable.dart';

/// Class that handles network errors and provides localized error messages.
@lazySingleton
class NetworkErrorHandler {
  final LocalizationService _localizationService;

  NetworkErrorHandler(this._localizationService);

  /// Main method to handle errors, including Dio exceptions.
  ApiCallFailureModel handleError(dynamic error, [StackTrace? stackTrace]) {
    if (error is DioException) {
      if (error.error == CustomErrorType.noInternet) {
        return ApiCallFailureModel(
          code: ResponseCode.NO_INTERNET,
          translatedMessage: _localizationService.translate(
            ErrorMessagesKey.noInternet,
          ),
          technicalMessage: 'No internet connection',
          stackTrace: stackTrace,
        );
      }
      return _handleDioError(error, stackTrace);
    } else {
      if (error is CustomException) {
        return _handleCustomException(error, stackTrace);
      }
      return ApiCallFailureModel(
        code: ResponseCode.DEFAULT,
        translatedMessage: _localizationService.translate(
          ErrorMessagesKey.unknown,
        ),
        technicalMessage:
            'Exception throwing has not been perfectly implemented',
        stackTrace: stackTrace,
      );
    }
  }

  /// Handles specific network error types.
  ApiCallFailureModel _handleDioError(
    DioException error, [
    StackTrace? stackTrace,
  ]) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiCallFailureModel(
          code: ResponseCode.TIMEOUT,
          translatedMessage: _localizationService.translate(
            ErrorMessagesKey.connectionTimeout,
          ),
          technicalMessage: 'Connection timed out',
          stackTrace: stackTrace,
        );
      case DioExceptionType.sendTimeout:
        return ApiCallFailureModel(
          code: ResponseCode.TIMEOUT,
          translatedMessage: _localizationService.translate(
            ErrorMessagesKey.sendTimeout,
          ),
          technicalMessage: 'Send timed out',
          stackTrace: stackTrace,
        );
      case DioExceptionType.receiveTimeout:
        return ApiCallFailureModel(
          code: ResponseCode.TIMEOUT,
          translatedMessage: _localizationService.translate(
            ErrorMessagesKey.receiveTimeout,
          ),
          technicalMessage: 'Receive timed out',
          stackTrace: stackTrace,
        );
      case DioExceptionType.connectionError:
        return ApiCallFailureModel(
          code: ResponseCode.CONNECTION_ERROR,
          translatedMessage: _localizationService.translate(
            ErrorMessagesKey.connectionError,
          ),
          technicalMessage: 'Connection error occurred',
          stackTrace: stackTrace,
        );
      case DioExceptionType.badCertificate:
        return ApiCallFailureModel(
          code: ResponseCode.CONNECTION_ERROR,
          translatedMessage: _localizationService.translate(
            ErrorMessagesKey.badCertificate,
          ),
          technicalMessage: 'Bad Certificate error occurred',
          stackTrace: stackTrace,
        );
      case DioExceptionType.cancel:
        return ApiCallFailureModel(
          code: ResponseCode.CONNECTION_ERROR,
          translatedMessage: _localizationService.translate(
            ErrorMessagesKey.cancel,
          ),
          technicalMessage: 'Cancel error occurred',
          stackTrace: stackTrace,
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(error, stackTrace);
      default:
        return ApiCallFailureModel(
          code: ResponseCode.DEFAULT,
          translatedMessage: _localizationService.translate(
            ErrorMessagesKey.unknown,
          ),
          technicalMessage: 'Unknown error occurred',
          stackTrace: stackTrace,
        );
    }
  }

  /// Handles HTTP status code errors.
  /// Supports new API error format:
  /// {
  ///   "success": false,
  ///   "error": {
  ///     "code": "VALIDATION_ERROR",
  ///     "message": "Transaction amount must be greater than zero",
  ///     "field": "amount"
  ///   }
  /// }
  ApiCallFailureModel _handleBadResponse(
    DioException error, [
    StackTrace? stackTrace,
  ]) {
    final statusCode = error.response?.statusCode ?? ResponseCode.DEFAULT;

    // Safely convert response data to Map<String, dynamic>
    Map<String, dynamic>? errorData;
    final responseData = error.response?.data;
    if (responseData != null) {
      if (responseData is Map<String, dynamic>) {
        errorData = responseData;
      } else if (responseData is String) {
        errorData = {'message': responseData};
      } else {
        errorData = {'data': responseData.toString()};
      }
    }

    // Extract error details from new API format
    String? backendErrorCode;
    String? backendMessage;
    String? errorField;

    if (errorData != null && errorData['error'] != null) {
      final errorObject = errorData['error'] as Map<String, dynamic>;
      backendErrorCode = errorObject['code'] as String?;
      backendMessage = errorObject['message'] as String?;
      errorField = errorObject['field'] as String?;
    }

    // Determine message key based on backend error code or HTTP status
    String messageKey;
    String translatedMessage;

    if (backendErrorCode != null) {
      // Try to map backend error code to localized message
      messageKey = _getMessageKeyFromErrorCode(backendErrorCode);
      translatedMessage = _localizationService.translate(messageKey);

      // If translation returns the same key (not found), use backend message
      if (translatedMessage == messageKey && backendMessage != null) {
        translatedMessage = backendMessage;
      }

      // Append field name if available for better context
      if (errorField != null && errorField.isNotEmpty) {
        translatedMessage = '$translatedMessage (Field: $errorField)';
      }
    } else {
      // Fallback to HTTP status code mapping
      messageKey = _getMessageKeyFromStatusCode(statusCode);
      translatedMessage = _localizationService.translate(messageKey);

      // Use backend message as fallback if available
      if (backendMessage != null) {
        translatedMessage = backendMessage;
      }
    }

    return ApiCallFailureModel(
      code: statusCode,
      translatedMessage: translatedMessage,
      technicalMessage: error.message,
      stackTrace: stackTrace,
      errorData: errorData,
      errorCode: backendErrorCode,
      field: errorField,
      backendMessage: backendMessage,
    );
  }

  /// Maps backend error code to localized message key
  String _getMessageKeyFromErrorCode(String errorCode) {
    switch (errorCode.toUpperCase()) {
      case 'VALIDATION_ERROR':
        return ErrorMessagesKey.validationError;
      case 'AMOUNT_INVALID':
      case 'INVALID_AMOUNT':
        return ErrorMessagesKey.amountInvalid;
      case 'DUPLICATE_ENTRY':
      case 'ALREADY_EXISTS':
        return ErrorMessagesKey.duplicateEntry;
      case 'RESOURCE_NOT_FOUND':
      case 'NOT_FOUND':
        return ErrorMessagesKey.resourceNotFound;
      case 'INSUFFICIENT_BALANCE':
        return ErrorMessagesKey.insufficientBalance;
      case 'INVALID_DATE_RANGE':
        return ErrorMessagesKey.invalidDateRange;
      case 'CATEGORY_NOT_FOUND':
        return ErrorMessagesKey.categoryNotFound;
      case 'TRANSACTION_NOT_FOUND':
        return ErrorMessagesKey.transactionNotFound;
      default:
        return errorCode
            .toLowerCase(); // Return as-is, will use backend message
    }
  }

  /// Maps HTTP status code to message key (fallback)
  String _getMessageKeyFromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return ErrorMessagesKey.badRequest;
      case 401:
        return ErrorMessagesKey.unauthorized;
      case 403:
        return ErrorMessagesKey.forbidden;
      case 404:
        return ErrorMessagesKey.notFound;
      case 500:
        return ErrorMessagesKey.serverError;
      default:
        return ErrorMessagesKey.unknown;
    }
  }

  ApiCallFailureModel _handleCustomException(
    CustomException error, [
    StackTrace? stackTrace,
  ]) {
    final customErrorType = error.type;
    String messageKey;

    switch (customErrorType) {
      case CustomErrorType.preCallError:
        messageKey = ErrorMessagesKey.preCall;
        break;
      case CustomErrorType.parsingError:
        messageKey = ErrorMessagesKey.parsing;
        break;
      default:
        messageKey = ErrorMessagesKey.unknown;
    }

    return ApiCallFailureModel(
      code: ResponseCode.DEFAULT,
      translatedMessage: _localizationService.translate(messageKey),
      technicalMessage: error.type.toString(),
      stackTrace: stackTrace,
      errorData: {},
    );
  }
}
