import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isAvailable = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _flutterTts = FlutterTts();
      await _flutterTts!.setLanguage('en');
      await _flutterTts!.setSpeechRate(0.5);
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.0);
      _isInitialized = true;
      _isAvailable = true;
    } on MissingPluginException catch (e) {
      debugPrint('TTS plugin not available: $e');
      debugPrint('Please rebuild the app: flutter clean && flutter pub get && flutter run');
      _isInitialized = false;
      _isAvailable = false;
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
      _isInitialized = false;
      _isAvailable = false;
    }
  }

  Future<void> speak(String text, {String? languageCode}) async {
    if (text.trim().isEmpty) return;
    if (!_isAvailable || _flutterTts == null) {
      debugPrint('TTS not available. Please rebuild the app.');
      return;
    }
    
    try {
      // Initialize if not already done
      if (!_isInitialized) {
        await initialize();
        if (!_isAvailable) return;
      }
      
      if (languageCode != null) {
        try {
          await _flutterTts!.setLanguage(languageCode);
        } catch (e) {
          debugPrint('Error setting language $languageCode: $e');
          // Try with default language
          try {
            await _flutterTts!.setLanguage('en');
          } catch (e2) {
            debugPrint('Error setting default language: $e2');
            return;
          }
        }
      }
      await _flutterTts!.speak(text);
    } on MissingPluginException catch (e) {
      debugPrint('TTS plugin error: $e. Please rebuild the app.');
      _isAvailable = false;
    } catch (e) {
      debugPrint('Error speaking text: $e');
    }
  }

  Future<void> stop() async {
    if (!_isAvailable || _flutterTts == null) return;
    
    try {
      await _flutterTts!.stop();
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }

  void dispose() {
    if (!_isAvailable || _flutterTts == null) return;
    
    try {
      _flutterTts!.stop();
    } catch (e) {
      debugPrint('Error disposing TTS: $e');
    }
  }
}

