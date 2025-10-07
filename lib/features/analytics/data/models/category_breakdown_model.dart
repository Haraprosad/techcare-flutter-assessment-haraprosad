import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../dashboard/data/models/category_model.dart';
import '../../domain/entities/category_breakdown.dart';

part 'category_breakdown_model.freezed.dart';
part 'category_breakdown_model.g.dart';

@freezed
class CategoryBreakdownModel with _$CategoryBreakdownModel {
  const factory CategoryBreakdownModel({
    required CategoryModel category,
    required double amount,
    required double percentage,
    required int transactionCount,
    double? budget,
    double? budgetUtilization,
  }) = _CategoryBreakdownModel;

  factory CategoryBreakdownModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryBreakdownModelFromJson(json);
}

extension CategoryBreakdownModelX on CategoryBreakdownModel {
  CategoryBreakdown toEntity() {
    return CategoryBreakdown(
      categoryId: category.id,
      categoryName: category.name,
      categoryIcon: category.icon,
      categoryColor: category.color,
      amount: amount,
      percentage: percentage,
      transactionCount: transactionCount,
      budget: budget,
      budgetUtilization: budgetUtilization,
    );
  }
}
