import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String firstName = 'Ahmed';
  String lastName = 'Gomaa';
  String email = 'ahmed.gomaa@aast.edu';
  String phone = '+20 123 456 7890';
  String major = 'Computer Science';
  String academicYear = 'Senior';
  String gpa = '3.7';
  String bio =
      'Recent graduate seeking opportunities in software development and data analytics.';
  String collegeId = ''; // ADD THIS

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  void setCollegeId(String id) {
    collegeId = id;
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
