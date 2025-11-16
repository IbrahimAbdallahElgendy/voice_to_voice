import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_transscript/core/services/tts_service.dart';
import 'package:voice_transscript/injection.dart';
import 'package:voice_transscript/models/language_model.dart';
import 'package:voice_transscript/view_model/connectivity_controller.dart';
import 'package:voice_transscript/view_model/pilgrim_controller.dart';
import 'widgets/language_button.dart';

// Helper function to detect Arabic text
bool _isArabicText(String text) {
  final arabicRegex = RegExp(r'[\u0600-\u06FF]');
  return arabicRegex.hasMatch(text);
}

class PilgrimScreen extends StatelessWidget {
  const PilgrimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(sl<PilgrimController>());
    Get.put(sl<ConnectivityController>());
    final ttsService = sl<TTSService>();

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: const Text('Ihuda\nإهدى'),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Language selector with auto-detection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GetBuilder<PilgrimController>(
              builder:
                  (controller) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Source language button (selectable)
                      Expanded(
                        child: LanguageButton(
                          language: controller.detectedSourceLanguage,
                          onTap:
                              () => _showLanguageSelector(
                                context,
                                controller,
                                isSource: true,
                              ),
                          isAutoDetected: false, // Auto-detection disabled
                          // isAutoDetected: controller.isAutoDetectingSource, // COMMENTED OUT
                        ),
                      ),
                      // Swap button
                      IconButton(
                        icon: const Icon(Icons.swap_horiz),
                        onPressed: () => controller.swapLanguages(),
                        iconSize: 32,
                      ),
                      // Target language button (selectable)
                      Expanded(
                        child: LanguageButton(
                          language: controller.targetLanguage,
                          onTap:
                              () => _showLanguageSelector(
                                context,
                                controller,
                                isSource: false,
                              ),
                          isAutoDetected: false,
                        ),
                      ),
                    ],
                  ),
            ),
          ),

          // Show last translation or current recording
          Expanded(
            child: GetBuilder<PilgrimController>(
              builder: (controller) {
                // Show current recording if active
                if (controller.currentWords.isNotEmpty) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
                        // You said card - white background
                        Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'You said:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        controller.currentWords,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.volume_up),
                                      onPressed: () {
                                        // Auto-detect language for TTS
                                        final isArabic = _isArabicText(
                                          controller.currentWords,
                                        );
                                        ttsService.speak(
                                          controller.currentWords,
                                          languageCode: isArabic ? 'ar' : 'en',
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Translation card - blue background
                        if (controller.currentTranslated.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Card(
                              color: Colors.blue,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Translation:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            controller.currentTranslated,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.volume_up,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            // Auto-detect language for TTS
                                            final isArabic = _isArabicText(
                                              controller.currentTranslated,
                                            );
                                            ttsService.speak(
                                              controller.currentTranslated,
                                              languageCode:
                                                  isArabic ? 'ar' : 'en',
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                // Show last message if exists
                if (controller.messages.isNotEmpty) {
                  final lastMessage = controller.messages.last;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
                        // You said card - white background
                        Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'You said:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        lastMessage.originalText,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.volume_up),
                                      onPressed: () {
                                        // Auto-detect language for TTS
                                        final isArabic = _isArabicText(
                                          lastMessage.originalText,
                                        );
                                        ttsService.speak(
                                          lastMessage.originalText,
                                          languageCode: isArabic ? 'ar' : 'en',
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Translation card - blue background
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Card(
                            color: Colors.blue,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Translation:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          lastMessage.translatedText,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.volume_up,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          // Auto-detect language for TTS
                                          final isArabic = _isArabicText(
                                            lastMessage.translatedText,
                                          );
                                          ttsService.speak(
                                            lastMessage.translatedText,
                                            languageCode:
                                                isArabic ? 'ar' : 'en',
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Empty state
                return GetBuilder<PilgrimController>(
                  builder:
                      (controller) => Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!controller.speechEnabled)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    'Microphone permission is needed.\nPlease enable it in Settings.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              Text(
                                controller.speechEnabled
                                    ? 'No messages yet. Tap the microphone to start.'
                                    : 'No messages yet. Tap the microphone to start.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                );
              },
            ),
          ),

          // Voice button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: GetBuilder<PilgrimController>(
              builder: (controller) {
                return InkWell(
                  onTap: () async {
                    if (controller.speechEnabled) {
                      debugPrint(
                        'Voice button tapped. speechEnabled: ${controller.speechEnabled}',
                      );
                      await controller.toggleListening();
                    } else {
                      debugPrint(
                        'Voice button tapped but speech is not enabled. Attempting to re-initialize...',
                      );
                      // Try to re-initialize speech recognition
                      await controller.reinitializeSpeech();
                      // If still not enabled, try to toggle anyway (might trigger permission request)
                      if (controller.speechEnabled) {
                        await controller.toggleListening();
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(60),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color:
                          controller.speechEnabled ? Colors.blue : Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (controller.speechEnabled
                                  ? Colors.blue
                                  : Colors.grey)
                              .withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      controller.isListening ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
          ),

          // Dynamic text based on state
          GetBuilder<PilgrimController>(
            builder: (controller) {
              String statusText;
              if (controller.isTranslating) {
                statusText = 'Translating your speech...';
              } else if (controller.isListening) {
                statusText = 'Listening';
              } else if (controller.messages.isNotEmpty) {
                statusText = 'Tap to record again';
              } else {
                statusText = 'Press to Talk';
              }

              return Text(
                statusText,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showLanguageSelector(
    BuildContext context,
    PilgrimController controller, {
    required bool isSource,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSource
                      ? 'Select Source Language'
                      : 'Select Target Language',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Auto-detect option - HIDDEN
                        // if (isSource)
                        //   ListTile(
                        //     leading: const Icon(Icons.auto_awesome, color: Colors.blue),
                        //     title: const Text('Auto-detect'),
                        //     subtitle: const Text('Automatically detect from speech'),
                        //     onTap: () {
                        //       controller.enableAutoDetection();
                        //       Navigator.pop(context);
                        //     },
                        //     tileColor: controller.isAutoDetectingSource
                        //         ? Colors.blue.shade100
                        //         : null,
                        //   ),
                        ...Languages.all.map(
                          (language) => ListTile(
                            leading: Text(
                              language.flag,
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(language.name),
                            onTap: () {
                              if (isSource) {
                                controller.setSourceLanguage(language);
                              } else {
                                controller.setTargetLanguage(language);
                              }
                              Navigator.pop(context);
                            },
                            tileColor:
                                (isSource
                                        ? controller
                                                .detectedSourceLanguage
                                                .code ==
                                            language.code
                                        : controller.targetLanguage.code ==
                                            language.code)
                                    ? Colors.blue.shade100
                                    : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
    );
  }
}
