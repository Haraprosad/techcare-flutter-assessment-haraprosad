import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/dashboard/data/models/category_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.g.dart';
part 'transaction_model.freezed.dart';

@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    @JsonKey(name: '_id') required String id,
    @Default("") String title,
    @Default(0.0) double amount,
    @Default(TransactionType.expense) TransactionType type,
    required CategoryModel category,
    required DateTime date,
    String? description,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  const TransactionModel._();

  Transaction toEntity() => Transaction(
    id: id,
    title: title,
    amount: amount,
    type: type,
    category: category.toEntity(),
    date: date,
    description: description,
  );
}
