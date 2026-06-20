// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../services/chat_service.dart';
//
// class CachedChatProvider extends ChangeNotifier {
//   final ChatService _chatService = ChatService();
//   final _supabase = Supabase.instance.client;
//
//   // Cache variables
//   String? _cachedContext;
//   DateTime? _lastFetched;
//   static const Duration _cacheDuration = Duration(minutes: 5);
//
//   final List<ChatMessage> _messages = [
//     ChatMessage(text: "Hi! I'm your AAST Connect Assistant. How can I help?", isUser: false)
//   ];
//
//   bool _isLoading = false;
//   List<ChatMessage> get messages => _messages;
//   bool get isLoading => _isLoading;
//
//   // PUBLIC: Call this after any DB change (e.g., submitting hours)
//   void invalidateCache() {
//     _cachedContext = null;
//     _lastFetched = null;
//     debugPrint("Cache invalidated: Next fetch will be fresh from Supabase.");
//   }
//
//   Future<String> _buildUserContext() async {
//     // 1. Check Cache
//     if (_cachedContext != null &&
//         _lastFetched != null &&
//         DateTime.now().difference(_lastFetched!) < _cacheDuration) {
//       debugPrint("Using Cached Data");
//       return _cachedContext!;
//     }
//
//     // 2. Otherwise Fetch Fresh
//     try {
//       debugPrint("Fetching Fresh Data from Supabase");
//       const int userId = 5;
//       final userData = await _supabase.from('users').select('name, role').eq('userid', userId).single();
//
//       String contextString = "User Name: ${userData['name']}\nRole: ${userData['role']}\n";
//       // ... (Rest of your fetch logic here) ...
//
//       _cachedContext = contextString;
//       _lastFetched = DateTime.now();
//       return _cachedContext!;
//     } catch (e) {
//       return "System Error: Could not refresh context.";
//     }
//   }
//
//   Future<void> sendMessage(String text) async {
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
// class ChatMessage {
//   final String text;
//   final bool isUser;
//   ChatMessage({required this.text, required this.isUser});
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/chat_service.dart';
import '../services/user_session.dart';

// 1. Define the ChatMessage model right here to prevent import errors
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

// 2. The Smart, Cached Provider
class CachedChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final _supabase = Supabase.instance.client;

  // Cache variables
  String? _cachedContext;
  DateTime? _lastFetched;
  static const Duration _cacheDuration = Duration(minutes: 5);

  final List<ChatMessage> _messages = [
    ChatMessage(
        text: "Hi! I'm your AAST Connect Assistant. How can I help you today?",
        isUser: false
    )
  ];

  bool _isLoading = false;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  // PUBLIC: Call this after any DB change (like submitting hours)
  void invalidateCache() {
    _cachedContext = null;
    _lastFetched = null;
    debugPrint("Cache invalidated: Next fetch will be fresh from Supabase.");
  }

  Future<String> _buildUserContext() async {
    // 1. Check Cache First
    if (_cachedContext != null &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < _cacheDuration) {
      debugPrint("Using Cached Database Context");
      return _cachedContext!;
    }

    // 2. Fetch Fresh Data (The "Smart" Part)
    try {
      debugPrint("Fetching Fresh Data from Supabase");

      // Use logged-in user's ID from UserSession
      final int userId = UserSession.instance.userId ?? 0;

      // --- FETCH USER INFO ---
      final userData = await _supabase
          .from('users')
          .select('userid, name, role')
          .eq('userid', userId)
          .maybeSingle();

      if (userData == null) return "System Error: Could not find user with ID $userId";

      final String role = userData['role'];
      final String name = userData['name'];

      String contextString = "User Name: $name\nRole: $role\n";

      // --- FETCH TRAINING HOURS ---
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

      // --- FETCH RECENT APPLICATIONS ---
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

      // --- FETCH AVAILABLE OPPORTUNITIES ---
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

      // 3. Save to Cache
      _cachedContext = contextString;
      _lastFetched = DateTime.now();

      return _cachedContext!;
    } catch (e) {
      debugPrint("Error fetching context: $e");
      return "Could not fetch live database context.";
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