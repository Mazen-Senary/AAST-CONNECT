import 'package:supabase_flutter/supabase_flutter.dart';

class ApprovalRemoteDataSource {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchApplications() async {
    return await supabase.from('application').select();
  }

  Future<List<Map<String, dynamic>>> fetchTraining() async {
    return await supabase.from('trainingrecord').select();
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
