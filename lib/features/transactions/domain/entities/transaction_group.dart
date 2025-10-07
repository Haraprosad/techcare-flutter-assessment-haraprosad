import 'package:equatable/equatable.dart';
import 'transaction.dart';

/// Entity for grouping transactions by date (used for sticky headers)
class TransactionGroup extends Equatable {
  final String dateKey;
  final DateTime date;
  final List<Transaction> transactions;

  const TransactionGroup({
    required this.dateKey,
    required this.date,
    required this.transactions,
  });

  double get totalAmount =>
      transactions.fold(0.0, (sum, transaction) => sum + transaction.amount);

  int get transactionCount => transactions.length;

  @override
  List<Object?> get props => [dateKey, date, transactions];
}
