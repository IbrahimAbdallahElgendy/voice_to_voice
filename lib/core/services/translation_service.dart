import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  OnDeviceTranslator? _translator;
  bool _isInitialized = false;

  /// Initialize the offline translator
  /// Downloads Arabic translation model if not already downloaded
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Create translator for English to Arabic (default)
      _translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: TranslateLanguage.arabic,
      );
      
      // Download models if needed (this only downloads once)
      final modelManager = OnDeviceTranslatorModelManager();
      
      // Download Arabic model
      final isArabicDownloaded = await modelManager.isModelDownloaded('ar');
      if (!isArabicDownloaded) {
        debugPrint('Downloading Arabic translation model...');
        await modelManager.downloadModel('ar');
        debugPrint('Arabic translation model downloaded');
      }
      
      // Download English model
      final isEnglishDownloaded = await modelManager.isModelDownloaded('en');
      if (!isEnglishDownloaded) {
        debugPrint('Downloading English translation model...');
        await modelManager.downloadModel('en');
        debugPrint('English translation model downloaded');
      }
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing translator: $e');
      _isInitialized = false;
    }
  }

  /// Auto-detects language and translates:
  /// - If Arabic: translates to English
  /// - If not Arabic: translates to Arabic
  Future<String> translateAuto(String text) async {
    if (text.trim().isEmpty) return text;
    
    if (!_isInitialized || _translator == null) {
      await initialize();
      if (!_isInitialized || _translator == null) {
        debugPrint('Translator not initialized, returning original text');
        return text;
      }
    }
    
    try {
      // Detect if text is Arabic
      final isArabic = _isArabicText(text);
      debugPrint('Language detection: isArabic = $isArabic for text: "$text"');
      
      if (isArabic) {
        // Arabic -> English
        debugPrint('Translating Arabic to English...');
        return await translateArabicToEnglish(text);
      } else {
        // Other language -> Arabic
        debugPrint('Translating to Arabic (assuming English)...');
        return await translateToArabic(text);
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      return text;
    }
  }

  /// Check if text contains Arabic characters
  /// Uses comprehensive Arabic Unicode ranges
  bool _isArabicText(String text) {
    if (text.trim().isEmpty) return false;
    
    // Comprehensive Arabic Unicode ranges
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
    
    // Count Arabic characters vs total characters
    final arabicChars = text.split('').where((char) => arabicRegex.hasMatch(char)).length;
    final totalChars = text.replaceAll(RegExp(r'\s'), '').length;
    
    // If more than 30% of characters are Arabic, consider it Arabic text
    if (totalChars == 0) return false;
    final arabicRatio = arabicChars / totalChars;
    
    debugPrint('Text: "$text" | Arabic chars: $arabicChars / $totalChars | Ratio: ${arabicRatio.toStringAsFixed(2)}');
    
    return arabicRatio > 0.3;
  }

  /// Translates Arabic text to English
  Future<String> translateArabicToEnglish(String text) async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      
      // Ensure Arabic and English models are downloaded
      final isArabicDownloaded = await modelManager.isModelDownloaded('ar');
      if (!isArabicDownloaded) {
        debugPrint('Downloading Arabic model...');
        await modelManager.downloadModel('ar');
      }
      
      final isEnglishDownloaded = await modelManager.isModelDownloaded('en');
      if (!isEnglishDownloaded) {
        debugPrint('Downloading English model...');
        await modelManager.downloadModel('en');
      }
      
      // Create translator for Arabic to English
      final translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.arabic,
        targetLanguage: TranslateLanguage.english,
      );
      
      final translated = await translator.translateText(text);
      translator.close();
      return translated;
    } catch (e) {
      debugPrint('Error translating Arabic to English: $e');
      return text;
    }
  }

  /// Translates non-Arabic text to Arabic
  Future<String> translateToArabic(String text) async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      
      // Try to detect source language (default to English)
      // For now, we'll use English as default for non-Arabic text
      // In the future, we could add language detection here
      
      final isEnglishDownloaded = await modelManager.isModelDownloaded('en');
      if (!isEnglishDownloaded) {
        debugPrint('Downloading English model...');
        await modelManager.downloadModel('en');
      }
      
      final isArabicDownloaded = await modelManager.isModelDownloaded('ar');
      if (!isArabicDownloaded) {
        debugPrint('Downloading Arabic model...');
        await modelManager.downloadModel('ar');
      }
      
      // Use default translator (English to Arabic)
      // Note: This assumes non-Arabic text is English
      // For other languages, we'd need to detect and download that model
      final translated = await _translator!.translateText(text);
      return translated;
    } catch (e) {
      debugPrint('Error translating to Arabic: $e');
      return text;
    }
  }
  /// Dispose resources
  void dispose() {
    _translator?.close();
    _translator = null;
    _isInitialized = false;
  }
}
