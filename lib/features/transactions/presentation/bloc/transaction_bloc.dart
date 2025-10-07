import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:techcare_assessment_app/core/logger/app_logger.dart';
import 'package:techcare_assessment_app/core/network/bloc/base_bloc.dart';
import 'package:techcare_assessment_app/core/network/bloc/base_bloc_state.dart';
import 'package:techcare_assessment_app/core/network/error_handling/models/api_call_failure_model.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/paginated_transactions.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction_filters.dart';
import 'package:techcare_assessment_app/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:techcare_assessment_app/features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'package:techcare_assessment_app/features/transactions/domain/usecases/get_transaction_by_id_usecase.dart';
import 'package:techcare_assessment_app/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:techcare_assessment_app/features/transactions/domain/usecases/refresh_transactions_usecase.dart';
import 'package:techcare_assessment_app/features/transactions/domain/usecases/update_transaction_usecase.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

/// Manages the transactions list screen - viewing, filtering, and managing transactions.
///
/// Handles:
/// - Paginated transaction loading (20 per page, infinite scroll)
/// - Search with 300ms debounce (doesn't hammer the API while typing)
/// - Filtering by date, category, amount, type
/// - Create/update/delete transactions with optimistic updates
/// - Pull-to-refresh
/// - Works offline with cached data
@lazySingleton
class TransactionBloc extends BaseBloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase _getTransactionsUseCase;
  final GetTransactionByIdUseCase _getTransactionByIdUseCase;
  final CreateTransactionUseCase _createTransactionUseCase;
  final UpdateTransactionUseCase _updateTransactionUseCase;
  final DeleteTransactionUseCase _deleteTransactionUseCase;
  final RefreshTransactionsUseCase _refreshTransactionsUseCase;

  TransactionBloc(
    this._getTransactionsUseCase,
    this._getTransactionByIdUseCase,
    this._createTransactionUseCase,
    this._updateTransactionUseCase,
    this._deleteTransactionUseCase,
    this._refreshTransactionsUseCase,
  ) : super(const TransactionState()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<LoadMoreTransactionsEvent>(_onLoadMoreTransactions);
    on<RefreshTransactionsEvent>(_onRefreshTransactions);
    on<SearchTransactionsEvent>(
      _onSearchTransactions,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<ClearFiltersEvent>(_onClearFilters);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<LoadTransactionByIdEvent>(_onLoadTransactionById);
    on<ClearErrorEvent>(_onClearError);
  }

  /// Debounces search events so we don't spam the API
  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounce(duration).switchMap(mapper);
  }

  /// Loads a page of transactions, applying any active filters
  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    AppLogger.i(message: 'Loading transactions (page: ${event.page})...');

    // If there's a search query, add it to the filters
    final filters = state.searchQuery.isNotEmpty
        ? (event.filters ?? state.filters).copyWith(
            searchQuery: state.searchQuery,
          )
        : (event.filters ?? state.filters);

    await handleApiCall(
      apiCall: () => _getTransactionsUseCase.call(
        page: event.page,
        pageSize: event.pageSize,
        filters: filters,
      ),
      onSuccess: (PaginatedTransactions data) {
        AppLogger.i(
          message:
              'Transactions loaded successfully (${data.transactions.length} items)',
        );

        emit(
          state.copyWith(
            transactions: data.transactions,
            currentPage: data.page,
            pageSize: data.pageSize,
            totalTransactions: data.total,
            hasMore: data.hasMore,
            filters: filters,
            isLoading: false,
            failure: null,
            clearFailure: true,
          ),
        );
      },
      onError: (failure) {
        AppLogger.e(
          message: 'Failed to load transactions: ${failure.translatedMessage}',
        );
      },
      emit: emit,
      showLoader: true,
    );
  }

  /// Loads the next page of transactions for infinite scrolling
  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    // Don't load if there's nothing more or already loading
    if (!state.hasMore || state.isLoadingMore || state.isLoading) {
      AppLogger.d(
        message:
            'Skipping load more (hasMore: ${state.hasMore}, isLoadingMore: ${state.isLoadingMore})',
      );
      return;
    }

    AppLogger.i(
      message: 'Loading more transactions (page: ${state.currentPage + 1})...',
    );

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final filters = state.searchQuery.isNotEmpty
        ? state.filters.copyWith(searchQuery: state.searchQuery)
        : state.filters;

    await handleApiCall(
      apiCall: () => _getTransactionsUseCase.call(
        page: nextPage,
        pageSize: state.pageSize,
        filters: filters,
      ),
      onSuccess: (PaginatedTransactions data) {
        AppLogger.i(
          message:
              'More transactions loaded successfully (${data.transactions.length} items)',
        );

        emit(
          state.copyWith(
            transactions: [...state.transactions, ...data.transactions],
            currentPage: data.page,
            totalTransactions: data.total,
            hasMore: data.hasMore,
            isLoadingMore: false,
          ),
        );
      },
      onError: (failure) {
        AppLogger.e(
          message:
              'Failed to load more transactions: ${failure.translatedMessage}',
        );
        emit(state.copyWith(isLoadingMore: false));
      },
      emit: emit,
      showLoader: false,
    );
  }

  /// Refreshes the transaction list from the network (pull-to-refresh action)
  Future<void> _onRefreshTransactions(
    RefreshTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    AppLogger.i(message: 'Refreshing transactions...');

    final filters = state.searchQuery.isNotEmpty
        ? state.filters.copyWith(searchQuery: state.searchQuery)
        : state.filters;

    await handleApiCall(
      apiCall: () => _refreshTransactionsUseCase.call(
        page: 1,
        pageSize: state.pageSize,
        filters: filters,
      ),
      onSuccess: (PaginatedTransactions data) {
        AppLogger.i(message: 'Transactions refreshed successfully');

        emit(
          state.copyWith(
            transactions: data.transactions,
            currentPage: 1,
            totalTransactions: data.total,
            hasMore: data.hasMore,
            isLoading: false,
            failure: null,
            clearFailure: true,
          ),
        );
      },
      onError: (failure) {
        AppLogger.e(
          message:
              'Failed to refresh transactions: ${failure.translatedMessage}',
        );
      },
      emit: emit,
      showLoader: false,
    );
  }

  /// Searches transactions with a 300ms debounce to prevent excessive API calls
  Future<void> _onSearchTransactions(
    SearchTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    AppLogger.i(message: 'Searching transactions: "${event.query}"');

    emit(state.copyWith(searchQuery: event.query));

    // Reload from page 1 with the search query
    add(const LoadTransactionsEvent(page: 1));
  }

  /// Applies filters (date range, category, amount range, type) to the transaction list
  Future<void> _onApplyFilters(
    ApplyFiltersEvent event,
    Emitter<TransactionState> emit,
  ) async {
    AppLogger.i(
      message:
          'Applying filters (active: ${event.filters.activeFilterCount})...',
    );

    emit(state.copyWith(filters: event.filters));

    // Reload from page 1 with the new filters
    add(const LoadTransactionsEvent(page: 1));
  }

  /// Clears all active filters and search query
  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<TransactionState> emit,
  ) async {
    AppLogger.i(message: 'Clearing all filters...');

    emit(state.copyWith(filters: const TransactionFilters(), searchQuery: ''));

    // Reload from page 1 with no filters
    add(const LoadTransactionsEvent(page: 1));
  }

  /// Creates a new transaction and optimistically adds it to the list
  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    AppLogger.i(message: 'Creating new transaction...');

    emit(state.copyWith(isOperationInProgress: true));

    await handleApiCall(
      apiCall: () => _createTransactionUseCase.call(event.transaction),
      onSuccess: (Transaction transaction) {
        AppLogger.i(message: 'Transaction created successfully');

        emit(
          state.copyWith(
            isOperationInProgress: false,
            operationMessage: 'Transaction created successfully',
          ),
        );

        // Refresh the transaction list
        add(const RefreshTransactionsEvent());
      },
      onError: (failure) {
        AppLogger.e(
          message: 'Failed to create transaction: ${failure.translatedMessage}',
        );
        emit(
          state.copyWith(
            isOperationInProgress: false,
            operationMessage: null,
            clearOperationMessage: true,
          ),
        );
      },
      emit: emit,
      showLoader: false,
    );
  }

  /// Updates an existing transaction and refreshes the list
  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    AppLogger.i(message: 'Updating transaction: ${event.transaction.id}');

    emit(state.copyWith(isOperationInProgress: true));

    await handleApiCall(
      apiCall: () => _updateTransactionUseCase.call(event.transaction),
      onSuccess: (Transaction transaction) {
        AppLogger.i(message: 'Transaction updated successfully');

        emit(
          state.copyWith(
            isOperationInProgress: false,
            operationMessage: 'Transaction updated successfully',
          ),
        );

        // Refresh to get the updated data
        add(const RefreshTransactionsEvent());
      },
      onError: (failure) {
        AppLogger.e(
          message: 'Failed to update transaction: ${failure.translatedMessage}',
        );
        emit(
          state.copyWith(
            isOperationInProgress: false,
            operationMessage: null,
            clearOperationMessage: true,
          ),
        );
      },
      emit: emit,
      showLoader: false,
    );
  }

  /// Deletes a transaction (with confirmation from the UI)
  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    AppLogger.i(message: 'Deleting transaction: ${event.id}');

    emit(state.copyWith(isOperationInProgress: true));

    await handleApiCall(
      apiCall: () => _deleteTransactionUseCase.call(event.id),
      onSuccess: (_) {
        AppLogger.i(message: 'Transaction deleted successfully');

        emit(
          state.copyWith(
            isOperationInProgress: false,
            operationMessage: 'Transaction deleted successfully',
          ),
        );

        // Refresh the transaction list
        add(const RefreshTransactionsEvent());
      },
      onError: (failure) {
        AppLogger.e(
          message: 'Failed to delete transaction: ${failure.translatedMessage}',
        );
        emit(
          state.copyWith(
            isOperationInProgress: false,
            operationMessage: null,
            clearOperationMessage: true,
          ),
        );
      },
      emit: emit,
      showLoader: false,
    );
  }

  /// Fetches a single transaction by ID (for viewing transaction details)
  Future<void> _onLoadTransactionById(
    LoadTransactionByIdEvent event,
    Emitter<TransactionState> emit,
  ) async {
    AppLogger.i(message: 'Loading transaction by ID: ${event.id}');

    await handleApiCall(
      apiCall: () => _getTransactionByIdUseCase.call(event.id),
      onSuccess: (Transaction transaction) {
        AppLogger.i(message: 'Transaction loaded successfully');

        emit(
          state.copyWith(selectedTransaction: transaction, isLoading: false),
        );
      },
      onError: (failure) {
        AppLogger.e(
          message: 'Failed to load transaction: ${failure.translatedMessage}',
        );
      },
      emit: emit,
      showLoader: true,
    );
  }

  /// Clears any error state so the UI can dismiss error messages
  void _onClearError(ClearErrorEvent event, Emitter<TransactionState> emit) {
    emit(state.copyWith(failure: null, clearFailure: true));
  }
}
