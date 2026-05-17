import '../entities/word_list.dart';

abstract class WordListRepository {
  Future<List<WordList>> getAll();
  Future<WordList?> getById(String id);
  Future<void> save(WordList list);
  Future<void> delete(String id);
}
