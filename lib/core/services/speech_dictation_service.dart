import 'package:speech_to_text/speech_to_text.dart';

/// Thin wrapper around [speech_to_text] for log title / notes dictation.
class SpeechDictationService {
  SpeechDictationService._();
  static final SpeechDictationService instance = SpeechDictationService._();

  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  SpeechToText get speech => _speech;

  bool get isInitialized => _initialized;

  Future<bool> initialize({
    SpeechErrorListener? onError,
    SpeechStatusListener? onStatus,
  }) async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(
      onError: onError,
      onStatus: onStatus,
    );
    return _initialized;
  }

  bool get isListening => _speech.isListening;

  Future<void> stop() async {
    if (_speech.isListening) await _speech.stop();
  }

  Future<void> listen({
    required SpeechResultListener onResult,
    ListenMode listenMode = ListenMode.confirmation,
    Duration listenFor = const Duration(seconds: 45),
    Duration pauseFor = const Duration(seconds: 4),
  }) async {
    if (!_initialized) {
      throw StateError('SpeechDictationService not initialized');
    }
    await _speech.listen(
      onResult: onResult,
      listenFor: listenFor,
      pauseFor: pauseFor,
      listenOptions: SpeechListenOptions(
        listenMode: listenMode,
        partialResults: true,
      ),
    );
  }
}
