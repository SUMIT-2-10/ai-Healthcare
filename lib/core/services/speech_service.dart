import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

enum SpeechStatus { idle, listening, done, error }

class SpeechService {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isInitialized = false;
  bool get isListening => _stt.isListening;

  // Callbacks
  ValueChanged<String>? onResult;
  ValueChanged<SpeechStatus>? onStatusChange;
  ValueChanged<double>? onSoundLevel;

  // ─── Initialise ────────────────────────────────────────────────────────────

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      AppLogger.w('Microphone permission denied');
      onStatusChange?.call(SpeechStatus.error);
      return false;
    }

    _isInitialized = await _stt.initialize(
      onError: (error) {
        AppLogger.e('STT error: ${error.errorMsg}');
        onStatusChange?.call(SpeechStatus.error);
      },
      onStatus: (status) {
        AppLogger.d('STT status: $status');
        if (status == 'done' || status == 'notListening') {
          onStatusChange?.call(SpeechStatus.done);
        }
      },
    );

    await _configureTts();
    AppLogger.i('SpeechService initialized: $_isInitialized');
    return _isInitialized;
  }

  // ─── STT ────────────────────────────────────────────────────────────────────

  Future<void> startListening({String locale = 'hi_IN'}) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return;
    }

    if (_stt.isListening) await stopListening();

    onStatusChange?.call(SpeechStatus.listening);

    await _stt.listen(
      localeId: locale,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      partialResults: true,
      cancelOnError: false,
      listenMode: ListenMode.confirmation,
      onResult: (result) {
        AppLogger.d('STT result: ${result.recognizedWords}');
        if (result.recognizedWords.isNotEmpty) {
          onResult?.call(result.recognizedWords);
        }
        if (result.finalResult) {
          onStatusChange?.call(SpeechStatus.done);
        }
      },
      onSoundLevelChange: (level) {
        onSoundLevel?.call(level);
      },
    );
  }

  Future<void> stopListening() async {
    await _stt.stop();
    onStatusChange?.call(SpeechStatus.done);
  }

  Future<void> cancelListening() async {
    await _stt.cancel();
    onStatusChange?.call(SpeechStatus.idle);
  }

  // ─── TTS ────────────────────────────────────────────────────────────────────

  Future<void> _configureTts() async {
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.85);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      AppLogger.d('TTS completed');
    });
  }

  Future<void> speak(String text, {String language = 'hi-IN'}) async {
    await _tts.setLanguage(language);
    await _tts.speak(text);
    AppLogger.d('TTS speaking in $language: ${text.substring(0, text.length.clamp(0, 50))}...');
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  Future<List<dynamic>> getAvailableLanguages() async {
    return await _tts.getLanguages;
  }

  // ─── Cleanup ────────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    await _stt.cancel();
    await _tts.stop();
  }
}
