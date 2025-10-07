import 'package:techcare_assessment_app/features/dashboard/domain/entities/balance_summary.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_summary_model.g.dart';
part 'balance_summary_model.freezed.dart';

@freezed
abstract class BalanceSummaryModel with _$BalanceSummaryModel {
  const factory BalanceSummaryModel({
    @Default(0.0) double totalBalance,
    @Default(0.0) double monthlyIncome,
    @Default(0.0) double monthlyExpense,
    @Default(0.0) double savingsRate,
    @Default(true) bool isVisible,
  }) = _BalanceSummaryModel;

  factory BalanceSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$BalanceSummaryModelFromJson(json);

  const BalanceSummaryModel._();

  BalanceSummary toEntity() => BalanceSummary(
    totalBalance: totalBalance,
    monthlyIncome: monthlyIncome,
    monthlyExpense: monthlyExpense,
    savingsRate: savingsRate,
    isVisible: isVisible,
  );
}
