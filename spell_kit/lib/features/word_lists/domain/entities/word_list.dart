import 'package:equatable/equatable.dart';

class WordList extends Equatable {
  const WordList({
    required this.id,
    required this.name,
    required this.words,
    required this.createdAt,
    this.lastPracticedAt,
    this.colorIndex = 0,
  });

  final String id;
  final String name;
  final List<String> words;
  final DateTime createdAt;
  final DateTime? lastPracticedAt;
  final int colorIndex;

  WordList copyWith({
    String? name,
    List<String>? words,
    DateTime? lastPracticedAt,
    int? colorIndex,
  }) =>
      WordList(
        id: id,
        name: name ?? this.name,
        words: words ?? this.words,
        createdAt: createdAt,
        lastPracticedAt: lastPracticedAt ?? this.lastPracticedAt,
        colorIndex: colorIndex ?? this.colorIndex,
      );

  @override
  List<Object?> get props => [id, name, words, createdAt, lastPracticedAt, colorIndex];
}
