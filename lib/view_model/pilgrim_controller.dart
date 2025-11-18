import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_transscript/core/services/translation_service.dart';
import 'package:voice_transscript/core/services/tts_service.dart';
import 'package:voice_transscript/injection.dart';
import 'package:voice_transscript/models/language_model.dart';
import 'package:voice_transscript/view_model/connectivity_controller.dart';

class MessageModel {
  final String originalText;
  final String translatedText;

  MessageModel({required this.originalText, required this.translatedText});
}

class PilgrimController extends GetxController {
  final SpeechToText _speechToText = SpeechToText();
  final ConnectivityController _connectivityController =
      sl<ConnectivityController>();
  final TranslationService _translationService = sl<TranslationService>();
  final TTSService _ttsService = sl<TTSService>();

  // Auto-detected languages (updated based on spoken text)
  LanguageModel detectedSourceLanguage = Languages.all[1]; // Arabic by default
  LanguageModel targetLanguage = Languages.all[0]; // English by default
  // Auto-detection - COMMENTED OUT
  // bool isAutoDetectingSource = true; // Whether source language is auto-detected
  bool isAutoDetectingSource = false; // Auto-detection disabled

  // State variables
  bool speechEnabled = false;
  bool isListening = false;
  bool microphonePermissionGranted = false;
  String currentWords = '';
  String currentTranslated = '';
  List<MessageModel> messages = [];
  bool isTranslating = false;

  // Getter for connectivity status
  ConnectivityController get connectivityController => _connectivityController;

  @override
  void onInit() {
    super.onInit();
    log("PilgrimController: OnInit()");
    _initSpeech();
    _translationService.initialize();
    // Initialize TTS asynchronously to avoid blocking
    _ttsService.initialize().catchError((e) {
      debugPrint('TTS initialization error: $e');
    });
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint("PilgrimController: onReady()");
  }

  @override
  void onClose() {
    _speechToText.stop();
    _translationService.dispose();
    super.onClose();
  }

  Future<void> _initSpeech() async {
    try {
      debugPrint('Initializing speech recognition...');

      // Check if we already have permission
      final hasPermission = await _speechToText.hasPermission;
      microphonePermissionGranted = hasPermission;
      debugPrint('Speech permission status: $hasPermission');

      // Initialize speech recognition
      final available = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: (error) {
          debugPrint('Speech error: $error');
          speechEnabled = false;
          update();
        },
      );

      debugPrint('Speech initialization result: $available');
      speechEnabled = available;

      // Log available locales for debugging
      if (available) {
        try {
          final locales = await _speechToText.locales();
          debugPrint('Available speech recognition locales: ${locales.length}');
          final arabicLocales =
              locales
                  .where((locale) => locale.localeId.startsWith('ar'))
                  .toList();
          final englishLocales =
              locales
                  .where((locale) => locale.localeId.startsWith('en'))
                  .toList();
          debugPrint(
            'Arabic locales: ${arabicLocales.map((l) => l.localeId).join(", ")}',
          );
          debugPrint(
            'English locales: ${englishLocales.map((l) => l.localeId).join(", ")}',
          );
        } catch (e) {
          debugPrint('Error getting locales: $e');
        }
      } else {
        debugPrint('Speech recognition is not available. Possible reasons:');
        debugPrint('1. Microphone permission not granted');
        debugPrint('2. Speech recognition permission not granted');
        debugPrint('3. Speech recognition not supported on this device');

        // Try to check permission again
        final permissionAfterInit = await _speechToText.hasPermission;
        microphonePermissionGranted = permissionAfterInit;
        debugPrint('Permission status after init: $permissionAfterInit');
      }

      update();
    } catch (e) {
      debugPrint('Error initializing speech: $e');
      speechEnabled = false;
      update();
    }
  }

  void _onSpeechStatus(String status) {
    if (status == 'notListening' && isListening) {
      finalizeCurrentMessage();
    }
  }

  /// Re-initialize speech recognition (useful if permissions were denied initially)
  Future<void> reinitializeSpeech() async {
    debugPrint('Re-initializing speech recognition...');
    await _initSpeech();
  }

  Future<void> toggleListening() async {
    debugPrint(
      'toggleListening called. speechEnabled: $speechEnabled, isListening: $isListening',
    );

    if (!speechEnabled) {
      debugPrint('Speech is not enabled. Attempting to re-initialize...');
      // Try to re-initialize in case permissions were just granted
      await reinitializeSpeech();
      if (!speechEnabled) {
        debugPrint('Speech is still not enabled after re-initialization.');
        return;
      }
    }

    try {
      if (isListening) {
        debugPrint('Stopping speech recognition...');
        await _speechToText.stop();
        finalizeCurrentMessage();
      } else {
        debugPrint('Starting speech recognition...');
        isListening = true;
        currentWords = '';
        currentTranslated = '';
        update();

        // Use null localeId to enable system auto-detection
        // This allows the device to detect the language being spoken
        // The translation service will then verify and translate based on text content
        final hasPermission = await _speechToText.hasPermission;
        debugPrint('Speech permission status: $hasPermission');

        if (!hasPermission) {
          debugPrint('No speech permission. Requesting...');
          final permissionStatus = await _speechToText.initialize(
            onStatus: _onSpeechStatus,
            onError: (error) => debugPrint('Speech error: $error'),
          );
          debugPrint('Permission request result: $permissionStatus');
          if (!permissionStatus) {
            isListening = false;
            update();
            return;
          }
        }

        await _speechToText.listen(
          onResult: (result) {
            final recognizedText = result.recognizedWords;
            debugPrint(
              'Speech recognized: "$recognizedText" | Final: ${result.finalResult}',
            );
            currentWords = recognizedText;

            // Auto-detection - COMMENTED OUT
            // Detect language from recognized text and update UI
            // if (recognizedText.isNotEmpty) {
            //   _detectLanguageFromText(recognizedText);
            // }

            // Auto-translate based on detected language in text content
            // This will check if text contains Arabic characters
            _translateCurrentWords(recognizedText);
            update();
            if (result.finalResult) {
              finalizeCurrentMessage(words: recognizedText);
            }
          },
          listenMode: ListenMode.confirmation,
          partialResults: true,
          localeId:
              null, // null enables system auto-detection for better multilingual support
        );
        debugPrint('Speech listening started successfully');
      }
    } catch (e) {
      debugPrint('Error in toggleListening: $e');
      isListening = false;
      update();
    }
  }

  /// Swap detected source and target languages
  void swapLanguages() {
    final temp = detectedSourceLanguage;
    detectedSourceLanguage = targetLanguage;
    targetLanguage = temp;
    // Auto-detection - COMMENTED OUT
    // When swapping, disable auto-detection if it was enabled
    // isAutoDetectingSource = false;
    update();
  }

  /// Set source language manually
  void setSourceLanguage(LanguageModel language) {
    detectedSourceLanguage = language;
    // Auto-detection - COMMENTED OUT
    // isAutoDetectingSource = false;
    update();
  }

  /// Set target language manually
  void setTargetLanguage(LanguageModel language) {
    targetLanguage = language;
    update();
  }

  /// Enable auto-detection for source language - COMMENTED OUT
  // void enableAutoDetection() {
  //   isAutoDetectingSource = true;
  //   update();
  // }

  /// Detect language from text and update detectedSourceLanguage
  /// Only updates if auto-detection is enabled - COMMENTED OUT
  // void _detectLanguageFromText(String text) {
  //   if (text.trim().isEmpty) return;
  //
  //   // Only auto-detect if auto-detection is enabled
  //   if (!isAutoDetectingSource) return;

  //   // Check if text is Arabic
  //   final isArabic = _isArabicText(text);

  //   if (isArabic) {
  //     detectedSourceLanguage = Languages.all[1]; // Arabic
  //     // Auto-set target to English if source is Arabic
  //     if (targetLanguage.code == 'ar') {
  //       targetLanguage = Languages.all[0]; // English
  //     }
  //   } else {
  //     // Assume English for non-Arabic text (could be enhanced with better detection)
  //     detectedSourceLanguage = Languages.all[0]; // English
  //     // Auto-set target to Arabic if source is English
  //     if (targetLanguage.code == 'en') {
  //       targetLanguage = Languages.all[1]; // Arabic
  //     }
  //   }

  //   update();
  // }

  /// Detect language from text - DISABLED (auto-detection commented out)
  void _detectLanguageFromText(String text) {
    // Auto-detection disabled - no action
    return;
  }

  /// Check if text contains Arabic characters
  bool _isArabicText(String text) {
    if (text.trim().isEmpty) return false;
    final arabicRegex = RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    );
    final arabicChars =
        text.split('').where((char) => arabicRegex.hasMatch(char)).length;
    final totalChars = text.replaceAll(RegExp(r'\s'), '').length;
    if (totalChars == 0) return false;
    final arabicRatio = arabicChars / totalChars;
    return arabicRatio > 0.3;
  }

  Future<void> _translateCurrentWords(String text) async {
    if (text.trim().isEmpty) {
      currentTranslated = '';
      return;
    }

    try {
      debugPrint('Translating text: "$text"');

      // Auto-detection - COMMENTED OUT
      // Detect language from text and update UI
      // _detectLanguageFromText(text);

      // Translate based on detected source and selected target
      final translated = await _translateBasedOnLanguages(text);
      debugPrint('Translation result: "$translated"');
      currentTranslated = translated;
      update();
    } catch (e) {
      debugPrint('Error translating current words: $e');
      // Keep currentTranslated empty if translation fails
    }
  }

  /// Translate text based on detected source language and selected target language
  Future<String> _translateBasedOnLanguages(String text) async {
    final sourceCode = detectedSourceLanguage.code;
    final targetCode = targetLanguage.code;

    // If source and target are the same, return original text
    if (sourceCode == targetCode) {
      return text;
    }

    // Use translation service based on language codes
    if (sourceCode == 'ar' && targetCode == 'en') {
      return await _translationService.translateArabicToEnglish(text);
    } else if (sourceCode == 'en' && targetCode == 'ar') {
      return await _translationService.translateToArabic(text);
    } else {
      // For other combinations, use auto-translate as fallback
      return await _translationService.translateAuto(text);
    }
  }

  Future<void> finalizeCurrentMessage({String? words}) async {
    final text = (words ?? currentWords).trim();
    if (text.isEmpty) {
      isListening = false;
      currentWords = '';
      currentTranslated = '';
      update();
      return;
    }

    isTranslating = true;
    update();

    // Auto-detection - COMMENTED OUT
    // Detect language from text
    // _detectLanguageFromText(text);

    // Translate based on detected source and selected target
    String translatedText = text;
    try {
      translatedText = await _translateBasedOnLanguages(text);
    } catch (e) {
      debugPrint('Error translating message: $e');
      // Use original text if translation fails
    }

    messages.add(
      MessageModel(originalText: text, translatedText: translatedText),
    );

    isListening = false;
    currentWords = '';
    currentTranslated = '';
    isTranslating = false;
    update();
  }

  bool get hasMessages => messages.isNotEmpty || currentWords.isNotEmpty;

  // Language locale mapping - NOT USED (auto-detection enabled)
  // String? _getLocaleIdForLanguage(String code) {
  //   // Map language codes to locale IDs for speech recognition
  //   final localeMap = {
  //     'en': 'en_US',
  //     'ar': 'ar_SA',
  //     'ur': 'ur_PK',
  //     'id': 'id_ID',
  //     'bn': 'bn_BD',
  //     'tr': 'tr_TR',
  //   };
  //   return localeMap[code] ?? code;
  // }
}
