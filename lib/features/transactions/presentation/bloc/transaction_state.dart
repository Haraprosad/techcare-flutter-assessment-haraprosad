part of 'transaction_bloc.dart';

/// State class for TransactionBloc
class TransactionState extends BaseBlocState {
  // List of transactions
  final List<Transaction> transactions;

  // Pagination state
  final int currentPage;
  final int pageSize;
  final int totalTransactions;
  final bool hasMore;
  final bool isLoadingMore;

  // Filter and search state
  final TransactionFilters filters;
  final String searchQuery;

  // Single transaction (for details view)
  final Transaction? selectedTransaction;

  // Operation state
  final bool isOperationInProgress;
  final String? operationMessage;

  const TransactionState({
    this.transactions = const [],
    this.currentPage = 1,
    this.pageSize = 20,
    this.totalTransactions = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.filters = const TransactionFilters(),
    this.searchQuery = '',
    this.selectedTransaction,
    this.isOperationInProgress = false,
    this.operationMessage,
    super.isLoading,
    super.failure,
  });

  /// Check if we have any transactions
  bool get hasTransactions => transactions.isNotEmpty;

  /// Check if filters are active
  bool get hasActiveFilters =>
      filters.hasActiveFilters || searchQuery.isNotEmpty;

  /// Get active filter count
  int get activeFilterCount => filters.activeFilterCount;

  /// Group transactions by date
  Map<String, List<Transaction>> get groupedByDate {
    final Map<String, List<Transaction>> grouped = {};

    for (final transaction in transactions) {
      final dateKey = transaction.dateKey;
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  @override
  TransactionState copyWith({
    List<Transaction>? transactions,
    int? currentPage,
    int? pageSize,
    int? totalTransactions,
    bool? hasMore,
    bool? isLoadingMore,
    TransactionFilters? filters,
    String? searchQuery,
    Transaction? selectedTransaction,
    bool clearSelectedTransaction = false,
    bool? isOperationInProgress,
    String? operationMessage,
    bool clearOperationMessage = false,
    bool? isLoading,
    ApiCallFailureModel? failure,
    bool clearFailure = false,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filters: filters ?? this.filters,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTransaction: clearSelectedTransaction
          ? null
          : (selectedTransaction ?? this.selectedTransaction),
      isOperationInProgress:
          isOperationInProgress ?? this.isOperationInProgress,
      operationMessage: clearOperationMessage
          ? null
          : (operationMessage ?? this.operationMessage),
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    currentPage,
    pageSize,
    totalTransactions,
    hasMore,
    isLoadingMore,
    filters,
    searchQuery,
    selectedTransaction,
    isOperationInProgress,
    operationMessage,
    isLoading,
    failure,
  ];
}
