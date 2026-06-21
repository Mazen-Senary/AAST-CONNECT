import 'package:supabase_flutter/supabase_flutter.dart';

class StudentIdentityNotFoundException implements Exception {
  final String collegeId;

  const StudentIdentityNotFoundException(this.collegeId);

  @override
  String toString() => 'No user or student found for college ID $collegeId';
}

class StudentSessionData {
  final int userId;
  final int? studentId;
  final String name;
  final String role;
  final String collegeId;

  const StudentSessionData({
    required this.userId,
    required this.studentId,
    required this.name,
    required this.role,
    required this.collegeId,
  });
}

class StudentIdentityService {
  final SupabaseClient _supabase;

  StudentIdentityService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<StudentSessionData> resolveByCollegeId(String collegeId) async {
    final userByCollegeId = await _fetchUserByCollegeId(collegeId);
    final studentByCollegeId = await _fetchStudentByCollegeId(collegeId);

    Map<String, dynamic>? studentByUserId;
    if (userByCollegeId != null && _roleOf(userByCollegeId) == 'STUDENT') {
      studentByUserId = await _fetchStudentById(
        _readInt(userByCollegeId, 'userid'),
      );
    }

    Map<String, dynamic>? linkedUserForStudent;
    if (studentByCollegeId != null) {
      linkedUserForStudent = await _fetchUserById(
        _readInt(studentByCollegeId, 'studentid'),
      );
    }

    return resolveStudentSessionFromRows(
      submittedCollegeId: collegeId,
      userByCollegeId: userByCollegeId,
      studentByCollegeId: studentByCollegeId,
      studentByUserId: studentByUserId,
      linkedUserForStudent: linkedUserForStudent,
    );
  }

  Future<Map<String, dynamic>?> _fetchUserByCollegeId(String collegeId) async {
    final data = await _supabase
        .from('users')
        .select('userid, name, role, college_id')
        .eq('college_id', collegeId)
        .maybeSingle();
    return _asMap(data);
  }

  Future<Map<String, dynamic>?> _fetchUserById(int userId) async {
    final data = await _supabase
        .from('users')
        .select('userid, name, role, college_id')
        .eq('userid', userId)
        .maybeSingle();
    return _asMap(data);
  }

  Future<Map<String, dynamic>?> _fetchStudentByCollegeId(
    String collegeId,
  ) async {
    final data = await _supabase
        .from('student')
        .select('studentid, name, email, college_id')
        .eq('college_id', collegeId)
        .limit(1)
        .maybeSingle();
    return _asMap(data);
  }

  Future<Map<String, dynamic>?> _fetchStudentById(int studentId) async {
    final data = await _supabase
        .from('student')
        .select('studentid, name, email, college_id')
        .eq('studentid', studentId)
        .maybeSingle();
    return _asMap(data);
  }
}

StudentSessionData resolveStudentSessionFromRows({
  required String submittedCollegeId,
  required Map<String, dynamic>? userByCollegeId,
  required Map<String, dynamic>? studentByCollegeId,
  required Map<String, dynamic>? studentByUserId,
  Map<String, dynamic>? linkedUserForStudent,
}) {
  final role = userByCollegeId == null ? null : _roleOf(userByCollegeId);

  if (studentByCollegeId != null &&
      (userByCollegeId == null || role == 'STUDENT')) {
    return _fromStudentRow(
      studentByCollegeId,
      linkedUserForStudent ?? userByCollegeId,
      submittedCollegeId,
    );
  }

  if (userByCollegeId == null) {
    throw StudentIdentityNotFoundException(submittedCollegeId);
  }

  if (role == 'STUDENT' && studentByUserId != null) {
    return _fromStudentRow(studentByUserId, userByCollegeId, submittedCollegeId);
  }

  return StudentSessionData(
    userId: _readInt(userByCollegeId, 'userid'),
    studentId: null,
    name: _readString(userByCollegeId, 'name'),
    role: role ?? _roleOf(userByCollegeId),
    collegeId: _readString(userByCollegeId, 'college_id', submittedCollegeId),
  );
}

StudentSessionData _fromStudentRow(
  Map<String, dynamic> student,
  Map<String, dynamic>? linkedUser,
  String submittedCollegeId,
) {
  final studentId = _readInt(student, 'studentid');
  final name = _readString(
    student,
    'name',
    linkedUser == null ? '' : _readString(linkedUser, 'name'),
  );

  return StudentSessionData(
    userId: studentId,
    studentId: studentId,
    name: name,
    role: 'STUDENT',
    collegeId: _readString(student, 'college_id', submittedCollegeId),
  );
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value == null) return null;
  return Map<String, dynamic>.from(value as Map);
}

String _roleOf(Map<String, dynamic> row) {
  final role = _readString(row, 'role', 'STUDENT').toUpperCase();
  return role.isEmpty ? 'STUDENT' : role;
}

int _readInt(Map<String, dynamic> row, String key) {
  final value = row[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.parse(value.toString());
}

String _readString(
  Map<String, dynamic> row,
  String key, [
  String fallback = '',
]) {
  final value = row[key];
  if (value == null) return fallback;
  final text = value.toString();
  return text.isEmpty ? fallback : text;
}
