import 'package:supabase_flutter/supabase_flutter.dart';

class ApprovalRemoteDataSource {
  final supabase = Supabase.instance.client;
  /*
  Future<List<Map<String, dynamic>>> fetchApplications() async {
    return await supabase.from('application').select();
  }

Future<List<Map<String, dynamic>>> fetchApplications() async {
  final response = await supabase
      .from('application')
      .select('*, student(gpa)');
  // flatten gpa into the map
  return List<Map<String, dynamic>>.from(response).map((e) {
    final studentData = e['student'] as Map<String, dynamic>?;
    return {
      ...e,
      'gpa': studentData?['gpa'],
    };
  }).toList();
}
  Future<List<Map<String, dynamic>>> fetchTraining() async {
    final response = await supabase
        .from('trainingrecord')
        .select('*, student(name, college_id, completedtraininghours)');
    return List<Map<String, dynamic>>.from(response);
  }
*/
  Future<List<Map<String, dynamic>>> fetchApplications() async {
    final apps = await supabase.from('application').select();

    final result = <Map<String, dynamic>>[];

    for (final app in apps) {
      final studentId = app['college_id'];

      double? gpa;

      if (studentId != null) {
        try {
          // First check student table
          final student = await supabase
              .from('student')
              .select('gpa')
              .eq('college_id', studentId)
              .maybeSingle();

          if (student != null) {
            gpa = (student['gpa'] as num?)?.toDouble();
          } else {
            // If not found, check freshgraduate table
            final freshGrad = await supabase
                .from('freshgraduate')
                .select('gpa')
                .eq('college_id', studentId)
                .maybeSingle();

            if (freshGrad != null) {
              gpa = (freshGrad['gpa'] as num?)?.toDouble();
            }
          }
        } catch (e) {
          print(e);
        }
      }

      result.add({...app, 'gpa': gpa});
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> fetchTraining() async {
    // Step 1: fetch all training records
    final records = await supabase.from('trainingrecord').select();

    // Step 2: for each record, fetch student info using studentid
    final result = <Map<String, dynamic>>[];
    for (final record in records) {
      final studentId = record['studentid'];
      String? studentName;
      String? collegeId;
      int? completedHours;

      if (studentId != null) {
        try {
          final student = await supabase
              .from('student')
              .select('name, college_id, completedtraininghours')
              .eq('studentid', studentId)
              .single();
          studentName = student['name'];
          collegeId = student['college_id'];
          completedHours = student['completedtraininghours'] as int?;
        } catch (e) {
          print("Error while fetching student: $e");
        }
      }

      result.add({
        ...record,
        'student_name': studentName ?? record['name'] ?? 'Unknown',
        'student_college_id': collegeId,
        'student_completed_hours': completedHours ?? 0,
      });
    }
    return result;
  }

  Future<void> approveApplication(int id) async {
    await supabase
        .from('application')
        .update({'status': 'APPROVED'})
        .eq('applicationid', id);
  }

  Future<void> rejectApplication(int id, String? reason) async {
    await supabase
        .from('application')
        .update({'status': 'REJECTED', 'rejectionreason': reason})
        .eq('applicationid', id);
  }

  Future<void> approveTraining(int id) async {
    // 1. Get the record to find studentid and hourssubmitted
    final record = await supabase
        .from('trainingrecord')
        .select('studentid, hourssubmitted')
        .eq('recordid', id)
        .single();

    final studentId = record['studentid'] as int;
    final hoursSubmitted = (record['hourssubmitted'] as int?) ?? 0;

    // 2. Get current completedtraininghours
    final studentData = await supabase
        .from('student')
        .select('completedtraininghours')
        .eq('studentid', studentId)
        .single();

    final currentHours = (studentData['completedtraininghours'] as int?) ?? 0;

    // 3. Add submitted hours to completed
    await supabase
        .from('student')
        .update({'completedtraininghours': currentHours + hoursSubmitted})
        .eq('studentid', studentId);

    // 4. Mark record as approved
    await supabase
        .from('trainingrecord')
        .update({'status': 'APPROVED'})
        .eq('recordid', id);
  }

  Future<void> rejectTraining(int id, String? reason) async {
    await supabase
        .from('trainingrecord')
        .update({'status': 'REJECTED', 'rejectionreason': reason})
        .eq('recordid', id);
  }
}
