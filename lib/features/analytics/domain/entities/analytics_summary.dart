import 'package:equatable/equatable.dart';

class AnalyticsSummary extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final double savingsRate;
  final double? previousIncome;
  final double? previousExpense;

  const AnalyticsSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.savingsRate,
    this.previousIncome,
    this.previousExpense,
  });

  double get incomeChange {
    if (previousIncome == null || previousIncome == 0) return 0;
    return ((totalIncome - previousIncome!) / previousIncome!) * 100;
  }

  double get expenseChange {
    if (previousExpense == null || previousExpense == 0) return 0;
    return ((totalExpense - previousExpense!) / previousExpense!) * 100;
  }

  double get netBalanceChange {
    if (previousIncome == null || previousExpense == null) return 0;
    final previousNet = previousIncome! - previousExpense!;
    if (previousNet == 0) return 0;
    return ((netBalance - previousNet) / previousNet) * 100;
  }

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpense,
    netBalance,
    savingsRate,
    previousIncome,
    previousExpense,
  ];
}
