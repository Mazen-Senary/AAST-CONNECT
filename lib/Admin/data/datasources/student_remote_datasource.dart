import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRemoteDataSource {
  final SupabaseClient client;

  StudentRemoteDataSource(this.client);

  Future<List<Map<String, dynamic>>> fetchStudents() async {
  // Step 1: fetch all students
  final students = await client.from('student').select();

  // Step 2: fetch application counts
  final counts = await client.from('student_application_counts').select();

  // Build a map of college_id -> total_applications
  final countMap = <String, int>{};
  for (final c in counts) {
    final id = c['college_id'] as String?;
    if (id != null) {
      countMap[id] = (c['total_applications'] as int?) ?? 0;
    }
  }

  // Step 3: merge
  return students.map<Map<String, dynamic>>((s) {
    final collegeId = s['college_id'] as String?;
    return {
      ...s,
      'application_count': countMap[collegeId] ?? 0,
    };
  }).toList();
}
}
