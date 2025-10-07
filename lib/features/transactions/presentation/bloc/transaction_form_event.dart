part of 'transaction_form_bloc.dart';

/// Base event class for TransactionFormBloc
abstract class TransactionFormEvent extends Equatable {
  const TransactionFormEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize form with empty data (for create)
class InitializeFormEvent extends TransactionFormEvent {
  const InitializeFormEvent();
}

/// Initialize form with existing transaction (for edit)
class InitializeFormWithTransactionEvent extends TransactionFormEvent {
  final Transaction transaction;

  const InitializeFormWithTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Load categories for category selection
class LoadCategoriesEvent extends TransactionFormEvent {
  const LoadCategoriesEvent();
}

/// Update amount
class UpdateAmountEvent extends TransactionFormEvent {
  final double? amount;

  const UpdateAmountEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// Update transaction type
class UpdateTypeEvent extends TransactionFormEvent {
  final TransactionType type;

  const UpdateTypeEvent(this.type);

  @override
  List<Object?> get props => [type];
}

/// Update category
class UpdateCategoryEvent extends TransactionFormEvent {
  final Category category;

  const UpdateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

/// Update title
class UpdateTitleEvent extends TransactionFormEvent {
  final String title;

  const UpdateTitleEvent(this.title);

  @override
  List<Object?> get props => [title];
}

/// Update description
class UpdateDescriptionEvent extends TransactionFormEvent {
  final String? description;

  const UpdateDescriptionEvent(this.description);

  @override
  List<Object?> get props => [description];
}

/// Update date
class UpdateDateEvent extends TransactionFormEvent {
  final DateTime date;

  const UpdateDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

/// Update time
class UpdateTimeEvent extends TransactionFormEvent {
  final DateTime? time;

  const UpdateTimeEvent(this.time);

  @override
  List<Object?> get props => [time];
}

/// Validate all fields
class ValidateFormEvent extends TransactionFormEvent {
  const ValidateFormEvent();
}

/// Submit form
class SubmitFormEvent extends TransactionFormEvent {
  const SubmitFormEvent();
}

/// Reset form
class ResetFormEvent extends TransactionFormEvent {
  const ResetFormEvent();
}
