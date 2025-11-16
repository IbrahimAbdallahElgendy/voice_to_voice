import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voice_transscript/views/main_navigation_screen.dart';

class SplashController extends GetxController {
  SplashController();
  static const platform = MethodChannel('com.MilaCompany.Mila/deepLink');
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void onInit() {
    log("SplashController: OnInit()");
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint("SplashController: onReady()");
    _navigateToHome();
  }

  void _navigateToHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute != '/MainNavigationScreen') {
        Get.offAll(() => const MainNavigationScreen());
      }
    });
  }
}
