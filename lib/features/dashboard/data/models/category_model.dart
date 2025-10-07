import 'package:techcare_assessment_app/features/transactions/domain/entities/category.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_model.g.dart';
part 'category_model.freezed.dart';

@freezed
abstract class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    @JsonKey(name: '_id') required String id,
    @Default("") String name,
    @Default("") String icon,
    @Default("") String color,
    double? budget,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  const CategoryModel._();

  Category toEntity() =>
      Category(id: id, name: name, icon: icon, color: color, budget: budget);
}
