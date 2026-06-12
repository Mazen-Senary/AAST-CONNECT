// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../services/chat_service.dart';
//
// class ChatMessage {
//   final String text;
//   final bool isUser;
//   ChatMessage({required this.text, required this.isUser});
// }
//
// class ChatProvider extends ChangeNotifier {
//   final ChatService _chatService = ChatService();
//   final _supabase = Supabase.instance.client;
//
//   final List<ChatMessage> _messages = [
//     ChatMessage(
//         text: "Hi! I'm your AAST Connect Assistant. You can ask me about training hours, applications, documents, or your current status.",
//         isUser: false
//     )
//   ];
//
//   bool _isLoading = false;
//
//   List<ChatMessage> get messages => _messages;
//   bool get isLoading => _isLoading;
//
//   Future<String> _buildUserContext() async {
//     try {
//       final user = _supabase.auth.currentUser;
//       if (user == null) return "User is not logged in.";
//
//       // 1. Get user role and basic info
//       final userData = await _supabase
//           .from('users')
//           .select('userid, name, role')
//           .eq('email', user.email!)
//           .single();
//
//       final int userId = userData['userid'];
//       final String role = userData['role'];
//       final String name = userData['name'];
//
//       String contextString = "User Name: $name\nRole: $role\n";
//
//       // 2. Fetch specific data if they are a student
//       if (role == 'STUDENT') {
//         final studentData = await _supabase
//             .from('student')
//             .select('completedtraininghours, requiredtraininghours')
//             .eq('studentid', userId)
//             .maybeSingle(); // maybeSingle handles cases where profile might not be fully complete
//
//         if (studentData != null) {
//           contextString += "Required Training Hours: ${studentData['requiredtraininghours']}\n";
//           contextString += "Completed Training Hours: ${studentData['completedtraininghours']}\n";
//         }
//       }
//
//       // 3. Fetch recent applications
//       final applications = await _supabase
//           .from('application')
//           .select('status, vacancies(title)')
//           .eq('applicantid', userId)
//           .order('submissiondate', ascending: false)
//           .limit(3);
//
//       if (applications.isNotEmpty) {
//         contextString += "Recent Applications:\n";
//         for (var app in applications) {
//           final title = app['vacancies']?['title'] ?? 'Unknown Vacancy';
//           final status = app['status'];
//           contextString += "- $title: $status\n";
//         }
//       } else {
//         contextString += "Recent Applications: None yet.\n";
//       }
//
//       // 4. Fetch latest relevant vacancies
//       final audienceFilter = (role == 'STUDENT') ? ['STUDENT', 'BOTH'] : ['GRADUATE', 'BOTH'];
//       final latestVacancies = await _supabase
//           .from('vacancies')
//           .select('title, type, company_name')
//           .inFilter('target_audience', audienceFilter)
//           .order('created_at', ascending: false)
//           .limit(3);
//
//       if (latestVacancies.isNotEmpty) {
//         contextString += "\nLatest Available Opportunities For This User:\n";
//         for (var job in latestVacancies) {
//           contextString += "- ${job['title']} at ${job['company_name']} (${job['type']})\n";
//         }
//       }
//
//       return contextString;
//     } catch (e) {
//       debugPrint("Error fetching context: $e");
//       return "Could not fetch live database context.";
//     }
//   }
//
//   Future<void> sendMessage(String text) async {
//     if (text.trim().isEmpty) return;
//
//     _messages.add(ChatMessage(text: text, isUser: true));
//     _isLoading = true;
//     notifyListeners();
//
//     final hiddenContext = await _buildUserContext();
//     final response = await _chatService.sendMessage(text, hiddenContext);
//
//     _messages.add(ChatMessage(text: response, isUser: false));
//     _isLoading = false;
//     notifyListeners();
//   }
// }


import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/chat_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final _supabase = Supabase.instance.client;

  final List<ChatMessage> _messages = [
    ChatMessage(
        text: "Hi! I'm your AAST Connect Assistant. How can I help you today?",
        isUser: false
    )
  ];

  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<String> _buildUserContext() async {
    try {
      // DEMO MODE: Hardcoded User ID 5
      const int userId = 5;

      // 1. Fetch user info using the hardcoded ID directly
      final userData = await _supabase
          .from('users')
          .select('userid, name, role')
          .eq('userid', userId)
          .maybeSingle();

      if (userData == null) return "System Error: Could not find user with ID $userId";

      final String role = userData['role'];
      final String name = userData['name'];

      String contextString = "User Name: $name\nRole: $role\n";

      // 2. Fetch specific data if they are a student
      if (role == 'STUDENT') {
        final studentData = await _supabase
            .from('student')
            .select('completedtraininghours, requiredtraininghours')
            .eq('studentid', userId)
            .maybeSingle();

        if (studentData != null) {
          contextString += "Required Training Hours: ${studentData['requiredtraininghours']}\n";
          contextString += "Completed Training Hours: ${studentData['completedtraininghours']}\n";
        }
      }

      // 3. Fetch recent applications
      final applications = await _supabase
          .from('application')
          .select('status, vacancies(title)')
          .eq('applicantid', userId)
          .order('submissiondate', ascending: false)
          .limit(3);

      if (applications.isNotEmpty) {
        contextString += "Recent Applications:\n";
        for (var app in applications) {
          final vacancy = app['vacancies'];
          final title = (vacancy != null && vacancy is Map) ? vacancy['title'] : 'Unknown Vacancy';
          final status = app['status'];
          contextString += "- $title: $status\n";
        }
      } else {
        contextString += "Recent Applications: None yet.\n";
      }

      // 4. Fetch latest relevant vacancies
      final audienceFilter = (role == 'STUDENT') ? ['STUDENT', 'BOTH'] : ['GRADUATE', 'BOTH'];
      final latestVacancies = await _supabase
          .from('vacancies')
          .select('title, type, company_name')
          .inFilter('target_audience', audienceFilter)
          .order('created_at', ascending: false)
          .limit(3);

      if (latestVacancies.isNotEmpty) {
        contextString += "\nLatest Available Opportunities For This User:\n";
        for (var job in latestVacancies) {
          contextString += "- ${job['title']} at ${job['company_name']} (${job['type']})\n";
        }
      }

      return contextString;
    } catch (e) {
      debugPrint("Error fetching context: $e");
      return "Could not fetch live database context for this test user.";
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text, isUser: true));
    _isLoading = true;
    notifyListeners();

    final hiddenContext = await _buildUserContext();
    final response = await _chatService.sendMessage(text, hiddenContext);

    _messages.add(ChatMessage(text: response, isUser: false));
    _isLoading = false;
    notifyListeners();
  }
}