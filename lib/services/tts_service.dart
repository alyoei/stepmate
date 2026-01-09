import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _tts = FlutterTts();

  static Future<void> init() async {
    await _tts.setLanguage("id-ID");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5); // Kecepatan bicara normal
  }

  static Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }
}