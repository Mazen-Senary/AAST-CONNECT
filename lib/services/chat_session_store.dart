class ChatSessionStore<T> {
  final Map<String, List<T>> _messagesBySession = {};
  final Map<String, String> _contextBySession = {};
  final Map<String, DateTime> _contextFetchedAtBySession = {};

  List<T>? messagesFor(String sessionKey) {
    return _messagesBySession[sessionKey];
  }

  void setMessages(String sessionKey, List<T> messages) {
    _messagesBySession[sessionKey] = messages;
  }

  void addMessage(String sessionKey, T message) {
    _messagesBySession.putIfAbsent(sessionKey, () => []).add(message);
  }

  String? contextFor(String sessionKey, Duration ttl, DateTime now) {
    final context = _contextBySession[sessionKey];
    final fetchedAt = _contextFetchedAtBySession[sessionKey];
    if (context == null || fetchedAt == null) return null;
    if (now.difference(fetchedAt) >= ttl) return null;
    return context;
  }

  void setContext(String sessionKey, String context, DateTime fetchedAt) {
    _contextBySession[sessionKey] = context;
    _contextFetchedAtBySession[sessionKey] = fetchedAt;
  }

  void invalidateContext(String sessionKey) {
    _contextBySession.remove(sessionKey);
    _contextFetchedAtBySession.remove(sessionKey);
  }

  void clearSession(String sessionKey) {
    _messagesBySession.remove(sessionKey);
    invalidateContext(sessionKey);
  }
}
