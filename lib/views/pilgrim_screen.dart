import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_transscript/core/services/tts_service.dart';
import 'package:voice_transscript/core/services/elevenlabs_agent_service.dart';
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

class PilgrimScreen extends StatefulWidget {
  const PilgrimScreen({super.key});

  @override
  State<PilgrimScreen> createState() => _PilgrimScreenState();
}

class _PilgrimScreenState extends State<PilgrimScreen> {
  late PilgrimController _controller;
  late ConnectivityController _connectivityController;
  late TTSService _ttsService;
  ElevenLabsAgentService? _elevenLabsAgentService;
  bool _onlineMode = false;
  bool _isWaitingForAgent = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(sl<PilgrimController>());
    _connectivityController = Get.put(sl<ConnectivityController>());
    _ttsService = sl<TTSService>();
    _updateOnlineMode();
    _connectivityController.addListener(_updateOnlineMode);
    if (_onlineMode) {
      _elevenLabsAgentService = ElevenLabsAgentService();
    }
  }

  @override
  void dispose() {
    _connectivityController.removeListener(_updateOnlineMode);
    super.dispose();
  }

  void _updateOnlineMode() {
    setState(() {
      _onlineMode = _connectivityController.isConnected;
      if (_onlineMode && _elevenLabsAgentService == null) {
        _elevenLabsAgentService = ElevenLabsAgentService();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // Language selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GetBuilder<PilgrimController>(
              builder:
                  (controller) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: LanguageButton(
                          language: controller.detectedSourceLanguage,
                          onTap:
                              () => _showLanguageSelector(
                                context,
                                controller,
                                isSource: true,
                              ),
                          isAutoDetected: false,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.swap_horiz),
                        onPressed: () => controller.swapLanguages(),
                        iconSize: 32,
                      ),
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

          // Main content (translation, messages, etc)
          Expanded(
            child: GetBuilder<PilgrimController>(
              builder: (controller) {
                if (controller.currentWords.isNotEmpty) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
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
                                        final isArabic = _isArabicText(
                                          controller.currentWords,
                                        );
                                        _ttsService.speak(
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
                                            final isArabic = _isArabicText(
                                              controller.currentTranslated,
                                            );
                                            _ttsService.speak(
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
                if (controller.messages.isNotEmpty) {
                  final lastMessage = controller.messages.last;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
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
                                        final isArabic = _isArabicText(
                                          lastMessage.originalText,
                                        );
                                        _ttsService.speak(
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
                                          final isArabic = _isArabicText(
                                            lastMessage.translatedText,
                                          );
                                          _ttsService.speak(
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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_controller.speechEnabled)
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
                          _controller.speechEnabled
                              ? 'No messages yet. Tap the microphone to start.'
                              : 'No messages yet. Tap the microphone to start.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Voice button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: InkWell(
              onTap: () async {
                if (_isWaitingForAgent) return; // prevent duplicate taps

                if (_onlineMode) {
                  // Ensure we show loading while waiting for agent/session
                  if (_elevenLabsAgentService != null &&
                      !_elevenLabsAgentService!.isConnected) {
                    setState(() => _isWaitingForAgent = true);
                    try {
                      await _elevenLabsAgentService!.startSession(
                        userId: 'pilgrim-user',
                      );
                    } catch (e) {
                      debugPrint('Failed to start agent session: $e');
                    } finally {
                      setState(() => _isWaitingForAgent = false);
                    }
                  } else if (_elevenLabsAgentService != null &&
                      _elevenLabsAgentService!.isConnected) {
                    // If already connected, allow ending quickly
                    setState(() => _isWaitingForAgent = true);
                    try {
                      await _elevenLabsAgentService!.endSession();
                    } catch (e) {
                      debugPrint('Failed to end agent session: $e');
                    } finally {
                      setState(() => _isWaitingForAgent = false);
                    }
                  }
                  setState(() {});
                } else {
                  if (_controller.speechEnabled) {
                    // Provide immediate feedback before awaiting
                    setState(() {});
                    await _controller.toggleListening();
                  } else {
                    setState(() {});
                    await _controller.reinitializeSpeech();
                    if (_controller.speechEnabled) {
                      await _controller.toggleListening();
                    }
                  }
                }
              },
              borderRadius: BorderRadius.circular(60),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color:
                      _onlineMode
                          ? (_elevenLabsAgentService?.isConnected ?? false
                              ? Colors.red
                              : Colors.blue)
                          : (_controller.speechEnabled
                              ? Colors.blue
                              : Colors.grey),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_onlineMode
                              ? (_elevenLabsAgentService?.isConnected ?? false
                                  ? Colors.red
                                  : Colors.blue)
                              : (_controller.speechEnabled
                                  ? Colors.blue
                                  : Colors.grey))
                          .withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child:
                    _isWaitingForAgent
                        ? const Center(
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                        )
                        : Icon(
                          _onlineMode
                              ? (_elevenLabsAgentService?.isConnected ?? false
                                  ? Icons.stop
                                  : Icons.mic)
                              : (_controller.isListening
                                  ? Icons.stop
                                  : Icons.mic),
                          color: Colors.white,
                          size: 50,
                        ),
              ),
            ),
          ),

          // Dynamic text based on state
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _onlineMode
                  ? (_elevenLabsAgentService?.isConnected ?? false
                      ? 'Connected to ElevenLabs Agent'
                      : 'Press to Talk (Online)')
                  : (_controller.isTranslating
                      ? 'Translating your speech...'
                      : _controller.isListening
                      ? 'Listening'
                      : _controller.messages.isNotEmpty
                      ? 'Tap to record again'
                      : 'Press to Talk'),
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
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
