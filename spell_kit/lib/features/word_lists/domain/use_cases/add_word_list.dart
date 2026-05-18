import 'package:uuid/uuid.dart';
import '../entities/word_list.dart';
import '../repositories/word_list_repository.dart';

class AddWordList {
  const AddWordList(this._repository);

  final WordListRepository _repository;

  Future<WordList> call(String name, List<String> words, {int colorIndex = 0}) async {
    final list = WordList(
      id: const Uuid().v4(),
      name: name,
      words: words,
      createdAt: DateTime.now(),
      colorIndex: colorIndex,
    );
    await _repository.save(list);
    return list;
  }
}
