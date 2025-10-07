import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/analytics_summary.dart';

part 'analytics_summary_model.freezed.dart';
part 'analytics_summary_model.g.dart';

@freezed
class AnalyticsSummaryModel with _$AnalyticsSummaryModel {
  const factory AnalyticsSummaryModel({
    required double totalIncome,
    required double totalExpense,
    required double netBalance,
    required double savingsRate,
    double? previousIncome,
    double? previousExpense,
  }) = _AnalyticsSummaryModel;

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsSummaryModelFromJson(json);
}

extension AnalyticsSummaryModelX on AnalyticsSummaryModel {
  AnalyticsSummary toEntity() {
    return AnalyticsSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netBalance: netBalance,
      savingsRate: savingsRate,
      previousIncome: previousIncome,
      previousExpense: previousExpense,
    );
  }
}
