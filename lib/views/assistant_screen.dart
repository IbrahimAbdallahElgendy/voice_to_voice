import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_transscript/injection.dart';
import 'package:voice_transscript/view_model/assistant_controller.dart';

class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(sl<AssistantController>());
    
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
      body: Center(
        child: Text(
          'Assistant',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}

