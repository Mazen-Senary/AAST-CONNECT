import 'package:flutter/material.dart';
import '../../services/user_session.dart';

class ProfileProvider extends ChangeNotifier {
  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';
  String major = '';
  String academicYear = '';
  String gpa = '';
  String bio = '';
  String collegeId = '';

  String get fullName => '$firstName $lastName'.trim();
  String get initials {
    if (firstName.isEmpty && lastName.isEmpty) return '?';
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  void setCollegeId(String id) {
    collegeId = id;
    notifyListeners();
  }

  /// Populate profile from UserSession after login
  void loadFromSession() {
    final session = UserSession.instance;
    final nameParts = (session.name ?? '').split(' ');
    firstName = nameParts.isNotEmpty ? nameParts.first : '';
    lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    collegeId = session.collegeId ?? '';
    notifyListeners();
  }

  void updateProfile({
    required String newFirstName,
    required String newLastName,
    required String newEmail,
    required String newPhone,
    required String newMajor,
    required String newAcademicYear,
    required String newGpa,
    required String newBio,
  }) {
    firstName = newFirstName;
    lastName = newLastName;
    email = newEmail;
    phone = newPhone;
    major = newMajor;
    academicYear = newAcademicYear;
    gpa = newGpa;
    bio = newBio;
    notifyListeners();
  }
}
