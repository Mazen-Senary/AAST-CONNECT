import '../../domain/entities/training.dart';

class TrainingModel extends Training {
  TrainingModel({
    required super.recordId,
    required super.studentId,
    required super.studentName,
    required super.companyName,
    required super.supervisorName,
    required super.hoursSubmitted,
    required super.startDate,
    required super.endDate,
    required super.status,
    required super.createdAt,
    super.proofImageUrl,
    super.rejectionReason,
    super.expanded,
    super.certificateUrl,
    super.collegeId,
    super.completedTrainingHours,
    super.profileImageUrl,
  });

  factory TrainingModel.fromMap(Map<String, dynamic> map) {
    final student = map['student'] as Map<String, dynamic>?;
  return TrainingModel(
    recordId: map['recordid'],
    studentId: map['studentid'] as int? ?? 0, 
   studentName: map['student_name'] ?? 'Unknown',       // NEW KEY
    collegeId: map['student_college_id'],  
    completedTrainingHours: (map['student_completed_hours'] as int?) ?? 0,    companyName: map['companyname'] ?? '',
    supervisorName: map['supervisorname'] ?? '',
    hoursSubmitted: (map['hourssubmitted'] as int?) ?? 0,
    startDate: map['startdate'] != null
        ? DateTime.parse(map['startdate'])
        : DateTime.now(),
    endDate: map['enddate'] != null
        ? DateTime.parse(map['enddate'])
        : DateTime.now(),
    status: map['status'] ?? 'PENDING',
    createdAt: DateTime.parse(map['created_at']),
    proofImageUrl: map['proof_image_url'],
    rejectionReason: map['rejectionreason'],
    // add this field to Training entity first
    certificateUrl: map['certificate_url'],
    profileImageUrl: map['profile_image_url'],
  );
}
}