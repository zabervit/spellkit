import 'package:audioplayers/audioplayers.dart';

enum SoundEffect { correct, wrong, levelUp }

class AudioService {
  final _player = AudioPlayer();

  Future<void> play(SoundEffect effect) async {
    final path = switch (effect) {
      SoundEffect.correct => 'sounds/correct.mp3',
      SoundEffect.wrong => 'sounds/wrong.mp3',
      SoundEffect.levelUp => 'sounds/level_up.mp3',
    };
    await _player.play(AssetSource(path));
  }

  void dispose() => _player.dispose();
}
