import 'user_session.dart';

class ChatSessionScope {
  static String currentKey() {
    final session = UserSession.instance;
    return [
      session.role ?? 'ANONYMOUS',
      session.userId?.toString() ?? 'none',
      session.studentId?.toString() ?? 'none',
      session.collegeId ?? 'none',
    ].join(':');
  }

  static bool hasChanged(String? previousKey, String currentKey) {
    return previousKey != currentKey;
  }
}
