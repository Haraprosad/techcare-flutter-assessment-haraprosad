import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/network/error_handling/models/api_call_failure_model.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction_form_data.dart';
import 'package:techcare_assessment_app/features/transactions/domain/repositories/transaction_repository.dart';

/// Saves a transaction - either creates a new one or updates an existing one
///
/// This use case handles form validation before saving. If validation fails,
/// it returns an ApiFailure without calling the repository.
@injectable
class SaveTransactionUseCase {
  final TransactionRepository _repository;

  SaveTransactionUseCase(this._repository);

  /// Validates the form data, then creates or updates the transaction
  Future<ApiResult<Transaction>> call(TransactionFormData formData) async {
    // Check if the form data is valid
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

    // If there's an ID, it's an update; otherwise it's a new transaction
    final isUpdate = formData.id != null && formData.id!.isNotEmpty;

    if (isUpdate) {
      return _repository.updateTransaction(transaction);
    } else {
      return _repository.createTransaction(transaction);
    }
  }

  /// Builds a user-friendly error message from all validation errors
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
