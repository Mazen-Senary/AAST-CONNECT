import 'package:aast_connect/services/student_identity_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveStudentSessionFromRows', () {
    test('prefers the student row that matches the submitted college id', () {
      final session = resolveStudentSessionFromRows(
        submittedCollegeId: 'STD2023001',
        userByCollegeId: {
          'userid': 3,
          'name': 'Aly Ahmed',
          'role': 'STUDENT',
          'college_id': 'STD2023001',
        },
        studentByCollegeId: {
          'studentid': 1,
          'name': 'Ahmed Hassan',
          'email': 'ahmed@example.com',
          'college_id': 'STD2023001',
        },
        studentByUserId: {
          'studentid': 3,
          'name': 'Aly Ahmed',
          'email': 'aly@example.com',
          'college_id': 'STD2023003',
        },
      );

      expect(session.role, 'STUDENT');
      expect(session.userId, 1);
      expect(session.studentId, 1);
      expect(session.name, 'Ahmed Hassan');
      expect(session.collegeId, 'STD2023001');
    });

    test('allows student login when the id exists only in the student table', () {
      final session = resolveStudentSessionFromRows(
        submittedCollegeId: 'STD2023003',
        userByCollegeId: null,
        studentByCollegeId: {
          'studentid': 3,
          'name': 'Aly Ahmed',
          'email': 'aly@example.com',
          'college_id': 'STD2023003',
        },
        studentByUserId: null,
        linkedUserForStudent: {
          'userid': 3,
          'name': 'Different Users Name',
          'role': 'STUDENT',
          'college_id': 'STD2023001',
        },
      );

      expect(session.role, 'STUDENT');
      expect(session.userId, 3);
      expect(session.studentId, 3);
      expect(session.name, 'Aly Ahmed');
      expect(session.collegeId, 'STD2023003');
    });

    test('keeps non-student roles resolved from users', () {
      final session = resolveStudentSessionFromRows(
        submittedCollegeId: 'FG2023001',
        userByCollegeId: {
          'userid': 9,
          'name': 'Fresh Graduate',
          'role': 'FRESH_GRAD',
          'college_id': 'FG2023001',
        },
        studentByCollegeId: {
          'studentid': 2,
          'name': 'Stray Student Row',
          'email': 'student@example.com',
          'college_id': 'FG2023001',
        },
        studentByUserId: null,
      );

      expect(session.role, 'FRESH_GRAD');
      expect(session.userId, 9);
      expect(session.studentId, isNull);
      expect(session.name, 'Fresh Graduate');
      expect(session.collegeId, 'FG2023001');
    });
  });
}
