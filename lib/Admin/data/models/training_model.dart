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
  });

  factory TrainingModel.fromMap(Map<String, dynamic> map) {
    return TrainingModel(
      recordId: map['recordid'],
      studentId: map['studentid'],
      studentName: map['studentname'] ?? 'Unknown',
      companyName: map['companyname'] ?? '',
      supervisorName: map['supervisorname'] ?? '',
      hoursSubmitted: map['hourssubmitted'] ?? 0,
      startDate: DateTime.parse(map['startdate']),
      endDate: DateTime.parse(map['enddate']),
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
      proofImageUrl: map['proof_image_url'],
      rejectionReason: map['rejectionreason'],
    );
  }
}