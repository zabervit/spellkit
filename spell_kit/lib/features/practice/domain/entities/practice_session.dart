import 'package:equatable/equatable.dart';
import '../../../../shared/domain/value_objects/difficulty.dart';
import 'word_result.dart';

class PracticeSession extends Equatable {
  const PracticeSession({
    required this.id,
    required this.listId,
    required this.date,
    required this.difficulty,
    required this.results,
  });

  final String id;
  final String listId;
  final DateTime date;
  final Difficulty difficulty;
  final List<WordResult> results;

  int get xpEarned => results.fold(0, (sum, r) {
        if (!r.correct) return sum;
        final base = switch (r.attempts) {
          1 => 10,
          2 => 5,
          _ => 2,
        };
        return sum + (base * difficulty.multiplier).round();
      });

  int get stars {
    if (results.isEmpty) return 0;
    final accuracy = results.where((r) => r.correct).length / results.length;
    if (accuracy >= 0.9) return 3;
    if (accuracy >= 0.6) return 2;
    return 1;
  }

  int get wordCount => results.length;

  @override
  List<Object?> get props => [id, listId, date, difficulty, results];
}
