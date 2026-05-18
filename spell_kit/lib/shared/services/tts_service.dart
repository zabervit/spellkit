import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  static const _normalRate = 0.45;
  static const _slowRate = 0.3;

  Future<void> init() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(_normalRate);
    await _tts.setVolume(1.0);
  }

  Future<void> speak(String word) async {
    await _tts.setSpeechRate(_normalRate);
    await _tts.speak(word);
  }

  Future<void> slowSpeak(String word) async {
    await _tts.setSpeechRate(_slowRate);
    await _tts.speak(word);
  }

  Future<void> stop() => _tts.stop();

  void dispose() => _tts.stop();
}

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  service.init();
  ref.onDispose(service.dispose);
  return service;
});
