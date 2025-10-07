import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/network/error_handling/models/api_call_failure_model.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction_form_data.dart';
import 'package:techcare_assessment_app/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case for saving a transaction (create or update)
/// Handles form validation and delegates to appropriate repository method
@injectable
class SaveTransactionUseCase {
  final TransactionRepository _repository;

  SaveTransactionUseCase(this._repository);

  /// Save transaction from form data
  /// Returns ApiSuccess<Transaction> on success
  /// Returns ApiFailure on validation error or repository error
  Future<ApiResult<Transaction>> call(TransactionFormData formData) async {
    // Validate form data
    if (!formData.isValid) {
      return ApiFailure(
        ApiCallFailureModel(
          code: 400,
          translatedMessage: _getValidationErrorMessage(formData),
        ),
      );
    }

    // Convert to transaction entity
    final transaction = formData.toTransaction();

    // Determine if this is create or update
    final isUpdate = formData.id != null && formData.id!.isNotEmpty;

    if (isUpdate) {
      return _repository.updateTransaction(transaction);
    } else {
      return _repository.createTransaction(transaction);
    }
  }

  /// Get comprehensive validation error message
  String _getValidationErrorMessage(TransactionFormData formData) {
    final errors = <String>[];

    if (formData.amountError != null) errors.add(formData.amountError!);
    if (formData.titleError != null) errors.add(formData.titleError!);
    if (formData.categoryError != null) errors.add(formData.categoryError!);
    if (formData.descriptionError != null) {
      errors.add(formData.descriptionError!);
    }
    if (formData.dateError != null) errors.add(formData.dateError!);

    return errors.isEmpty
        ? 'Invalid form data'
        : 'Validation errors: ${errors.join(', ')}';
  }
}
