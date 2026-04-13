import 'dart:async';
import 'package:flutter/services.dart';

enum LightCondition { bright, moderate, dim, dark }

class SensorService {
  SensorService._();
  static final SensorService instance = SensorService._();

  static const EventChannel _channel =
      EventChannel('com.calebarthur.adventure_logger/light');

  StreamSubscription<double>? _subscription;
  double _currentLux = -1.0;
  bool _isListening = false;

  double get currentLux => _currentLux;
  bool get isListening => _isListening;

  Stream<double> get _luxStream => _channel
      .receiveBroadcastStream()
      .map((v) => (v as num).toDouble())
      .handleError((_) => -1.0);

  void startListening({void Function(double lux)? onUpdate}) {
    if (_isListening) return;
    _isListening = true;
    _subscription = _luxStream.listen(
      (lux) {
        _currentLux = lux;
        onUpdate?.call(lux);
      },
      onError: (_) {
        _currentLux = -1.0;
        _isListening = false;
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
  }

  /// One-shot: returns lux or -1.0 if sensor unavailable / timeout.
  Future<double> readOnce() async {
    if (_isListening) return _currentLux;

    final completer = Completer<double>();
    StreamSubscription<double>? sub;

    try {
      sub = _luxStream.listen(
        (lux) {
          if (!completer.isCompleted) {
            completer.complete(lux);
            sub?.cancel();
          }
        },
        onError: (_) {
          if (!completer.isCompleted) {
            completer.complete(-1.0);
            sub?.cancel();
          }
        },
      );
    } on PlatformException {
      return -1.0;
    }

    // 3-second timeout in case sensor never fires
    Future.delayed(const Duration(seconds: 3), () {
      if (!completer.isCompleted) {
        completer.complete(-1.0);
        sub?.cancel();
      }
    });

    return completer.future;
  }

  static LightCondition classify(double lux) {
    if (lux < 0) return LightCondition.dark;
    if (lux >= 1000) return LightCondition.bright;
    if (lux >= 200) return LightCondition.moderate;
    if (lux >= 20) return LightCondition.dim;
    return LightCondition.dark;
  }

  static String conditionLabel(LightCondition c) => switch (c) {
        LightCondition.bright => 'Bright',
        LightCondition.moderate => 'Moderate',
        LightCondition.dim => 'Dim',
        LightCondition.dark => 'Dark',
      };

  static String safetyAdvice(LightCondition c) => switch (c) {
        LightCondition.bright => 'Excellent visibility. Safe to continue trail.',
        LightCondition.moderate => 'Good visibility. Sunglasses recommended.',
        LightCondition.dim => 'Low light. Use a headlamp or flashlight.',
        LightCondition.dark => 'Very dark. Stop and use lighting equipment.',
      };
}
