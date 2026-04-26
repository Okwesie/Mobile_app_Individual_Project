import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

enum TtsPlaybackState { stopped, speaking, paused }

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  final ValueNotifier<TtsPlaybackState> playbackState =
      ValueNotifier(TtsPlaybackState.stopped);
  bool _initialized = false;
  List<String> _segments = const [];
  int _segmentIndex = 0;
  int _playbackRun = 0;
  bool _pauseRequested = false;
  bool _stopRequested = false;

  bool get isSpeaking => playbackState.value == TtsPlaybackState.speaking;
  bool get canResume =>
      playbackState.value == TtsPlaybackState.paused && _segments.isNotEmpty;

  Future<void> _ensureInit(double rate) async {
    if (!_initialized) {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
      _tts.setStartHandler(() {
        playbackState.value = TtsPlaybackState.speaking;
      });
      _tts.setCompletionHandler(() {
        if (_segmentIndex >= _segments.length - 1) {
          playbackState.value = TtsPlaybackState.stopped;
        }
      });
      _tts.setCancelHandler(() {
        playbackState.value =
            _pauseRequested ? TtsPlaybackState.paused : TtsPlaybackState.stopped;
      });
      _tts.setPauseHandler(() {
        playbackState.value = TtsPlaybackState.paused;
      });
      _tts.setErrorHandler((_) {
        playbackState.value = TtsPlaybackState.stopped;
      });
      _initialized = true;
    }
    await _tts.setSpeechRate(rate.clamp(0.1, 1.0));
  }

  Future<void> speak(String text, {double rate = 0.5}) async {
    await _ensureInit(rate);
    if (playbackState.value != TtsPlaybackState.stopped) await stop();
    _segments = _splitIntoSegments(text);
    _segmentIndex = 0;
    await _playFromCurrent();
  }

  Future<void> resume() async {
    if (!canResume) return;
    await _playFromCurrent();
  }

  Future<void> _playFromCurrent() async {
    final run = ++_playbackRun;
    _pauseRequested = false;
    _stopRequested = false;
    playbackState.value = TtsPlaybackState.speaking;

    while (_segmentIndex < _segments.length && run == _playbackRun) {
      await _tts.speak(_segments[_segmentIndex]);
      if (run != _playbackRun || _pauseRequested || _stopRequested) break;
      _segmentIndex++;
    }

    if (run != _playbackRun) return;
    if (_pauseRequested) {
      playbackState.value = TtsPlaybackState.paused;
      return;
    }
    _resetPlayback();
  }

  Future<void> pause() async {
    if (playbackState.value != TtsPlaybackState.speaking) return;
    _pauseRequested = true;
    // flutter_tts does not offer reliable resume-from-word support on Android.
    // Stopping here lets us resume from the current sentence/chunk ourselves.
    await _tts.stop();
    playbackState.value = TtsPlaybackState.paused;
  }

  Future<void> stop() async {
    _stopRequested = true;
    _playbackRun++;
    await _tts.stop();
    _resetPlayback();
  }

  void _resetPlayback() {
    _segments = const [];
    _segmentIndex = 0;
    _pauseRequested = false;
    _stopRequested = false;
    playbackState.value = TtsPlaybackState.stopped;
  }

  List<String> _splitIntoSegments(String text) {
    final parts = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.isEmpty ? [text] : parts;
  }

  Future<void> dispose() async {
    await stop();
    playbackState.dispose();
  }
}
