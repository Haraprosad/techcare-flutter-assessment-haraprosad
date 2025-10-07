import 'package:equatable/equatable.dart';

class CategoryBreakdown extends Equatable {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final double amount;
  final double percentage;
  final int transactionCount;
  final double? budget;
  final double? budgetUtilization;

  const CategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
    this.budget,
    this.budgetUtilization,
  });

  /// Determine budget status color based on utilization
  String get budgetStatusColor {
    if (budgetUtilization == null || budget == null) return '#4CAF50';
    if (budgetUtilization! <= 70) return '#4CAF50'; // Green
    if (budgetUtilization! <= 90) return '#FFC107'; // Yellow
    return '#F44336'; // Red
  }

  bool get isOverBudget =>
      budgetUtilization != null && budgetUtilization! > 100;

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    categoryIcon,
    categoryColor,
    amount,
    percentage,
    transactionCount,
    budget,
    budgetUtilization,
  ];
}
