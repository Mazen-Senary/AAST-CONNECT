/// Singleton that holds the currently logged-in user's data.
///
/// Populated by [SignInScreen] after a successful login and read by every
/// screen that used to hard-code `userId = 5`.
class UserSession {
  static final UserSession _instance = UserSession._();
  static UserSession get instance => _instance;
  UserSession._();

  int? userId;
  String? name;
  String? role; // 'STUDENT', 'FRESH_GRAD', 'ADMIN'
  String? collegeId;

  bool get isLoggedIn => userId != null;

  /// Call on logout to wipe session data.
  void clear() {
    userId = null;
    name = null;
    role = null;
    collegeId = null;
  }
}
