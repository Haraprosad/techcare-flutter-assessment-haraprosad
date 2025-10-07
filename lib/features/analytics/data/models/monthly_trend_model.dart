import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/monthly_trend.dart';

part 'monthly_trend_model.freezed.dart';
part 'monthly_trend_model.g.dart';

@freezed
class MonthlyTrendModel with _$MonthlyTrendModel {
  const factory MonthlyTrendModel({
    required String month,
    required double income,
    required double expense,
  }) = _MonthlyTrendModel;

  factory MonthlyTrendModel.fromJson(Map<String, dynamic> json) =>
      _$MonthlyTrendModelFromJson(json);
}

extension MonthlyTrendModelX on MonthlyTrendModel {
  MonthlyTrend toEntity() {
    return MonthlyTrend(month: month, income: income, expense: expense);
  }
}
