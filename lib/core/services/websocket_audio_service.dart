import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:voice_transscript/models/app_config.dart';

enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

class WebSocketAudioService {
  WebSocketChannel? _channel;
  WebSocketConnectionState _connectionState = WebSocketConnectionState.disconnected;
  String? _sessionId;
  Timer? _reconnectTimer;
  bool _shouldReconnect = false;
  StreamController<WebSocketConnectionState>? _stateController;

  WebSocketConnectionState get connectionState => _connectionState;
  String? get sessionId => _sessionId;
  
  Stream<WebSocketConnectionState> get connectionStateStream {
    _stateController ??= StreamController<WebSocketConnectionState>.broadcast();
    return _stateController!.stream;
  }

  /// Connect to WebSocket server
  Future<void> connect({String? sessionId}) async {
    if (_connectionState == WebSocketConnectionState.connected ||
        _connectionState == WebSocketConnectionState.connecting) {
      log('WebSocket already connected or connecting');
      return;
    }

    try {
      _updateConnectionState(WebSocketConnectionState.connecting);
      _sessionId = sessionId;
      
      // Get WebSocket URL from AppConfig
      final baseUrl = AppConfig.shared.baseUrl;
      if (baseUrl.isEmpty) {
        throw Exception('Base URL not configured');
      }

      // Convert HTTP/HTTPS URL to WebSocket URL
      String wsUrl = baseUrl.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
      if (!wsUrl.endsWith('/')) {
        wsUrl += '/';
      }
      wsUrl += 'api/v1/audio/stream';

      log('Connecting to WebSocket: $wsUrl');
      
      try {
        _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
        
        // Connection is established, update state
        _updateConnectionState(WebSocketConnectionState.connected);
        _shouldReconnect = true;
        _initializeSession();

        // Listen for messages
        _channel!.stream.listen(
          (message) {
            _handleMessage(message);
          },
          onError: (error) {
            log('WebSocket stream error: $error');
            _updateConnectionState(WebSocketConnectionState.error);
            _scheduleReconnect();
          },
          onDone: () {
            log('WebSocket connection closed');
            _updateConnectionState(WebSocketConnectionState.disconnected);
            if (_shouldReconnect) {
              _scheduleReconnect();
            }
          },
          cancelOnError: false,
        );
      } catch (e) {
        log('Error creating WebSocket connection: $e');
        _updateConnectionState(WebSocketConnectionState.error);
        _scheduleReconnect();
      }
    } catch (e) {
      log('Error connecting to WebSocket: $e');
      _updateConnectionState(WebSocketConnectionState.error);
      _scheduleReconnect();
    }
  }

  /// Initialize session with backend
  void _initializeSession() {
    if (_channel == null || _connectionState != WebSocketConnectionState.connected) {
      return;
    }

    try {
      final initMessage = {
        'type': 'init',
        if (_sessionId != null) 'sessionId': _sessionId,
      };
      
      _channel!.sink.add(jsonEncode(initMessage));
      log('Session initialized with sessionId: $_sessionId');
    } catch (e) {
      log('Error initializing session: $e');
    }
  }

  /// Send audio chunk to server
  Future<void> sendAudioChunk(Uint8List audioData, {bool isFinal = false}) async {
    if (_channel == null || _connectionState != WebSocketConnectionState.connected) {
      log('WebSocket not connected, cannot send audio chunk');
      return;
    }

    try {
      // Option 1: Send binary audio data directly
      _channel!.sink.add(audioData);
      
      // Option 2: Send JSON with base64 (commented out, using binary instead)
      // final base64Audio = base64Encode(audioData);
      // final message = {
      //   'type': 'audio',
      //   'data': base64Audio,
      //   'isFinal': isFinal,
      // };
      // _channel!.sink.add(jsonEncode(message));

      if (isFinal) {
        log('Sent final audio chunk');
      } else {
        log('Sent audio chunk: ${audioData.length} bytes');
      }
    } catch (e) {
      log('Error sending audio chunk: $e');
    }
  }

  /// Send final audio chunk with JSON format
  Future<void> sendFinalAudioChunk(Uint8List audioData) async {
    if (_channel == null || _connectionState != WebSocketConnectionState.connected) {
      log('WebSocket not connected, cannot send final audio chunk');
      return;
    }

    try {
      final base64Audio = base64Encode(audioData);
      final message = {
        'type': 'audio',
        'data': base64Audio,
        'isFinal': true,
      };
      _channel!.sink.add(jsonEncode(message));
      log('Sent final audio chunk with JSON format');
    } catch (e) {
      log('Error sending final audio chunk: $e');
    }
  }

  /// Handle incoming messages from server
  void _handleMessage(dynamic message) {
    try {
      if (message is String) {
        final data = jsonDecode(message);
        log('Received message: $data');
        // Handle server responses here if needed
      } else {
        log('Received binary message: ${message.length} bytes');
      }
    } catch (e) {
      log('Error handling message: $e');
    }
  }

  /// Update connection state and notify listeners
  void _updateConnectionState(WebSocketConnectionState newState) {
    if (_connectionState != newState) {
      _connectionState = newState;
      _stateController?.add(newState);
      log('WebSocket state changed to: $newState');
    }
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (!_shouldReconnect) return;
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_shouldReconnect && _connectionState != WebSocketConnectionState.connected) {
        log('Attempting to reconnect WebSocket...');
        connect(sessionId: _sessionId);
      }
    });
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    
    try {
      await _channel?.sink.close();
      _channel = null;
      _updateConnectionState(WebSocketConnectionState.disconnected);
      log('WebSocket disconnected');
    } catch (e) {
      log('Error disconnecting WebSocket: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _stateController?.close();
    _stateController = null;
  }
}

