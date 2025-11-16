import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_transscript/view_model/pilgrim_controller.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({
    super.key,
    required this.controller,
  });

  final PilgrimController controller;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PilgrimController>(
      init: controller,
      builder: (controller) {
        if (!controller.speechEnabled) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Speech recognition not available. Check microphone permissions.',
              textAlign: TextAlign.center,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                controller.isListening ? Icons.mic : Icons.mic_off,
                color: controller.isListening
                    ? Colors.redAccent
                    : Colors.grey.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.isListening
                      ? 'Listening... tap stop when you are done.'
                      : 'Tap "Record Voice" to start a new message.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

