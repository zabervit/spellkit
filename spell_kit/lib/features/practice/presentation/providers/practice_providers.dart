import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/domain/value_objects/difficulty.dart';
import '../../domain/entities/practice_state.dart';
import '../../domain/entities/word_result.dart';
import '../../domain/services/rule_based_hint_service.dart';

const _maxAttempts = 3;

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

  Future<bool> submitAnswer(String answer) async {
    final current = state.currentWord;
    final isCorrect = answer.toLowerCase() == current.toLowerCase();
    final newAttempts = state.attempts + 1;

    if (isCorrect || newAttempts >= _maxAttempts) {
      final result = WordResult(
        word: current,
        attempts: newAttempts,
        correct: isCorrect,
      );
      final newResults = [...state.results, result];
      final nextIndex = state.currentIndex + 1;
      state = state.copyWith(
        results: newResults,
        attempts: 0,
        currentIndex: state.isLastWord ? state.currentIndex : nextIndex,
        status: state.isLastWord
            ? PracticeStatus.sessionComplete
            : PracticeStatus.wordComplete,
      );
      return isCorrect;
    }

    state = state.copyWith(attempts: newAttempts);
    return false;
  }

  void nextWord() {
    if (state.status == PracticeStatus.sessionComplete) return;
    state = state.copyWith(status: PracticeStatus.inProgress);
  }

  Future<String> getHint(String attempt) =>
      _hintService.explain(state.currentWord, attempt);
}
