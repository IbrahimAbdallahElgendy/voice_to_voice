import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_transscript/view_model/pilgrim_controller.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.controller,
  });

  final PilgrimController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetBuilder<PilgrimController>(
      init: controller,
      builder: (controller) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            controller.speechEnabled
                ? 'Tap "Record Voice" and start speaking. Your transcript will appear like a chat bubble.'
                : 'Microphone permission is needed to start recording. Please enable it in system settings.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}

