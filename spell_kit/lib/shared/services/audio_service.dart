import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SoundEffect { correct, wrong, levelUp }

class AudioService {
  final _player = AudioPlayer();

  Future<void> play(SoundEffect effect) async {
    final path = switch (effect) {
      SoundEffect.correct => 'sounds/correct.mp3',
      SoundEffect.wrong => 'sounds/wrong.mp3',
      SoundEffect.levelUp => 'sounds/level_up.mp3',
    };
    try {
      await _player.play(AssetSource(path));
    } catch (_) {
      // Sound file missing — silently skip.
    }
  }

  void dispose() => _player.dispose();
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});
