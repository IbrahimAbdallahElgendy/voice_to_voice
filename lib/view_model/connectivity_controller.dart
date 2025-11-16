import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  bool isConnected = false;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _checkConnectivity();
  }

  Future<void> _initConnectivity() async {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _updateConnectionStatus(results);
      },
    );
  }

  Future<void> _checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Check if any of the connectivity results indicate internet access
    final hasConnection = results.any((result) => 
      result != ConnectivityResult.none
    );
    if (isConnected != hasConnection) {
      isConnected = hasConnection;
      update();
    }
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}

