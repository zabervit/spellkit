import 'package:equatable/equatable.dart';

class WordList extends Equatable {
  const WordList({
    required this.id,
    required this.name,
    required this.words,
    required this.createdAt,
    this.lastPracticedAt,
  });

  final String id;
  final String name;
  final List<String> words;
  final DateTime createdAt;
  final DateTime? lastPracticedAt;

  WordList copyWith({
    String? name,
    List<String>? words,
    DateTime? lastPracticedAt,
  }) =>
      WordList(
        id: id,
        name: name ?? this.name,
        words: words ?? this.words,
        createdAt: createdAt,
        lastPracticedAt: lastPracticedAt ?? this.lastPracticedAt,
      );

  @override
  List<Object?> get props => [id, name, words, createdAt, lastPracticedAt];
}
