import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRemoteDataSource {
  final SupabaseClient client;

  StudentRemoteDataSource(this.client);

  Future<List<Map<String, dynamic>>> fetchStudents() async {
    final response =
        await client.from('student_profiles_view').select();

    return List<Map<String, dynamic>>.from(response);
  }
}