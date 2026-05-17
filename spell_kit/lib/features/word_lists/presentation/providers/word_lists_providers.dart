import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/hive_word_list_repository.dart';
import '../../domain/entities/word_list.dart';
import '../../domain/repositories/word_list_repository.dart';
import '../../domain/use_cases/add_word_list.dart';
import '../../domain/use_cases/delete_word_list.dart';

final wordListRepositoryProvider = Provider<WordListRepository>(
  (_) => HiveWordListRepository(),
);

final addWordListProvider = Provider(
  (ref) => AddWordList(ref.read(wordListRepositoryProvider)),
);

final deleteWordListProvider = Provider(
  (ref) => DeleteWordList(ref.read(wordListRepositoryProvider)),
);

final wordListsProvider =
    AsyncNotifierProvider<WordListsNotifier, List<WordList>>(
  WordListsNotifier.new,
);

class WordListsNotifier extends AsyncNotifier<List<WordList>> {
  @override
  Future<List<WordList>> build() =>
      ref.read(wordListRepositoryProvider).getAll();

  Future<void> add(String name, List<String> words) async {
    await ref.read(addWordListProvider).call(name, words);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await ref.read(deleteWordListProvider).call(id);
    ref.invalidateSelf();
  }
}
