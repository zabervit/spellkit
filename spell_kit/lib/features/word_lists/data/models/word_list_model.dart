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
    this.colorIndex = 0,
  });

  String id;
  String name;
  List<String> words;
  DateTime createdAt;
  DateTime? lastPracticedAt;
  int colorIndex;

  factory WordListModel.fromEntity(WordList entity) => WordListModel(
        id: entity.id,
        name: entity.name,
        words: List<String>.from(entity.words),
        createdAt: entity.createdAt,
        lastPracticedAt: entity.lastPracticedAt,
        colorIndex: entity.colorIndex,
      );

  WordList toEntity() => WordList(
        id: id,
        name: name,
        words: List<String>.unmodifiable(words),
        createdAt: createdAt,
        lastPracticedAt: lastPracticedAt,
        colorIndex: colorIndex,
      );
}

class WordListModelAdapter extends TypeAdapter<WordListModel> {
  @override
  final int typeId = HiveTypeIds.wordListModel;

  @override
  WordListModel read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final words = reader.readStringList();
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final hasDate = reader.readBool();
    final lastPracticedAt =
        hasDate ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
    // colorIndex was added after initial release — default to 0 for old records
    int colorIndex = 0;
    try {
      colorIndex = reader.readInt();
    } catch (_) {}
    return WordListModel(
      id: id,
      name: name,
      words: words,
      createdAt: createdAt,
      lastPracticedAt: lastPracticedAt,
      colorIndex: colorIndex,
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
    writer.writeInt(obj.colorIndex);
  }
}
