import 'package:equatable/equatable.dart';

/// Entity representing the balance summary displayed on dashboard
class BalanceSummary extends Equatable {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double savingsRate;
  final bool isVisible;

  const BalanceSummary({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.savingsRate,
    this.isVisible = true,
  });

  double get netBalance => monthlyIncome - monthlyExpense;

  BalanceSummary copyWith({
    double? totalBalance,
    double? monthlyIncome,
    double? monthlyExpense,
    double? savingsRate,
    bool? isVisible,
  }) {
    return BalanceSummary(
      totalBalance: totalBalance ?? this.totalBalance,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      savingsRate: savingsRate ?? this.savingsRate,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  List<Object?> get props => [
    totalBalance,
    monthlyIncome,
    monthlyExpense,
    savingsRate,
    isVisible,
  ];
}
