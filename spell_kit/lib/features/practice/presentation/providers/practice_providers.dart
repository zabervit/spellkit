import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/domain/value_objects/difficulty.dart';
import '../../domain/entities/practice_state.dart';
import '../../domain/entities/word_result.dart';
import '../../domain/services/rule_based_hint_service.dart';

const maxPracticeAttempts = 3;

class PracticeArgs {
  const PracticeArgs(this.listId, this.words, this.difficulty);
  final String listId;
  final List<String> words;
  final Difficulty difficulty;
}

final practiceNotifierProvider =
    NotifierProvider.family<PracticeNotifier, PracticeState, PracticeArgs>(
  PracticeNotifier.new,
);

class PracticeNotifier extends FamilyNotifier<PracticeState, PracticeArgs> {
  final _hintService = RuleBasedHintService();

  @override
  PracticeState build(PracticeArgs arg) => PracticeState.initial(
        listId: arg.listId,
        words: arg.words,
        difficulty: arg.difficulty,
      );

  // Returns true if correct, false if wrong.
  // Does NOT advance currentIndex — call nextWord() after showing feedback.
  Future<bool> submitAnswer(String answer) async {
    final current = state.currentWord;
    final isCorrect = answer.toLowerCase() == current.toLowerCase();
    final newAttempts = state.attempts + 1;

    if (isCorrect || newAttempts >= maxPracticeAttempts) {
      final result = WordResult(
        word: current,
        attempts: newAttempts,
        correct: isCorrect,
      );
      state = state.copyWith(
        results: [...state.results, result],
        attempts: 0,
        status: state.isLastWord
            ? PracticeStatus.sessionComplete
            : PracticeStatus.wordComplete,
      );
      return isCorrect;
    }

    state = state.copyWith(attempts: newAttempts);
    return false;
  }

  // Advances to the next word. Call after celebrate/reveal animation.
  void nextWord() {
    if (state.status != PracticeStatus.wordComplete) return;
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      status: PracticeStatus.inProgress,
    );
  }

  Future<String> getHint(String attempt) =>
      _hintService.explain(state.currentWord, attempt);
}
