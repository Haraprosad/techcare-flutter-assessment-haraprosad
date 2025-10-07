import 'package:equatable/equatable.dart';
import 'analytics_summary.dart';
import 'category_breakdown.dart';
import 'monthly_trend.dart';

class AnalyticsData extends Equatable {
  final AnalyticsSummary summary;
  final List<CategoryBreakdown> categoryBreakdown;
  final List<MonthlyTrend> monthlyTrend;

  const AnalyticsData({
    required this.summary,
    required this.categoryBreakdown,
    required this.monthlyTrend,
  });

  @override
  List<Object?> get props => [summary, categoryBreakdown, monthlyTrend];
}
