import 'package:hive/hive.dart';
import '../../../../shared/data/hive_config.dart';
import '../../domain/entities/word_list.dart';
import '../../domain/repositories/word_list_repository.dart';
import '../models/word_list_model.dart';

class HiveWordListRepository implements WordListRepository {
  Box<WordListModel> get _box => Hive.box<WordListModel>(HiveBoxes.wordLists);

  @override
  Future<List<WordList>> getAll() async =>
      _box.values.map((m) => m.toEntity()).toList();

  @override
  Future<WordList?> getById(String id) async =>
      _box.get(id)?.toEntity();

  @override
  Future<void> save(WordList list) async =>
      _box.put(list.id, WordListModel.fromEntity(list));

  @override
  Future<void> delete(String id) async => _box.delete(id);
}
