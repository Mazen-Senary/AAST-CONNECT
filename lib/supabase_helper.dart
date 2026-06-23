import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_session.dart';

final supabase = Supabase.instance.client;

Future<void> setContext() async {
  final id = AuthSession.collegeId;
  final password = AuthSession.password; 
   print('SET CONTEXT');
  print('id=$id');
  print('password=$password');

  if (id != null && password != null) {
    await supabase.rpc('set_session_context', params: {
      'p_college_id': id,
      'p_password': password,
    });
  }
}