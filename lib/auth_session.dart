class AuthSession {
  static String? collegeId;
  static String? role;
  static String? password;
  static String? token;

  static void set(String id, String r, String p, String t) {
    collegeId = id;
    role = r;
    password = p;
    token = t;
  }

  static void clear() {
    collegeId = null;
    role = null;
    password = null;
    token = null;
  }
}
