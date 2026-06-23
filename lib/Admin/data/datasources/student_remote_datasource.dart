import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grad_project/supabase_helper.dart';

class StudentRemoteDataSource {
  final SupabaseClient client;
  StudentRemoteDataSource(this.client);

  static const int pageSize = 20;

  Future<List<Map<String, dynamic>>> fetchStudents({int page = 0}) async {
  await setContext();
  final from = page * pageSize;
  final to = from + pageSize - 1;

  final studentsRaw = await client
      .rpc('admin_fetch_students', params: {'p_from': from, 'p_to': to});
  final students = (studentsRaw as List)
      .map((s) => Map<String, dynamic>.from(s as Map))
      .toList();
  print('📦 students fetched: ${students.length}');

  final countsRaw = await client.rpc('admin_fetch_application_counts');
  final counts = (countsRaw as List)
      .map((c) => Map<String, dynamic>.from(c as Map))
      .toList();
  print('📦 counts fetched: ${counts.length}');

  final countMap = <String, int>{};
  for (final c in counts) {
    final id = c['college_id'] as String?;
    if (id != null) countMap[id] = (c['total_applications'] as num?)?.toInt() ?? 0;
  }

  return students.map<Map<String, dynamic>>((s) {
    return {...s, 'application_count': countMap[s['college_id']] ?? 0};
  }).toList();
}
}