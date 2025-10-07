import 'package:equatable/equatable.dart';

class MonthlyTrend extends Equatable {
  final String month;
  final double income;
  final double expense;

  const MonthlyTrend({
    required this.month,
    required this.income,
    required this.expense,
  });

  double get netAmount => income - expense;

  @override
  List<Object?> get props => [month, income, expense];
}
