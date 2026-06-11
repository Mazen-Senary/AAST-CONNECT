import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vacancy.dart';

class VacancyService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all vacancies for students (target_audience = 'STUDENT' or 'BOTH')
  Future<List<Vacancy>> getStudentVacancies() async {
    try {
      final response = await _supabase
          .from('vacancies')
          .select('''
            *,
            company:companyid(name)
          ''')
          .or('target_audience.eq.STUDENT,target_audience.eq.BOTH')
          .order('created_at', ascending: false);

      final List<Vacancy> vacancies = [];
      for (var item in response) {
        if (item['company'] != null && item['company']['name'] != null) {
          item['company_name'] = item['company']['name'].toString();
        }

        try {
          vacancies.add(Vacancy.fromMap(item));
        } catch (e) {
          print('Error parsing vacancy: $e');
          continue; // Skip invalid entries
        }
      }
      return vacancies;
    } catch (e) {
      print('Supabase error: $e');
      throw Exception('Failed to fetch vacancies: $e');
    }
  }

  // Get a single vacancy by ID
  Future<Vacancy?> getVacancyById(String vacancyId) async {
    try {
      final response = await _supabase
          .from('vacancies')
          .select('''
            *,
            company:companyid(name)
          ''')
          .eq('vacancyid', vacancyId)
          .single();

      if (response['company'] != null) {
        response['company_name'] = response['company']['name'];
      }
      return Vacancy.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch vacancy: $e');
    }
  }

  // Submit an application for a vacancy
  Future<void> submitApplication({
    required String vacancyId,
    required int applicantId,
    required String applicantName,
    required String collegeId,
    String? coverLetter,
    String? documentId, // NEW
  }) async {
    try {
      await _supabase.from('application').insert({
        'vacancyid': vacancyId,
        'applicantid': applicantId,
        'applicant_name': applicantName,
        'college_id': collegeId,
        'coverletter': coverLetter,
        'status': 'PENDING',
        'submissiondate': DateTime.now().toIso8601String(),
        'document_id':
            documentId, // Optional UUID; null is allowed if no document
      });
    } catch (e) {
      throw Exception('Failed to submit application: $e');
    }
  }

  // Future<void> submitApplication({
  //   required String vacancyId,
  //   required int applicantId,
  //   required String applicantName,
  //   required String collegeId,
  //   String? coverLetter,
  // }) async {
  //   try {
  //     await _supabase.from('application').insert({
  //       'vacancyid': vacancyId,
  //       'applicantid': applicantId,
  //       'applicant_name': applicantName,
  //       'college_id': collegeId,
  //       'coverletter': coverLetter,
  //       'status': 'PENDING',
  //       'submissiondate': DateTime.now().toIso8601String(),
  //     });
  //   } catch (e) {
  //     throw Exception('Failed to submit application: $e');
  //   }
  // }

  // Get applications for a specific user
  Future<List<Map<String, dynamic>>> getUserApplications(int userId) async {
    try {
      final response = await _supabase
          .from('application')
          .select('''
            *,
            vacancy:vacancyid(title, company_name, type)
          ''')
          .eq('applicantid', userId)
          .order('submissiondate', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch user applications: $e');
    }
  }

  // Cancel an application
  Future<void> cancelApplication(int applicationId) async {
    try {
      await _supabase
          .from('application')
          .update({'status': 'CANCELED'})
          .eq('applicationid', applicationId);
    } catch (e) {
      throw Exception('Failed to cancel application: $e');
    }
  }

  // Cancel a training record
  Future<void> cancelTrainingRecord(int trainingRecordId) async {
    try {
      await _supabase
          .from('trainingrecord')
          .update({'status': 'CANCELED'})
          .eq('recordid', trainingRecordId);
    } catch (e) {
      throw Exception('Failed to cancel training record: $e');
    }
  }

  // Check if user has applied (excluding canceled applications)
  Future<bool> hasUserApplied(String vacancyId, int userId) async {
    try {
      final response = await _supabase
          .from('application')
          .select()
          .eq('vacancyid', vacancyId)
          .eq('applicantid', userId)
          .not('status', 'eq', 'CANCELED')
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check application status: $e');
    }
  }

  // Real-time stream for vacancies
  Stream<List<Vacancy>> getVacanciesStream() {
    return _supabase
        .from('vacancies')
        .stream(primaryKey: ['vacancyid'])
        .order('created_at', ascending: false)
        .map((data) {
          final List<Vacancy> vacancies = [];
          for (var item in data) {
            if (item['target_audience'] == 'STUDENT' ||
                item['target_audience'] == 'BOTH') {
              vacancies.add(Vacancy.fromMap(item));
            }
          }
          return vacancies;
        });
  }
}

/// Service for calculating student training progress
class TrainingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Calculate training progress based on APPROVED training hours only
  ///
  /// Logic:
  /// - Progress = 0 if no APPROVED trainings
  /// - Progress = 100 if APPROVED hours >= Required hours
  /// - Progress = (APPROVED hours / Required hours) * 100 otherwise
  ///
  /// Returns: Map with:
  /// - 'approvedHours': int (sum of APPROVED training hours)
  /// - 'requiredHours': int (from student table)
  /// - 'progressPercentage': double (0-100, capped at 100)
  Future<Map<String, dynamic>> calculateTrainingProgress(int studentId) async {
    try {
      // Get required training hours from student table
      final studentData = await _supabase
          .from('student')
          .select('requiredtraininghours')
          .eq('studentid', studentId)
          .single();

      final requiredHours = (studentData['requiredtraininghours'] as int?) ?? 0;

      // Get all APPROVED training records and sum hours
      final approvedTrainings = await _supabase
          .from('trainingrecord')
          .select('hourssubmitted')
          .eq('studentid', studentId)
          .eq('status', 'APPROVED');

      // Sum approved hours only
      int totalApprovedHours = 0;
      for (var training in approvedTrainings) {
        totalApprovedHours += (training['hourssubmitted'] as int?) ?? 0;
      }

      // Calculate percentage (0-100, capped at 100)
      double progressPercentage = 0.0;

      if (requiredHours > 0 && totalApprovedHours > 0) {
        progressPercentage = (totalApprovedHours / requiredHours) * 100;
        if (progressPercentage > 100) {
          progressPercentage = 100.0;
        }
      }

      return {
        'approvedHours': totalApprovedHours,
        'requiredHours': requiredHours,
        'progressPercentage': double.parse(progressPercentage.toStringAsFixed(1)),
      };
    } catch (e) {
      print('Error calculating training progress: $e');
      return {
        'approvedHours': 0,
        'requiredHours': 0,
        'progressPercentage': 0.0,
      };
    }
  }
}
