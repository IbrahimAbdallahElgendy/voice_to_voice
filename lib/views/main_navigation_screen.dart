import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_transscript/injection.dart';
import 'package:voice_transscript/view_model/connectivity_controller.dart';
import 'package:voice_transscript/view_model/navigation_controller.dart';
import 'package:voice_transscript/views/assistant_screen.dart';
import 'package:voice_transscript/views/info_screen.dart';
import 'package:voice_transscript/views/pilgrim_screen.dart';
import 'package:voice_transscript/views/settings_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(sl<NavigationController>());
    
    final List<Widget> screens = [
      const PilgrimScreen(),
      const AssistantScreen(),
      const InfoScreen(),
      const SettingsScreen(),
    ];

    Get.put(sl<ConnectivityController>());
    
    return GetBuilder<NavigationController>(
      builder: (controller) => Scaffold(
        body: screens[controller.currentIndex],
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // WiFi status and offline button - positioned above navigation
            GetBuilder<ConnectivityController>(
              builder: (connectivityController) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      connectivityController.isConnected
                          ? Icons.wifi
                          : Icons.wifi_off,
                      color: connectivityController.isConnected
                          ? Colors.green
                          : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      connectivityController.isConnected
                          ? 'Connected'
                          : 'Disconnected',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: connectivityController.isConnected
                          ? () {
                              print('Go Offline button pressed');
                            }
                          : null, // Disable when disconnected
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ).copyWith(
                        backgroundColor: connectivityController.isConnected
                            ? MaterialStateProperty.all(Colors.blue)
                            : MaterialStateProperty.all(Colors.grey),
                      ),
                      child: const Text('Go Offline'),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Navigation Bar
            BottomNavigationBar(
              currentIndex: controller.currentIndex,
              onTap: (index) => controller.changeTab(index),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Pilgrim',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: 'Assistant',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.info),
                  label: 'Info',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

