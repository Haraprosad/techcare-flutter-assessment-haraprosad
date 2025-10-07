part of 'transaction_bloc.dart';

/// Base event class for TransactionBloc
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Load transactions for a specific page
class LoadTransactionsEvent extends TransactionEvent {
  final int page;
  final int pageSize;
  final TransactionFilters? filters;

  const LoadTransactionsEvent({
    required this.page,
    this.pageSize = 20,
    this.filters,
  });

  @override
  List<Object?> get props => [page, pageSize, filters];
}

/// Load more transactions (pagination)
class LoadMoreTransactionsEvent extends TransactionEvent {
  const LoadMoreTransactionsEvent();
}

/// Refresh transactions (pull-to-refresh)
class RefreshTransactionsEvent extends TransactionEvent {
  const RefreshTransactionsEvent();
}

/// Search transactions
class SearchTransactionsEvent extends TransactionEvent {
  final String query;

  const SearchTransactionsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Apply filters to transactions
class ApplyFiltersEvent extends TransactionEvent {
  final TransactionFilters filters;

  const ApplyFiltersEvent(this.filters);

  @override
  List<Object?> get props => [filters];
}

/// Clear all filters
class ClearFiltersEvent extends TransactionEvent {
  const ClearFiltersEvent();
}

/// Add a new transaction
class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const AddTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Update an existing transaction
class UpdateTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Delete a transaction
class DeleteTransactionEvent extends TransactionEvent {
  final String id;

  const DeleteTransactionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Load transaction by ID
class LoadTransactionByIdEvent extends TransactionEvent {
  final String id;

  const LoadTransactionByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Clear error state
class ClearErrorEvent extends TransactionEvent {
  const ClearErrorEvent();
}
