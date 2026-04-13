import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> _ensureInit(double rate) async {
    if (!_initialized) {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.0);
      _tts.setStartHandler(() => _isSpeaking = true);
      _tts.setCompletionHandler(() => _isSpeaking = false);
      _tts.setCancelHandler(() => _isSpeaking = false);
      _tts.setErrorHandler((_) => _isSpeaking = false);
      _initialized = true;
    }
    await _tts.setSpeechRate(rate.clamp(0.1, 1.0));
  }

  Future<void> speak(String text, {double rate = 0.5}) async {
    await _ensureInit(rate);
    if (_isSpeaking) await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  Future<void> dispose() async {
    await stop();
  }
}
