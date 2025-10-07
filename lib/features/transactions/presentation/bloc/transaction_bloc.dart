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

/// BLoC for managing Transaction screen state and business logic
///
/// Features:
/// - Load transactions with pagination (20 items per page)
/// - Search transactions with 300ms debouncing
/// - Filter transactions by date, category, amount, and type
/// - Infinite scroll support
/// - Pull-to-refresh functionality
/// - Create, update, and delete transactions
/// - Optimistic UI updates
/// - Cache support with offline fallback
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

  /// Debounce transformer for search
  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounce(duration).switchMap(mapper);
  }

  /// Load transactions (initial load or with new filters)
  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    AppLogger.i(message: 'Loading transactions (page: ${event.page})...');

    // Merge search query into filters if present
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

  /// Load more transactions (pagination)
  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
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

  /// Refresh transactions (pull-to-refresh)
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

  /// Search transactions with debouncing
  Future<void> _onSearchTransactions(
    SearchTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    AppLogger.i(message: 'Searching transactions: "${event.query}"');

    emit(state.copyWith(searchQuery: event.query));

    // Trigger new load with search query
    add(const LoadTransactionsEvent(page: 1));
  }

  /// Apply filters to transactions
  Future<void> _onApplyFilters(
    ApplyFiltersEvent event,
    Emitter<TransactionState> emit,
  ) async {
    AppLogger.i(
      message:
          'Applying filters (active: ${event.filters.activeFilterCount})...',
    );

    emit(state.copyWith(filters: event.filters));

    // Trigger new load with filters
    add(const LoadTransactionsEvent(page: 1));
  }

  /// Clear all filters
  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<TransactionState> emit,
  ) async {
    AppLogger.i(message: 'Clearing all filters...');

    emit(state.copyWith(filters: const TransactionFilters(), searchQuery: ''));

    // Trigger new load without filters
    add(const LoadTransactionsEvent(page: 1));
  }

  /// Add a new transaction
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

  /// Update an existing transaction
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

        // Refresh the transaction list
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

  /// Delete a transaction
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

  /// Load a single transaction by ID
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

  /// Clear error state
  void _onClearError(ClearErrorEvent event, Emitter<TransactionState> emit) {
    emit(state.copyWith(failure: null, clearFailure: true));
  }
}
