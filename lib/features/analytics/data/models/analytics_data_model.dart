import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/analytics_data.dart';
import 'analytics_summary_model.dart';
import 'category_breakdown_model.dart';
import 'monthly_trend_model.dart';

part 'analytics_data_model.freezed.dart';
part 'analytics_data_model.g.dart';

@freezed
class AnalyticsDataModel with _$AnalyticsDataModel {
  const factory AnalyticsDataModel({
    required AnalyticsSummaryModel summary,
    required List<CategoryBreakdownModel> categoryBreakdown,
    required List<MonthlyTrendModel> monthlyTrend,
  }) = _AnalyticsDataModel;

  factory AnalyticsDataModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsDataModelFromJson(json);
}

extension AnalyticsDataModelX on AnalyticsDataModel {
  AnalyticsData toEntity() {
    return AnalyticsData(
      summary: summary.toEntity(),
      categoryBreakdown: categoryBreakdown.map((e) => e.toEntity()).toList(),
      monthlyTrend: monthlyTrend.map((e) => e.toEntity()).toList(),
    );
  }
}
