import 'package:aast_connect/services/chat_session_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps messages and cached context isolated per session key', () {
    final store = ChatSessionStore<String>();
    final now = DateTime(2026, 6, 21, 12);
    const ttl = Duration(minutes: 5);

    store.addMessage('STUDENT:1', 'student message');
    store.addMessage('FRESH_GRAD:2', 'fresh grad message');
    store.setContext('STUDENT:1', 'student context', now);
    store.setContext('FRESH_GRAD:2', 'fresh grad context', now);

    expect(store.messagesFor('STUDENT:1'), ['student message']);
    expect(store.messagesFor('FRESH_GRAD:2'), ['fresh grad message']);
    expect(store.contextFor('STUDENT:1', ttl, now), 'student context');
    expect(store.contextFor('FRESH_GRAD:2', ttl, now), 'fresh grad context');
  });

  test('expires cached context by ttl without deleting chat messages', () {
    final store = ChatSessionStore<String>();
    final now = DateTime(2026, 6, 21, 12);
    const ttl = Duration(minutes: 5);

    store.addMessage('STUDENT:1', 'student message');
    store.setContext('STUDENT:1', 'student context', now);

    expect(
      store.contextFor('STUDENT:1', ttl, now.add(const Duration(minutes: 6))),
      isNull,
    );
    expect(store.messagesFor('STUDENT:1'), ['student message']);
  });

  test('clears one session without touching other sessions', () {
    final store = ChatSessionStore<String>();

    store.addMessage('STUDENT:1', 'student message');
    store.addMessage('FRESH_GRAD:2', 'fresh grad message');
    store.clearSession('STUDENT:1');

    expect(store.messagesFor('STUDENT:1'), isNull);
    expect(store.messagesFor('FRESH_GRAD:2'), ['fresh grad message']);
  });
}
