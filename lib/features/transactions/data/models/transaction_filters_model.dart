import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction_filters.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';

part 'transaction_filters_model.freezed.dart';
part 'transaction_filters_model.g.dart';

/// Model for transaction filters
@freezed
class TransactionFiltersModel with _$TransactionFiltersModel {
  const factory TransactionFiltersModel({
    DateTime? startDate,
    DateTime? endDate,
    @Default([]) List<String> categoryIds,
    double? minAmount,
    double? maxAmount,
    TransactionType? type,
    @Default('') String searchQuery,
  }) = _TransactionFiltersModel;

  factory TransactionFiltersModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionFiltersModelFromJson(json);

  const TransactionFiltersModel._();

  TransactionFilters toEntity() => TransactionFilters(
    startDate: startDate,
    endDate: endDate,
    categoryIds: categoryIds,
    minAmount: minAmount,
    maxAmount: maxAmount,
    type: type,
    searchQuery: searchQuery,
  );
}
