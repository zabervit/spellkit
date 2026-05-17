import 'hint_service.dart';

class RuleBasedHintService implements HintService {
  @override
  Future<String> explain(String word, String attempt) async {
    if (attempt.length != word.length) {
      return 'The word has ${word.length} letters.';
    }
    for (var i = 0; i < word.length; i++) {
      if (attempt[i] != word[i]) {
        return 'Check letter ${i + 1} — it should be "${word[i].toUpperCase()}".';
      }
    }
    return 'Almost! Try again carefully.';
  }
}
