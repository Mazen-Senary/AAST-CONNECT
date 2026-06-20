import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  /// Fetch the full fresh-graduate profile from the database
  /// using the college_id stored in UserSession.
  Future<void> loadFromDatabase() async {
    final session = UserSession.instance;
    if (session.collegeId == null || session.collegeId!.isEmpty) return;

    collegeId = session.collegeId ?? '';

    try {
      final supabase = Supabase.instance.client;

      // Look up in freshgraduate table by college_id
      final data = await supabase
          .from('freshgraduate')
          .select()
          .eq('college_id', session.collegeId!)
          .maybeSingle();

      if (data != null) {
        final nameParts = (data['name'] ?? '').toString().split(' ');
        firstName = nameParts.isNotEmpty ? nameParts.first : '';
        lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        email = data['email']?.toString() ?? '';
        phone = data['phone']?.toString() ?? '';
        major = data['major']?.toString() ?? '';
        gpa = data['gpa']?.toString() ?? '';
        bio = data['bio']?.toString() ?? '';
        // academicYear is not in freshgraduate table, default to 'Graduate'
        academicYear = 'Graduate';
      } else {
        // Fallback: use data from UserSession
        final nameParts = (session.name ?? '').split(' ');
        firstName = nameParts.isNotEmpty ? nameParts.first : '';
        lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        academicYear = 'Graduate';
      }

      notifyListeners();
    } catch (e) {
      debugPrint('ProfileProvider.loadFromDatabase error: $e');
      // Fallback to session name
      final nameParts = (session.name ?? '').split(' ');
      firstName = nameParts.isNotEmpty ? nameParts.first : '';
      lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      academicYear = 'Graduate';
      notifyListeners();
    }
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
