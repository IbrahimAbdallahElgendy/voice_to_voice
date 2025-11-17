import 'package:elevenlabs_agents/elevenlabs_agents.dart';
import 'package:flutter/material.dart';

class ElevenLabsAgentService {
  static const String agentId =
      'agent_9701ka60vka0fkx8mf1sw80yzd5b'; // TODO: fetch from API
  late ConversationClient _client;

  ElevenLabsAgentService({ConversationCallbacks? callbacks}) {
    _client = ConversationClient(
      clientTools: {'logMessage': LogMessageTool()},
      callbacks: callbacks ?? ConversationCallbacks(),
    );
  }

  Future<void> startSession({String userId = 'demo-user'}) async {
    await _client.startSession(agentId: agentId, userId: userId);
  }

  Future<void> endSession() async {
    await _client.endSession();
  }

  Future<void> sendUserMessage(String text) async {
    _client.sendUserMessage(text);
  }

  Future<void> sendContextualUpdate(String text) async {
    _client.sendContextualUpdate(text);
  }

  Future<void> toggleMute() async {
    await _client.toggleMute();
  }

  bool get isConnected => _client.status == ConversationStatus.connected;
  bool get isSpeaking => _client.isSpeaking;
  bool get isMuted => _client.isMuted;
  bool get canSendFeedback => _client.canSendFeedback;
  String? get conversationId => _client.conversationId;
  ConversationStatus get status => _client.status;
}

class LogMessageTool implements ClientTool {
  @override
  Future<ClientToolResult?> execute(Map<String, dynamic> parameters) async {
    final message = parameters['message'] as String?;
    if (message == null || message.isEmpty) {
      return ClientToolResult.failure('Missing or empty message parameter');
    }
    debugPrint('📢 Agent Tool Call - Log Message: $message');
    return null;
  }
}
