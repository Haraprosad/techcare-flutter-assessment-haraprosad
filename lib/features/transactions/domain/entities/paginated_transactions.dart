import 'package:equatable/equatable.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';

/// Paginated transaction response entity
class PaginatedTransactions extends Equatable {
  final List<Transaction> transactions;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PaginatedTransactions({
    required this.transactions,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  /// Get total number of pages
  int get totalPages => (total / pageSize).ceil();

  /// Check if this is the first page
  bool get isFirstPage => page == 1;

  /// Check if this is the last page
  bool get isLastPage => !hasMore;

  PaginatedTransactions copyWith({
    List<Transaction>? transactions,
    int? total,
    int? page,
    int? pageSize,
    bool? hasMore,
  }) {
    return PaginatedTransactions(
      transactions: transactions ?? this.transactions,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [transactions, total, page, pageSize, hasMore];
}
