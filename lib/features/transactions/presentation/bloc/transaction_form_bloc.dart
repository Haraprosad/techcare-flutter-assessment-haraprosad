import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/logger/app_logger.dart';
import 'package:techcare_assessment_app/core/network/error_handling/models/api_call_failure_model.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/category.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction_form_data.dart';
import 'package:techcare_assessment_app/features/transactions/domain/usecases/get_categories_usecase.dart';
import 'package:techcare_assessment_app/features/transactions/domain/usecases/save_transaction_usecase.dart';

part 'transaction_form_event.dart';
part 'transaction_form_state.dart';

/// BLoC for managing transaction form state and operations
@injectable
class TransactionFormBloc
    extends Bloc<TransactionFormEvent, TransactionFormState> {
  final SaveTransactionUseCase _saveTransactionUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;

  TransactionFormBloc(this._saveTransactionUseCase, this._getCategoriesUseCase)
    : super(TransactionFormState(formData: TransactionFormData.empty())) {
    on<InitializeFormEvent>(_onInitializeForm);
    on<InitializeFormWithTransactionEvent>(_onInitializeFormWithTransaction);
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<UpdateAmountEvent>(_onUpdateAmount);
    on<UpdateTypeEvent>(_onUpdateType);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<UpdateTitleEvent>(_onUpdateTitle);
    on<UpdateDescriptionEvent>(_onUpdateDescription);
    on<UpdateDateEvent>(_onUpdateDate);
    on<UpdateTimeEvent>(_onUpdateTime);
    on<ValidateFormEvent>(_onValidateForm);
    on<SubmitFormEvent>(_onSubmitForm);
    on<ResetFormEvent>(_onResetForm);
  }

  /// Initialize form with empty data
  Future<void> _onInitializeForm(
    InitializeFormEvent event,
    Emitter<TransactionFormState> emit,
  ) async {
    AppLogger.d(message: '📝 Initializing form');
    emit(
      state.copyWith(
        formData: TransactionFormData.empty(),
        validationErrors: {},
        clearSavedTransaction: true,
        clearFailure: true,
      ),
    );

    // Load categories
    add(const LoadCategoriesEvent());
  }

  /// Initialize form with existing transaction
  Future<void> _onInitializeFormWithTransaction(
    InitializeFormWithTransactionEvent event,
    Emitter<TransactionFormState> emit,
  ) async {
    AppLogger.d(
      message: '📝 Initializing form with transaction: ${event.transaction.id}',
    );
    emit(
      state.copyWith(
        formData: TransactionFormData.fromTransaction(event.transaction),
        validationErrors: {},
        clearSavedTransaction: true,
        clearFailure: true,
      ),
    );

    // Load categories
    add(const LoadCategoriesEvent());
  }

  /// Load available categories
  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<TransactionFormState> emit,
  ) async {
    AppLogger.d(message: '📦 Loading categories');

    emit(state.copyWith(categoriesLoading: true));

    final result = await _getCategoriesUseCase();

    switch (result) {
      case ApiSuccess(:final data):
        AppLogger.i(message: '✅ Categories loaded: ${data.length}');
        emit(state.copyWith(categories: data, categoriesLoading: false));
      case ApiFailure(:final failure):
        AppLogger.e(
          message: '❌ Failed to load categories: ${failure.translatedMessage}',
        );
        emit(state.copyWith(categoriesLoading: false, failure: failure));
    }
  }

  /// Update amount
  Future<void> _onUpdateAmount(
    UpdateAmountEvent event,
    Emitter<TransactionFormState> emit,
  ) async {
    final updatedFormData = state.formData.copyWith(amount: event.amount);
    emit(
      state.copyWith(
        formData: updatedFormData,
        isFormValid: updatedFormData.isValid,
      ),
    );

    // Validate amount field
    _validateField(emit, 'amount', updatedFormData.amountError);
  }

  /// Update transaction type
  Future<void> _onUpdateType(
    UpdateTypeEvent event,
    Emitter<TransactionFormState> emit,
  ) async {
    final updatedFormData = state.formData.copyWith(
      type: event.type,
      // Clear category when switching type
      category: null,
    );
    emit(
      state.copyWith(
        formData: updatedFormData,
        isFormValid: updatedFormData.isValid,
      ),
    );
  }

  /// Update category
  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<TransactionFormState> emit,
  ) async {
    final updatedFormData = state.formData.copyWith(category: event.category);
    emit(
      state.copyWith(
        formData: updatedFormData,
        isFormValid: updatedFormData.isValid,
      ),
    );

    // Validate category field
    _validateField(emit, 'category', updatedFormData.categoryError);
  }

  /// Update title
  Future<void> _onUpdateTitle(
    UpdateTitleEvent event,
    Emitter<TransactionFormState> emit,
  ) async {
    final updatedFormData = state.formData.copyWith(title: event.title);
    emit(
      state.copyWith(
        formData: updatedFormData,
        isFormValid: updatedFormData.isValid,
      ),
    );

    // Validate title field
    _validateField(emit, 'title', updatedFormData.titleError);
  }

  /// Update description
  Future<void> _onUpdateDescription(
    UpdateDescriptionEvent event,
    Emitter<TransactionFormState> emit,
  ) async {
    final updatedFormData = state.formData.copyWith(
      description: event.description,
    );
    emit(
      state.copyWith(
        formData: updatedFormData,
        isFormValid: updatedFormData.isValid,
      ),
    );

    // Validate description field
    _validateField(emit, 'description', updatedFormData.descriptionError);
  }

  /// Update date
  Future<void> _onUpdateDate(
    UpdateDateEvent event,
    Emitter<TransactionFormState> emit,
  ) async {
    final updatedFormData = state.formData.copyWith(date: event.date);
    emit(
      state.copyWith(
        formData: updatedFormData,
        isFormValid: updatedFormData.isValid,
      ),
    );

    // Validate date field
    _validateField(emit, 'date', updatedFormData.dateError);
  }

  /// Update time
  Future<void> _onUpdateTime(
    UpdateTimeEvent event,
    Emitter<TransactionFormState> emit,
  ) async {
    final updatedFormData = state.formData.copyWith(time: event.time);
    emit(
      state.copyWith(
        formData: updatedFormData,
        isFormValid: updatedFormData.isValid,
      ),
    );
  }

  /// Validate all form fields
  Future<void> _onValidateForm(
    ValidateFormEvent event,
    Emitter<TransactionFormState> emit,
  ) async {
    final errors = <String, String?>{};
    final formData = state.formData;

    // Collect all validation errors
    if (formData.amountError != null) {
      errors['amount'] = formData.amountError;
    }
    if (formData.titleError != null) {
      errors['title'] = formData.titleError;
    }
    if (formData.categoryError != null) {
      errors['category'] = formData.categoryError;
    }
    if (formData.descriptionError != null) {
      errors['description'] = formData.descriptionError;
    }
    if (formData.dateError != null) {
      errors['date'] = formData.dateError;
    }

    emit(state.copyWith(validationErrors: errors, isFormValid: errors.isEmpty));
  }

  /// Submit form
  Future<void> _onSubmitForm(
    SubmitFormEvent event,
    Emitter<TransactionFormState> emit,
  ) async {
    AppLogger.d(message: '📤 Submitting form');

    // Validate first
    add(const ValidateFormEvent());

    // Wait for validation to complete
    await Future.delayed(const Duration(milliseconds: 50));

    if (!state.isFormValid) {
      AppLogger.w(message: '⚠️ Form validation failed');
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearFailure: true));

    final result = await _saveTransactionUseCase(state.formData);

    switch (result) {
      case ApiSuccess(:final data):
        AppLogger.i(message: '✅ Transaction saved successfully');
        emit(state.copyWith(isSubmitting: false, savedTransaction: data));
      case ApiFailure(:final failure):
        AppLogger.e(
          message: '❌ Failed to save transaction: ${failure.translatedMessage}',
        );
        emit(state.copyWith(isSubmitting: false, failure: failure));
    }
  }

  /// Reset form to initial state
  Future<void> _onResetForm(
    ResetFormEvent event,
    Emitter<TransactionFormState> emit,
  ) async {
    AppLogger.d(message: '🔄 Resetting form');
    emit(
      TransactionFormState(
        formData: TransactionFormData.empty(),
        categories: state.categories, // Keep loaded categories
      ),
    );
  }

  /// Helper method to validate a single field
  void _validateField(
    Emitter<TransactionFormState> emit,
    String fieldName,
    String? error,
  ) {
    final updatedErrors = Map<String, String?>.from(state.validationErrors);

    if (error != null) {
      updatedErrors[fieldName] = error;
    } else {
      updatedErrors.remove(fieldName);
    }

    emit(state.copyWith(validationErrors: updatedErrors));
  }
}
