import 'package:techcare_assessment_app/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:techcare_assessment_app/features/dashboard/data/models/balance_summary_model.dart';
import 'package:techcare_assessment_app/features/dashboard/data/models/spending_category_model.dart';
import 'package:techcare_assessment_app/features/dashboard/data/models/transaction_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_data_model.g.dart';
part 'dashboard_data_model.freezed.dart';

@freezed
abstract class DashboardDataModel with _$DashboardDataModel {
  const factory DashboardDataModel({
    required BalanceSummaryModel balanceSummary,
    @Default([]) List<SpendingCategoryModel> spendingByCategory,
    @Default([]) List<TransactionModel> recentTransactions,
    @Default(0) int unreadNotifications,
  }) = _DashboardDataModel;

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataModelFromJson(json);

  const DashboardDataModel._();

  DashboardData toEntity() => DashboardData(
    balanceSummary: balanceSummary.toEntity(),
    spendingByCategory: spendingByCategory.map((e) => e.toEntity()).toList(),
    recentTransactions: recentTransactions.map((e) => e.toEntity()).toList(),
    unreadNotifications: unreadNotifications,
  );
}
