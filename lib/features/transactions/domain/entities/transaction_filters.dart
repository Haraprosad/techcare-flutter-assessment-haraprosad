import 'package:equatable/equatable.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';

/// Filter criteria for transactions
class TransactionFilters extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> categoryIds;
  final double? minAmount;
  final double? maxAmount;
  final TransactionType? type;
  final String searchQuery;

  const TransactionFilters({
    this.startDate,
    this.endDate,
    this.categoryIds = const [],
    this.minAmount,
    this.maxAmount,
    this.type,
    this.searchQuery = '',
  });

  /// Check if any filters are active
  bool get hasActiveFilters =>
      startDate != null ||
      endDate != null ||
      categoryIds.isNotEmpty ||
      minAmount != null ||
      maxAmount != null ||
      type != null ||
      searchQuery.isNotEmpty;

  /// Count active filters (excluding search)
  int get activeFilterCount {
    int count = 0;
    if (startDate != null && endDate != null) count++;
    if (categoryIds.isNotEmpty) count++;
    if (minAmount != null || maxAmount != null) count++;
    if (type != null) count++;
    return count;
  }

  /// Clear all filters
  TransactionFilters clearAll() => const TransactionFilters();

  TransactionFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryIds,
    double? minAmount,
    double? maxAmount,
    TransactionType? type,
    String? searchQuery,
  }) {
    return TransactionFilters(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryIds: categoryIds ?? this.categoryIds,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      type: type ?? this.type,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    categoryIds,
    minAmount,
    maxAmount,
    type,
    searchQuery,
  ];
}
