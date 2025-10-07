import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:techcare_assessment_app/features/dashboard/data/models/transaction_model.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/paginated_transactions.dart';

part 'paginated_transactions_model.freezed.dart';
part 'paginated_transactions_model.g.dart';

/// Model for paginated transaction responses
@freezed
class PaginatedTransactionsModel with _$PaginatedTransactionsModel {
  const factory PaginatedTransactionsModel({
    @Default([]) List<TransactionModel> transactions,
    @Default(0) int total,
    @Default(1) int page,
    @Default(20) int pageSize,
    @Default(false) bool hasMore,
  }) = _PaginatedTransactionsModel;

  factory PaginatedTransactionsModel.fromJson(Map<String, dynamic> json) =>
      _$PaginatedTransactionsModelFromJson(json);

  const PaginatedTransactionsModel._();

  PaginatedTransactions toEntity() => PaginatedTransactions(
    transactions: transactions.map((t) => t.toEntity()).toList(),
    total: total,
    page: page,
    pageSize: pageSize,
    hasMore: hasMore,
  );
}
