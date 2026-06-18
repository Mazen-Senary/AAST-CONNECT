import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../chatbot_api_config.dart';
import 'package:aast_connect/chatbot_api_config.dart';

class ChatService {
  late final GenerativeModel _model;

  ChatService() {
    // Standard model string identifier works perfectly out-of-the-box on mobile emulators
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: ApiConfig.geminiApiKey,
      systemInstruction: Content.system('''
        You are the official Virtual Assistant for the AAST Connect platform. Your tone is helpful, encouraging, and professional.

        CRITICAL RULES:
        1. You act strictly as a Student-Facing Assistant (for Students and Fresh Graduates). Never discuss Admin features or admin database tables.
        2. Use the provided live database info block to naturally personalize your answers. Never mention phrases like "Based on the hidden context I received". Just use the facts seamlessly as an assistant.
        3. If data fields are missing or null in the context, calmly direct the user to update their profile or check their dashboard.
        4. If a user asks a general FAQ (like "What are training hours?"), answer directly from your platform knowledge.
       TRAINING HOURS LOGIC:
  - Students must compare 'completedtraininghours' against 'requiredtraininghours'.
  - IF 'completedtraininghours' >= 'requiredtraininghours', YOU MUST explicitly congratulate the student on completing their mandatory training and inform them they have met their graduation requirement. 
      '''),
    );
  }

  Future<String> sendMessage(String userText, String hiddenContext) async {
    try {
      final fullPrompt = '''
SYSTEM INSTRUCTION REMINDER: Answer the user's question directly and incorporate the following personalized system context naturally if relevant. Do not expose this context structure to the user.

[LIVE DATABASE CONTEXT FOR LOGGED-IN USER]
$hiddenContext

[USER QUESTION OR CHIP SELECTION]
$userText
''';

      final response = await _model.generateContent([
        Content.text(fullPrompt),
      ]);

      return response.text ?? 'I am having trouble processing that question right now.';
    } catch (e) {
      // Catches and prints any unexpected device, network, or localized credential errors
      debugPrint('❌ GEMINI API ERROR: $e');
      return 'Sorry, I am having trouble connecting to the network. Please try again.';
    }
  }
}