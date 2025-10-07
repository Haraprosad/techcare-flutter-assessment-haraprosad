import 'package:techcare_assessment_app/features/dashboard/domain/entities/spending_category.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'spending_category_model.g.dart';
part 'spending_category_model.freezed.dart';

@freezed
abstract class SpendingCategoryModel with _$SpendingCategoryModel {
  const factory SpendingCategoryModel({
    required String categoryId,
    @Default("") String categoryName,
    @Default("") String icon,
    @Default("") String color,
    @Default(0.0) double amount,
    @Default(0.0) double percentage,
    @Default(0) int transactionCount,
  }) = _SpendingCategoryModel;

  factory SpendingCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$SpendingCategoryModelFromJson(json);

  const SpendingCategoryModel._();

  SpendingCategory toEntity() => SpendingCategory(
    categoryId: categoryId,
    categoryName: categoryName,
    icon: icon,
    color: color,
    amount: amount,
    percentage: percentage,
    transactionCount: transactionCount,
  );
}
