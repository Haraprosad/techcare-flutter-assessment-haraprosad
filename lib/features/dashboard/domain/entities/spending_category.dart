import 'package:equatable/equatable.dart';

/// Entity representing category-wise spending for pie chart
class SpendingCategory extends Equatable {
  final String categoryId;
  final String categoryName;
  final String icon;
  final String color;
  final double amount;
  final double percentage;
  final int transactionCount;

  const SpendingCategory({
    required this.categoryId,
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    icon,
    color,
    amount,
    percentage,
    transactionCount,
  ];
}
