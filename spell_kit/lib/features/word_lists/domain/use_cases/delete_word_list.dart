import '../repositories/word_list_repository.dart';

class DeleteWordList {
  const DeleteWordList(this._repository);

  final WordListRepository _repository;

  Future<void> call(String id) => _repository.delete(id);
}
