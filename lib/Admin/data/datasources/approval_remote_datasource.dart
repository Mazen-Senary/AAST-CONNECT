import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grad_project/supabase_helper.dart';

class ApprovalRemoteDataSource {
  final supabase = Supabase.instance.client;
/*
  Future<List<Map<String, dynamic>>> fetchApplications() async {
    await setContext();
  final apps = await supabase.from('application').select();

  // Collect all unique college_ids in one shot
  final collegeIds = apps
      .map((a) => a['college_id'])
      .where((id) => id != null)
      .toSet()
      .toList();
/*
  // 1 query for students, 1 for fresh grads — instead of N queries
  final students = await supabase
      .from('student')
      .select('college_id, gpa , profile_image_url')
      .inFilter('college_id', collegeIds);
print('STUDENTS RESULT = $students');*/
final students = await supabase.rpc(
  'admin_fetch_students',
  params: {
    'p_from': 0,
    'p_to': 999,
  },
);

print('STUDENTS RESULT = $students');
  final freshGrads = await supabase
      .from('freshgraduate')
      .select('college_id, gpa')
      .inFilter('college_id', collegeIds);

  // Build lookup maps
  final studentGpaMap = <String, double>{};
  for (final s in students) {
    print(
    'STUDENT ${s['college_id']} IMAGE=${s['profile_image_url']}',
  );
    if (s['college_id'] != null) {
      studentGpaMap[s['college_id']] = (s['gpa'] as num).toDouble();
    }
  }
  final freshGpaMap = <String, double>{};
  for (final f in freshGrads) {
    if (f['college_id'] != null) {
      freshGpaMap[f['college_id']] = (f['gpa'] as num).toDouble();
    }
  }
  final profileMap = <String, String?>{};

for (final s in students) {
  print(
    'STUDENT ${s['college_id']} IMAGE=${s['profile_image_url']}',
  );
  profileMap[s['college_id']] = s['profile_image_url'];
}

  return apps.map<Map<String, dynamic>>((app) {
    final cid = app['college_id'] as String?;
    print(
    'APP $cid -> ${profileMap[cid]}',
  );
    return {
      ...app,
      'gpa': studentGpaMap[cid] ?? freshGpaMap[cid],
      'profile_image_url': profileMap[cid],
    };
  }).toList();
}
*/
Future<List<Map<String, dynamic>>> fetchApplications() async {
  await setContext();

  final apps = await supabase.from('application').select();

  final vacancyIds = apps
      .map((a) => a['vacancyid'])
      .where((id) => id != null)
      .toSet()
      .toList();

  final vacancies = await supabase
      .from('vacancies')
      .select('vacancyid, company_name')
      .inFilter('vacancyid', vacancyIds);

  final vacancyMap = <String, String?>{};
  for (final v in vacancies) {
    vacancyMap[v['vacancyid'].toString()] = v['company_name'];
  }

  final studentsRaw = await supabase.rpc(
    'admin_fetch_students',
    params: {
      'p_from': 0,
      'p_to': 999,
    },
  );

  final freshGrads = await supabase
      .from('freshgraduate')
      .select('college_id, gpa');

  final studentGpaMap = <String, double>{};
  final profileMap = <String, String?>{};

  for (final s in studentsRaw) {
    final student = Map<String, dynamic>.from(s as Map);

    final cid = student['college_id']?.toString();

    if (cid == null) continue;

    if (student['gpa'] != null) {
      studentGpaMap[cid] =
          (student['gpa'] as num).toDouble();
    }

    profileMap[cid] =
        student['profile_image_url'];

    print(
      'STUDENT $cid IMAGE=${student['profile_image_url']}',
    );
  }

  final freshGpaMap = <String, double>{};

  for (final f in freshGrads) {
    final cid = f['college_id']?.toString();

    if (cid != null && f['gpa'] != null) {
      freshGpaMap[cid] =
          (f['gpa'] as num).toDouble();
    }
  }

  return apps.map<Map<String, dynamic>>((app) {
    final cid = app['college_id']?.toString();

    print(
      'APP $cid -> ${profileMap[cid]}',
    );

    final vid = app['vacancyid']?.toString();
    return {
      ...app,
      'gpa': studentGpaMap[cid] ?? freshGpaMap[cid],
      'profile_image_url': profileMap[cid],
      'company_name': vacancyMap[vid],
    };
  }).toList();
}
Future<List<Map<String, dynamic>>> fetchTraining() async {
  await setContext();
  final records = await supabase.rpc('admin_fetch_trainingrecords');

  final studentIds = records
      .map((r) => r['studentid'])
      .where((id) => id != null)
      .toSet()
      .toList();

  final students = await supabase
      .rpc('admin_fetch_students', params: {'p_from': 0, 'p_to': 999});

  final studentMap = <dynamic, Map<String, dynamic>>{};
for (final s in students) {
  final sMap = Map<String, dynamic>.from(s as Map);
  studentMap[sMap['studentid']] = sMap;
}

  return records.map<Map<String, dynamic>>((record) {
  final r = Map<String, dynamic>.from(record as Map);
  final student = studentMap[r['studentid']];
  return {
    ...r,
    'student_name': student?['name'] ?? 'Unknown',
    'student_college_id': student?['college_id'],
    'student_completed_hours': student?['completedtraininghours'] ?? 0,
    'profile_image_url': student?['profile_image_url'],
  };
}).toList();
}

  Future<void> approveApplication(int id) async {
    await setContext(); 
    await supabase
        .from('application')
        .update({'status': 'APPROVED'})
        .eq('applicationid', id);
  }

  Future<void> rejectApplication(int id, String? reason) async {
    await setContext(); 
    await supabase
        .from('application')
        .update({'status': 'REJECTED', 'rejectionreason': reason})
        .eq('applicationid', id);
  }

  Future<void> approveTraining(int id) async {
    await setContext(); 
    // 1. Get the record to find studentid and hourssubmitted
    final record = await supabase
        .from('trainingrecord')
        .select('studentid, hourssubmitted')
        .eq('recordid', id)
        .single();

    final studentId = record['studentid'] as int;
    final hoursSubmitted = (record['hourssubmitted'] as int?) ?? 0;

    // 2. Get current completedtraininghours
    await setContext(); 
    final studentData = await supabase
        .from('student')
        .select('completedtraininghours')
        .eq('studentid', studentId)
        .single();

    final currentHours = (studentData['completedtraininghours'] as int?) ?? 0;

    // 3. Add submitted hours to completed
    await setContext(); 
    await supabase
        .from('student')
        .update({'completedtraininghours': currentHours + hoursSubmitted})
        .eq('studentid', studentId);

    // 4. Mark record as approved
    await setContext(); 
    await supabase
        .from('trainingrecord')
        .update({'status': 'APPROVED'})
        .eq('recordid', id);
  }

  Future<void> rejectTraining(int id, String? reason) async {
    await setContext(); 
    await supabase
        .from('trainingrecord')
        .update({'status': 'REJECTED', 'rejectionreason': reason})
        .eq('recordid', id);
  }
}
/*
Future<List<Map<String, dynamic>>> fetchTraining() async {
  await setContext();
  final records = await supabase.rpc('admin_fetch_trainingrecords');

  final studentIds = records
      .map((r) => r['studentid'])
      .where((id) => id != null)
      .toSet()
      .toList();

  final students = await supabase
      .rpc('admin_fetch_students', params: {'p_from': 0, 'p_to': 999});

  final studentMap = <dynamic, Map<String, dynamic>>{};
  for (final s in students) {
    studentMap[s['studentid']] = s;
  }

  return records.map<Map<String, dynamic>>((record) {
    final student = studentMap[record['studentid']];
    return {
      ...record,
      'student_name': student?['name'] ?? 'Unknown',
      'student_college_id': student?['college_id'],
      'student_completed_hours': student?['completedtraininghours'] ?? 0,
    };
  }).toList();
}
*/