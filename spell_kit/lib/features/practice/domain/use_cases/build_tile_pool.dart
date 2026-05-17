import '../../../../shared/domain/value_objects/difficulty.dart';

class BuildTilePool {
  static const _alphabet = 'abcdefghijklmnopqrstuvwxyz';

  List<String> call(String word, Difficulty difficulty) {
    final letters = word.split('');
    final decoyCount = switch (difficulty) {
      Difficulty.starter => 0,
      Difficulty.explorer => 2,
      Difficulty.challenger || Difficulty.master || Difficulty.expert => 5,
    };
    final decoys = _alphabet.split('')
      ..removeWhere(letters.contains)
      ..shuffle();
    return [...letters, ...decoys.take(decoyCount)]..shuffle();
  }
}
