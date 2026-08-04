import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum CookingVoiceCommand {
  next,
  previous,
  repeat,
  startTimer,
  pauseTimer,
  resetTimer,
  addMinute,
  finish,
  unknown,
}

class VoiceCookingService {
  VoiceCookingService({
    SpeechToText? speech,
    FlutterTts? tts,
  })  : _speech = speech ?? SpeechToText(),
        _tts = tts ?? FlutterTts();

  final SpeechToText _speech;
  final FlutterTts _tts;
  bool _ready = false;

  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    if (_ready) return true;

    _ready = await _speech.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );

    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    return _ready;
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> listen({
    required void Function(String words, bool finalResult) onWords,
  }) async {
    if (!await initialize() || _speech.isListening) return;

    await _speech.listen(
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      onResult: (result) {
        onWords(result.recognizedWords, result.finalResult);
      },
    );
  }

  Future<void> stopListening() => _speech.stop();

  static CookingVoiceCommand parseCommand(String words) {
    final value = words
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');

    if (value.contains('next') ||
        value.contains('continue') ||
        value.contains('done')) {
      return CookingVoiceCommand.next;
    }
    if (value.contains('previous') ||
        value.contains('go back') ||
        value == 'back') {
      return CookingVoiceCommand.previous;
    }
    if (value.contains('repeat') ||
        value.contains('say again') ||
        value.contains('read again')) {
      return CookingVoiceCommand.repeat;
    }
    if ((value.contains('start') || value.contains('begin')) &&
        value.contains('timer')) {
      return CookingVoiceCommand.startTimer;
    }
    if ((value.contains('pause') || value.contains('stop')) &&
        value.contains('timer')) {
      return CookingVoiceCommand.pauseTimer;
    }
    if ((value.contains('reset') || value.contains('restart')) &&
        value.contains('timer')) {
      return CookingVoiceCommand.resetTimer;
    }
    if (value.contains('add minute') ||
        value.contains('one more minute') ||
        value.contains('plus one minute')) {
      return CookingVoiceCommand.addMinute;
    }
    if (value.contains('finish') ||
        value.contains('meal ready') ||
        value.contains('recipe complete')) {
      return CookingVoiceCommand.finish;
    }
    return CookingVoiceCommand.unknown;
  }

  Future<void> dispose() async {
    await _speech.stop();
    await _tts.stop();
  }
}
