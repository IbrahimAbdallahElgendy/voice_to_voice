import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_transscript/injection.dart';
import 'package:voice_transscript/view_model/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final SplashController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        Get.isRegistered<SplashController>()
            ? Get.find<SplashController>()
            : Get.put(sl<SplashController>());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: _controller,
      builder: (controller) {
        return Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              // Background SVG image
              Positioned.fill(
                child: Image.asset(
                  "assets/images/splashBg.png",
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
