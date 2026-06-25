import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vacancy.dart';

class VacancyService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _extractStoragePath(String publicUrl) {
    final uri = Uri.parse(publicUrl);
    return uri.pathSegments
        .skipWhile((segment) => segment != 'documents')
        .skip(1)
        .join('/');
  }

  String _extractFileName(String publicUrl) {
    final uri = Uri.parse(publicUrl);
    return uri.pathSegments.isEmpty ? 'document.pdf' : uri.pathSegments.last;
  }

  Future<String?> _createApplicationDocumentSnapshot({
    required String documentId,
    required int applicantId,
  }) async {
    final sourceDocument = await _supabase
        .from('document')
        .select('documentid, documenttype, filepath')
        .eq('documentid', documentId)
        .maybeSingle();

    if (sourceDocument == null) {
      throw Exception('Selected document was not found.');
    }

    final sourceUrl = sourceDocument['filepath']?.toString() ?? '';
    if (sourceUrl.isEmpty) {
      throw Exception('Selected document has no file path.');
    }

    final sourcePath = _extractStoragePath(sourceUrl);
    final sourceBytes =
        await _supabase.storage.from('documents').download(sourcePath);

    final fileName = _extractFileName(sourceUrl)
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final snapshotPath =
        'applications/$applicantId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await _supabase.storage.from('documents').uploadBinary(
          snapshotPath,
          sourceBytes,
        );

    final snapshotUrl =
        _supabase.storage.from('documents').getPublicUrl(snapshotPath);

    final inserted = await _supabase
        .from('document')
        .insert({
          // Keep the application copy outside the user's document library.
          'ownerprofileid': null,
          'documenttype': sourceDocument['documenttype'],
          'filepath': snapshotUrl,
        })
        .select('documentid')
        .single();

    return inserted['documentid']?.toString();
  }

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
      String? snapshotDocumentId;
      if (documentId != null && documentId.isNotEmpty) {
        snapshotDocumentId = await _createApplicationDocumentSnapshot(
          documentId: documentId,
          applicantId: applicantId,
        );
      }

      await _supabase.from('application').insert({
        'vacancyid': vacancyId,
        'applicantid': applicantId,
        'applicant_name': applicantName,
        'college_id': collegeId,
        'coverletter': coverLetter,
        'status': 'PENDING',
        'submissiondate': DateTime.now().toIso8601String(),
        'document_id':
            snapshotDocumentId, // Application keeps its own detached copy.
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

  /// Calculate training progress from the canonical student row.
  ///
  /// Source of truth:
  /// - `student.requiredtraininghours`
  /// - `student.completedtraininghours`
  ///
  /// Returns: Map with:
  /// - 'completedHours': int (from student table)
  /// - 'requiredHours': int (from student table)
  /// - 'remainingHours': int
  /// - 'extraHours': int
  /// - 'isCompleted': bool
  /// - 'progressPercentage': double (0-100, capped at 100)
  Future<Map<String, dynamic>> calculateTrainingProgress(int studentId) async {
    try {
      final studentData = await _supabase
          .from('student')
          .select('requiredtraininghours, completedtraininghours')
          .eq('studentid', studentId)
          .single();

      final requiredHours = (studentData['requiredtraininghours'] as int?) ?? 0;
      final completedHours =
          (studentData['completedtraininghours'] as int?) ?? 0;

      final remainingHours =
          requiredHours > completedHours ? requiredHours - completedHours : 0;
      final extraHours =
          completedHours > requiredHours ? completedHours - requiredHours : 0;
      final isCompleted =
          requiredHours > 0 && completedHours >= requiredHours;

      double progressPercentage = 0.0;
      if (requiredHours > 0 && completedHours > 0) {
        progressPercentage = (completedHours / requiredHours) * 100;
        if (progressPercentage > 100) {
          progressPercentage = 100.0;
        }
      }

      return {
        'completedHours': completedHours,
        // Keep the old key temporarily so existing callers stay stable.
        'approvedHours': completedHours,
        'requiredHours': requiredHours,
        'remainingHours': remainingHours,
        'extraHours': extraHours,
        'isCompleted': isCompleted,
        'progressPercentage': double.parse(progressPercentage.toStringAsFixed(1)),
      };
    } catch (e) {
      print('Error calculating training progress: $e');
      return {
        'completedHours': 0,
        'approvedHours': 0,
        'requiredHours': 0,
        'remainingHours': 0,
        'extraHours': 0,
        'isCompleted': false,
        'progressPercentage': 0.0,
      };
    }
  }
}
