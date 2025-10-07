import 'package:techcare_assessment_app/core/network/error_handling/network_error_handler.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';

/// Base class for all API repositories in the app.
///
/// Provides a safe wrapper for API calls that catches any errors and
/// converts them into our standard ApiResult format. Extend this class
/// in your repository implementations to get automatic error handling.
abstract class BaseApiRepository {
  final NetworkErrorHandler _errorHandler;

  BaseApiRepository(this._errorHandler);

  /// Wraps an API call with try-catch and converts the result to ApiResult.
  ///
  /// If the call succeeds, returns ApiSuccess with the data.
  /// If anything goes wrong, catches the error and returns ApiFailure
  /// with a user-friendly message.
  Future<ApiResult<T>> safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      final result = await apiCall();
      return ApiSuccess(result);
    } catch (error, stackTrace) {
      final failure = _errorHandler.handleError(error, stackTrace);
      return ApiFailure(failure);
    }
  }
}
