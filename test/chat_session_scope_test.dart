import 'package:aast_connect/services/chat_session_scope.dart';
import 'package:aast_connect/services/user_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    UserSession.instance.clear();
  });

  test('builds a different chat session key for different users', () {
    UserSession.instance
      ..userId = 1
      ..studentId = 1
      ..role = 'STUDENT'
      ..collegeId = 'STD2023001';

    final firstKey = ChatSessionScope.currentKey();

    UserSession.instance
      ..userId = 7
      ..studentId = null
      ..role = 'FRESH_GRAD'
      ..collegeId = 'FG2023007';

    final secondKey = ChatSessionScope.currentKey();

    expect(firstKey, isNot(secondKey));
    expect(ChatSessionScope.hasChanged(firstKey, secondKey), isTrue);
  });
}
