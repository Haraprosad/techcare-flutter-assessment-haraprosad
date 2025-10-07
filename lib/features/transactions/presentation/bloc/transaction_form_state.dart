part of 'transaction_form_bloc.dart';

/// State class for TransactionFormBloc
class TransactionFormState extends Equatable {
  // Form data
  final TransactionFormData formData;

  // Available categories
  final List<Category> categories;
  final bool categoriesLoading;

  // Validation errors
  final Map<String, String?> validationErrors;

  // Form state
  final bool isSubmitting;
  final bool isFormValid;

  // Success state
  final Transaction? savedTransaction;

  // Loading and error state
  final bool isLoading;
  final ApiCallFailureModel? failure;

  const TransactionFormState({
    required this.formData,
    this.categories = const [],
    this.categoriesLoading = false,
    this.validationErrors = const {},
    this.isSubmitting = false,
    this.isFormValid = false,
    this.savedTransaction,
    this.isLoading = false,
    this.failure,
  });

  /// Check if this is an edit operation
  bool get isEditMode => formData.id != null && formData.id!.isNotEmpty;

  /// Get validation error for a specific field
  String? getFieldError(String fieldName) => validationErrors[fieldName];

  /// Check if a field has error
  bool hasFieldError(String fieldName) =>
      validationErrors.containsKey(fieldName) &&
      validationErrors[fieldName] != null;

  TransactionFormState copyWith({
    TransactionFormData? formData,
    List<Category>? categories,
    bool? categoriesLoading,
    Map<String, String?>? validationErrors,
    bool? isSubmitting,
    bool? isFormValid,
    Transaction? savedTransaction,
    bool clearSavedTransaction = false,
    bool? isLoading,
    ApiCallFailureModel? failure,
    bool clearFailure = false,
  }) {
    return TransactionFormState(
      formData: formData ?? this.formData,
      categories: categories ?? this.categories,
      categoriesLoading: categoriesLoading ?? this.categoriesLoading,
      validationErrors: validationErrors ?? this.validationErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isFormValid: isFormValid ?? this.isFormValid,
      savedTransaction: clearSavedTransaction
          ? null
          : (savedTransaction ?? this.savedTransaction),
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
        formData,
        categories,
        categoriesLoading,
        validationErrors,
        isSubmitting,
        isFormValid,
        savedTransaction,
        isLoading,
        failure,
      ];
}
