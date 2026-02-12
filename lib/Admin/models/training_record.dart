class TrainingRecord {
  final int recordId;
  final int studentId;
  final String studentName;
  final String companyName;
  final String supervisorName;
  final int hoursSubmitted;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime createdAt;
  final String? proofImageUrl;
  final bool expanded;

  TrainingRecord({
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
    this.expanded = false,
    this.proofImageUrl,
  });

  factory TrainingRecord.fromMap(Map<String, dynamic> map) {
    return TrainingRecord(
      recordId: map['recordid'] as int,
      studentId: map['studentid'] as int,
      studentName: map['studentname'] ?? 'Unknown Student',
      companyName: map['companyname'] ?? '',
      supervisorName: map['supervisorname'] ?? '',
      hoursSubmitted: map['hourssubmitted'] ?? 0,
      startDate: map['startdate'] != null
          ? DateTime.parse(map['startdate'])
          : DateTime.now(),
      endDate: map['enddate'] != null
          ? DateTime.parse(map['enddate'])
          : DateTime.now(),
      status: map['status'] ?? 'PENDING',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      proofImageUrl: map['proof_image_url'],
      expanded: false,
    );
  }

  TrainingRecord copyWith({
    String? status,
    bool? expanded,
    String? proofImageUrl,
  }) {
    return TrainingRecord(
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
      expanded: expanded ?? this.expanded,
    );
  }
}
