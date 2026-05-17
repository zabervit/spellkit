import 'package:equatable/equatable.dart';
import '../../../../shared/domain/value_objects/difficulty.dart';
import 'word_result.dart';

enum PracticeStatus { idle, inProgress, wordComplete, sessionComplete }

class PracticeState extends Equatable {
  const PracticeState({
    required this.listId,
    required this.words,
    required this.difficulty,
    required this.currentIndex,
    required this.attempts,
    required this.results,
    required this.status,
  });

  factory PracticeState.initial({
    required String listId,
    required List<String> words,
    required Difficulty difficulty,
  }) =>
      PracticeState(
        listId: listId,
        words: words,
        difficulty: difficulty,
        currentIndex: 0,
        attempts: 0,
        results: const [],
        status: PracticeStatus.inProgress,
      );

  final String listId;
  final List<String> words;
  final Difficulty difficulty;
  final int currentIndex;
  final int attempts;
  final List<WordResult> results;
  final PracticeStatus status;

  String get currentWord => words[currentIndex];
  bool get isLastWord => currentIndex >= words.length - 1;

  PracticeState copyWith({
    int? currentIndex,
    int? attempts,
    List<WordResult>? results,
    PracticeStatus? status,
  }) =>
      PracticeState(
        listId: listId,
        words: words,
        difficulty: difficulty,
        currentIndex: currentIndex ?? this.currentIndex,
        attempts: attempts ?? this.attempts,
        results: results ?? this.results,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props =>
      [listId, words, difficulty, currentIndex, attempts, results, status];
}
