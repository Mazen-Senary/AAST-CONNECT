class Training {
  final int recordId;
  final int studentId;
  final String studentName;
  final String companyName;
  final String supervisorName;
  final int hoursSubmitted;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;
  final String? proofImageUrl;
  final bool expanded;
  final String? certificateUrl;
   // In training.dart entity, add these two fields:
  final String? collegeId;
  final int completedTrainingHours;

  Training({
    required this.recordId,
    required this.studentId,
    required this.studentName,
    required this.companyName,
    required this.supervisorName,
    required this.hoursSubmitted,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    this.proofImageUrl,
    this.rejectionReason,
    this.expanded = false,
    this.certificateUrl,
    required this.collegeId,
    this.completedTrainingHours = 0,
  });

  Training copyWith({
    String? status,
    String? rejectionReason,
    bool? expanded,
    String? certificateUrl,
    String? collegeId,
    int? completedTrainingHours,
  }) {
    return Training(
      recordId: recordId,
      studentId: studentId,
      studentName: studentName,
      companyName: companyName,
      supervisorName: supervisorName,
      hoursSubmitted: hoursSubmitted,
      startDate: startDate,
      endDate: endDate,
      status: status ?? this.status,
      createdAt: createdAt,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      expanded: expanded ?? this.expanded,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      collegeId: collegeId ?? this.collegeId,
      completedTrainingHours: completedTrainingHours ?? this.completedTrainingHours,
    );
  }
}