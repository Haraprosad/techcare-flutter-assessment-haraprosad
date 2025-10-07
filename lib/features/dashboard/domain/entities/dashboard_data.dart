import 'package:equatable/equatable.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'balance_summary.dart';
import 'spending_category.dart';

/// Aggregate entity containing all dashboard data
class DashboardData extends Equatable {
  final BalanceSummary balanceSummary;
  final List<SpendingCategory> spendingByCategory;
  final List<Transaction> recentTransactions;
  final int unreadNotifications;

  const DashboardData({
    required this.balanceSummary,
    required this.spendingByCategory,
    required this.recentTransactions,
    required this.unreadNotifications,
  });

  DashboardData copyWith({
    BalanceSummary? balanceSummary,
    List<SpendingCategory>? spendingByCategory,
    List<Transaction>? recentTransactions,
    int? unreadNotifications,
  }) {
    return DashboardData(
      balanceSummary: balanceSummary ?? this.balanceSummary,
      spendingByCategory: spendingByCategory ?? this.spendingByCategory,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
    );
  }

  @override
  List<Object?> get props => [
    balanceSummary,
    spendingByCategory,
    recentTransactions,
    unreadNotifications,
  ];
}
