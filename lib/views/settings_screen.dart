import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_transscript/injection.dart';
import 'package:voice_transscript/view_model/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(sl<SettingsController>());
    
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
          'Settings',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}

