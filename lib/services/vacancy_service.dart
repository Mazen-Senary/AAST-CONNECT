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
      });
    } catch (e) {
      throw Exception('Failed to submit application: $e');
    }
  }

  // Check if user has already applied to a vacancy
  Future<bool> hasUserApplied(String vacancyId, int userId) async {
    try {
      final response = await _supabase
          .from('application')
          .select()
          .eq('vacancyid', vacancyId)
          .eq('applicantid', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check application status: $e');
    }
  }

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
