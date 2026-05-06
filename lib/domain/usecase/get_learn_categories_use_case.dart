import 'package:flymap/domain/entity/learn_category.dart';
import 'package:flymap/repository/learn_repository.dart';

class GetLearnCategoriesUseCase {
  GetLearnCategoriesUseCase({required LearnRepository repository})
    : _repository = repository;

  final LearnRepository _repository;

  Future<List<LearnCategory>> call() async {
    return _repository.getCategories();
  }
}
