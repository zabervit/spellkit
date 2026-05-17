import 'package:equatable/equatable.dart';

class WordResult extends Equatable {
  const WordResult({
    required this.word,
    required this.attempts,
    required this.correct,
  });

  final String word;
  final int attempts;
  final bool correct;

  @override
  List<Object?> get props => [word, attempts, correct];
}
