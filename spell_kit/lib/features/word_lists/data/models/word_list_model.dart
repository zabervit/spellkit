import 'package:hive/hive.dart';
import '../../../../shared/data/hive_config.dart';
import '../../domain/entities/word_list.dart';

class WordListModel extends HiveObject {
  WordListModel({
    required this.id,
    required this.name,
    required this.words,
    required this.createdAt,
    this.lastPracticedAt,
  });

  String id;
  String name;
  List<String> words;
  DateTime createdAt;
  DateTime? lastPracticedAt;

  factory WordListModel.fromEntity(WordList entity) => WordListModel(
        id: entity.id,
        name: entity.name,
        words: List<String>.from(entity.words),
        createdAt: entity.createdAt,
        lastPracticedAt: entity.lastPracticedAt,
      );

  WordList toEntity() => WordList(
        id: id,
        name: name,
        words: List<String>.unmodifiable(words),
        createdAt: createdAt,
        lastPracticedAt: lastPracticedAt,
      );
}

class WordListModelAdapter extends TypeAdapter<WordListModel> {
  @override
  final int typeId = HiveTypeIds.wordListModel;

  @override
  WordListModel read(BinaryReader reader) {
    return WordListModel(
      id: reader.readString(),
      name: reader.readString(),
      words: reader.readStringList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      lastPracticedAt: reader.readBool()
          ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
          : null,
    );
  }

  @override
  void write(BinaryWriter writer, WordListModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeStringList(obj.words);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    final hasDate = obj.lastPracticedAt != null;
    writer.writeBool(hasDate);
    if (hasDate) writer.writeInt(obj.lastPracticedAt!.millisecondsSinceEpoch);
  }
}
