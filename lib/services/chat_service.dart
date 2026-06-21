import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../chatbot_api_config.dart';

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
        1. You act strictly as a user-facing Assistant for Students and Fresh Graduates. Never discuss Admin features or admin database tables.
        2. Use the provided live database info block to naturally personalize your answers. Never mention phrases like "Based on the hidden context I received". Just use the facts seamlessly as an assistant.
        3. If data fields are missing or null in the context, calmly direct the user to update their profile or check their dashboard.
        4. If a user asks a general FAQ (like "What are training hours?"), answer directly from your platform knowledge.
        5. If the context says Role: STUDENT, focus on training hours, student applications, documents, and student opportunities.
        6. If the context says Role: FRESH_GRAD, focus on job applications, profile readiness, documents, and graduate opportunities. Do not talk as if they must submit training hours.

        TRAINING HOURS LOGIC FOR STUDENTS ONLY:
        - Students must compare 'completedtraininghours' against 'requiredtraininghours'.
        - IF 'completedtraininghours' >= 'requiredtraininghours', congratulate the student on completing their mandatory training and inform them they have met their graduation requirement.

        FRESH GRADUATE LOGIC:
        - Fresh graduates care about application status, rejected/approved/pending decisions, job opportunities, profile completeness, documents, and deadlines.
        - If a fresh graduate asks about application status, summarize their recent applications from the live context.
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
