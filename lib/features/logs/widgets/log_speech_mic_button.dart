import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:adventure_logger/core/services/speech_dictation_service.dart';
import 'package:adventure_logger/core/utils/app_theme.dart';

/// Mic control for speech-to-text into a [TextEditingController].
///
/// [longForm] uses dictation-oriented timeouts; short titles use confirmation mode.
/// [combineWithExistingText] keeps text that was already in the field before listen started.
class LogSpeechMicButton extends StatefulWidget {
  final TextEditingController controller;
  final bool longForm;
  final bool combineWithExistingText;

  const LogSpeechMicButton({
    super.key,
    required this.controller,
    this.longForm = false,
    this.combineWithExistingText = false,
  });

  @override
  State<LogSpeechMicButton> createState() => _LogSpeechMicButtonState();
}

class _LogSpeechMicButtonState extends State<LogSpeechMicButton> {
  final SpeechDictationService _svc = SpeechDictationService.instance;
  bool _listening = false;
  String _prefixBeforeListen = '';

  Future<void> _toggle() async {
    if (_listening) {
      await _svc.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    final ok = await _svc.initialize(
      onError: (_) {},
      onStatus: (status) {
        if (status == SpeechToText.doneStatus ||
            status == SpeechToText.notListeningStatus) {
          if (mounted) setState(() => _listening = false);
        }
      },
    );

    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is not available on this device.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _prefixBeforeListen = widget.combineWithExistingText
        ? widget.controller.text.trimRight()
        : '';

    try {
      await _svc.listen(
        listenMode: widget.longForm
            ? ListenMode.dictation
            : ListenMode.confirmation,
        listenFor: widget.longForm
            ? const Duration(minutes: 2)
            : const Duration(seconds: 45),
        pauseFor: widget.longForm
            ? const Duration(seconds: 5)
            : const Duration(seconds: 3),
        onResult: (result) {
          final spoken = result.recognizedWords;
          if (!mounted) return;
          if (widget.combineWithExistingText) {
            final p = _prefixBeforeListen;
            widget.controller.text =
                p.isEmpty ? spoken : '$p $spoken'.trim();
          } else {
            widget.controller.text = spoken;
          }
          widget.controller.selection = TextSelection.collapsed(
            offset: widget.controller.text.length,
          );
          setState(() {});
        },
      );
      if (mounted) setState(() => _listening = true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not start speech recognition.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (_listening) {
      _svc.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: _listening ? 'Stop dictation' : 'Speak to type',
      onPressed: _toggle,
      icon: Icon(
        _listening ? Icons.mic : Icons.mic_none_rounded,
        color: _listening ? Colors.red.shade700 : AppTheme.forestGreen,
      ),
    );
  }
}
