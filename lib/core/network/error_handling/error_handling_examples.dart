import 'package:dio/dio.dart';
import 'package:techcare_assessment_app/core/network/error_handling/network_error_handler.dart';
import 'package:techcare_assessment_app/core/network/services/localization_service/localization_service.dart';

/// Example demonstrating how the new error handling works
/// This shows how backend error responses are processed and displayed

void demonstrateErrorHandling() {
  // Simulated backend error response
  final Map<String, dynamic> backendErrorResponse = {
    "success": false,
    "error": {
      "code": "VALIDATION_ERROR",
      "message": "Transaction amount must be greater than zero",
      "field": "amount",
    },
  };

  // Simulate Dio throwing an exception with this response
  final dioException = DioException(
    requestOptions: RequestOptions(path: '/api/transactions'),
    response: Response(
      requestOptions: RequestOptions(path: '/api/transactions'),
      statusCode: 400,
      data: backendErrorResponse,
    ),
    type: DioExceptionType.badResponse,
  );

  // NetworkErrorHandler processes the error
  // final errorHandler = NetworkErrorHandler(localizationService);
  // final failure = errorHandler.handleError(dioException);

  // Result will be an ApiCallFailureModel:
  /*
  ApiCallFailureModel(
    code: 400,                                    // HTTP status code
    errorCode: "VALIDATION_ERROR",                // Backend error code
    field: "amount",                              // Field that caused error
    backendMessage: "Transaction amount must...", // Original backend message
    translatedMessage: "Validation error occurred (Field: amount)", // Localized for UI
  )
  */

  // In the UI (BLoC listener):
  /*
  BlocListener<TransactionFormBloc, TransactionFormState>(
    listener: (context, state) {
      if (state.failure != null) {
        // Show error to user
        SnackbarUtils.showError(
          context, 
          state.failure!.translatedMessage  // Shows: "Validation error occurred (Field: amount)"
        );
        
        // Optionally highlight the problematic field
        if (state.failure!.field != null) {
          _highlightField(state.failure!.field!);  // Highlights "amount" field
        }
        
        // Log technical details for debugging
        AppLogger.e(
          message: 'Transaction failed',
          error: state.failure!.errorCode,          // Logs: "VALIDATION_ERROR"
          metadata: {
            'field': state.failure!.field,          // "amount"
            'backendMessage': state.failure!.backendMessage,
          },
        );
      }
    },
  )
  */
}

/// Example with different error types

void exampleValidationError() {
  // Backend returns:
  final response = {
    "success": false,
    "error": {
      "code": "VALIDATION_ERROR",
      "message": "Amount must be greater than zero",
      "field": "amount",
    },
  };

  // User sees (English): "Validation error occurred (Field: amount)"
  // User sees (Bengali): "যাচাইকরণ ত্রুটি ঘটেছে (Field: amount)"
}

void exampleInsufficientBalance() {
  // Backend returns:
  final response = {
    "success": false,
    "error": {
      "code": "INSUFFICIENT_BALANCE",
      "message": "You don't have enough balance",
    },
  };

  // User sees (English): "Insufficient balance"
  // User sees (Bengali): "অপর্যাপ্ত ব্যালেন্স"
}

void exampleUnknownError() {
  // Backend returns new/unknown error code:
  final response = {
    "success": false,
    "error": {
      "code": "SOME_NEW_ERROR_FROM_BACKEND",
      "message": "This is a new error type we just added",
    },
  };

  // Flutter doesn't have translation for "SOME_NEW_ERROR_FROM_BACKEND"
  // So it falls back to backend message:
  // User sees: "This is a new error type we just added"

  // This way, backend can add new errors without breaking the app!
}

void exampleLegacyHttpError() {
  // If backend doesn't send structured error (old format):
  final response = "Server Error"; // Just a string

  // Falls back to HTTP status code mapping:
  // Status 500 → "Server error occurred" (localized)
}

/// How to test in your app

void howToTestInMockService() {
  /*
  In your mock_transaction_service.dart:
  
  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> data) async {
    final amount = data['amount'] as double?;
    
    // Simulate validation error
    if (amount == null || amount <= 0) {
      throw DioException(
        requestOptions: RequestOptions(path: '/transactions'),
        response: Response(
          requestOptions: RequestOptions(path: '/transactions'),
          statusCode: 400,
          data: {
            "success": false,
            "error": {
              "code": "VALIDATION_ERROR",
              "message": "Transaction amount must be greater than zero",
              "field": "amount"
            }
          },
        ),
        type: DioExceptionType.badResponse,
      );
    }
    
    // Simulate insufficient balance
    if (data['type'] == 'expense' && amount > 10000) {
      throw DioException(
        requestOptions: RequestOptions(path: '/transactions'),
        response: Response(
          requestOptions: RequestOptions(path: '/transactions'),
          statusCode: 400,
          data: {
            "success": false,
            "error": {
              "code": "INSUFFICIENT_BALANCE",
              "message": "You don't have enough balance for this transaction"
            }
          },
        ),
        type: DioExceptionType.badResponse,
      );
    }
    
    // Normal success case
    return {
      'id': 'txn_${DateTime.now().millisecondsSinceEpoch}',
      'amount': amount,
      ...data,
    };
  }
  */
}

/// Expected behavior in different languages

class ExpectedBehavior {
  static void englishLocale() {
    // When app language is English:

    // VALIDATION_ERROR → "Validation error occurred (Field: amount)"
    // AMOUNT_INVALID → "Invalid amount entered"
    // INSUFFICIENT_BALANCE → "Insufficient balance"
    // DUPLICATE_ENTRY → "This entry already exists"
    // Unknown error → Shows backend message as-is
  }

  static void bengaliLocale() {
    // When app language is Bengali:

    // VALIDATION_ERROR → "যাচাইকরণ ত্রুটি ঘটেছে (Field: amount)"
    // AMOUNT_INVALID → "অবৈধ পরিমাণ প্রবেশ করানো হয়েছে"
    // INSUFFICIENT_BALANCE → "অপর্যাপ্ত ব্যালেন্স"
    // DUPLICATE_ENTRY → "এই এন্ট্রি ইতিমধ্যে বিদ্যমান"
    // Unknown error → Shows backend message as-is
  }
}

/// Automatic Retry with Exponential Backoff

class RetryMechanism {
  static void howItWorks() {
    /*
    The app now includes automatic retry with exponential backoff for:
    
    ✅ RETRY ON:
    - Connection timeout
    - Send timeout  
    - Receive timeout
    - Connection errors
    - Temporary server errors (500, 502, 503, 504, 408)
    
    ❌ DO NOT RETRY:
    - Client errors (400, 401, 403, 404, etc.)
    - Successful responses (2xx)
    - Cancelled requests
    - No internet errors (handled by connectivity check)
    
    CONFIGURATION (in NetworkConstants):
    - maxRetries: 3 attempts
    - initialRetryDelay: 1 second
    - backoffMultiplier: 2.0
    
    RETRY PATTERN:
    - 1st retry: after 1 second
    - 2nd retry: after 2 seconds  
    - 3rd retry: after 4 seconds
    - Total: 3 retries over ~7 seconds
    
    The RetryInterceptor is automatically applied to all network requests
    through the DioClient. No additional code needed in repositories or BLoCs.
    */
  }

  static void testingRetry() {
    /*
    To test retry behavior in mock services:
    
    Future<Map<String, dynamic>> getTransactions() async {
      // Simulate temporary server error (will be retried)
      throw DioException(
        requestOptions: RequestOptions(path: '/transactions'),
        response: Response(
          requestOptions: RequestOptions(path: '/transactions'),
          statusCode: 503, // Service Unavailable - will retry
          data: {'error': 'Service temporarily unavailable'},
        ),
        type: DioExceptionType.badResponse,
      );
    }
    
    // The RetryInterceptor will automatically:
    // 1. Wait 1 second, retry
    // 2. Wait 2 seconds, retry
    // 3. Wait 4 seconds, retry
    // 4. If still failing, return error to user
    
    // For timeout testing:
    throw DioException(
      requestOptions: RequestOptions(path: '/transactions'),
      type: DioExceptionType.connectionTimeout, // Will retry
    );
    
    // For client errors (will NOT retry):
    throw DioException(
      requestOptions: RequestOptions(path: '/transactions'),
      response: Response(
        requestOptions: RequestOptions(path: '/transactions'),
        statusCode: 400, // Bad Request - no retry
        data: {'error': {'code': 'VALIDATION_ERROR', 'message': 'Invalid data'}},
      ),
      type: DioExceptionType.badResponse,
    );
    */
  }

  static void logsToExpect() {
    /*
    When retry happens, you'll see logs like:
    
    🔄 Retrying request (1/3) after 1s: /api/transactions
    ❌ Retry failed (attempt 1): /api/transactions
    🔄 Retrying request (2/3) after 2s: /api/transactions
    ❌ Retry failed (attempt 2): /api/transactions
    🔄 Retrying request (3/3) after 4s: /api/transactions
    ✅ Retry successful (attempt 3): /api/transactions
    
    OR if max retries reached:
    
    ⚠️ Max retries (3) reached for: /api/transactions
    ❌ Request will not be retried: /api/transactions
    */
  }
}
