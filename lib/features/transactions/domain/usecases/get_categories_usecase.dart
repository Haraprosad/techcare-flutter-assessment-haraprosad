import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/category.dart';
import 'package:techcare_assessment_app/features/transactions/domain/repositories/transaction_repository.dart';

/// Fetches available transaction categories for use in forms and filters
@injectable
class GetCategoriesUseCase {
  final TransactionRepository _repository;

  GetCategoriesUseCase(this._repository);

  Future<ApiResult<List<Category>>> call() {
    return _repository.getCategories();
  }
}
