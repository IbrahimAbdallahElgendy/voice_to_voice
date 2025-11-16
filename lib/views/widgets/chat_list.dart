import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_transscript/view_model/pilgrim_controller.dart';
import 'package:voice_transscript/views/widgets/chat_bubble.dart';

class ChatList extends StatelessWidget {
  const ChatList({
    super.key,
    required this.controller,
  });

  final PilgrimController controller;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PilgrimController>(
      init: controller,
      builder: (controller) {
        final entries = [
          ...controller.messages.map(
            (message) => ChatBubble(
              text: message.translatedText,
              isLive: false,
            ),
          ),
          if (controller.currentWords.isNotEmpty)
            ChatBubble(
              text: controller.currentTranslated.isNotEmpty
                  ? controller.currentTranslated
                  : controller.currentWords,
              isLive: true,
            ),
        ];
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, index) => entries[index],
        );
      },
    );
  }
}

