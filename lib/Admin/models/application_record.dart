class ApplicationRecord {
  final int applicationId;
  final String status;
  final String studentName;
  final String collegeId;
  final DateTime submissionDate;
  final String? coverLetter;
  final String? rejectionReason;
  final bool expanded;

  ApplicationRecord({
    required this.applicationId,
    required this.status,
    required this.studentName,
    required this.collegeId,
    required this.submissionDate,
    this.coverLetter,
    this.rejectionReason,
    this.expanded = false,
  });

  factory ApplicationRecord.fromMap(Map<String, dynamic> map) {
  return ApplicationRecord(
    applicationId: map['applicationid'] as int,
    status: map['status'] as String,

    // 🔑 FIX: null-safe fallbacks
    studentName: (map['applicant_name'] as String?) ?? 'Unknown Student',
    collegeId: (map['college_id'] as String?) ?? 'N/A',

    submissionDate: map['submissiondate'] != null
        ? DateTime.parse(map['submissiondate'])
        : DateTime.now(),

    coverLetter: map['coverletter'],
    rejectionReason: map['rejectionreason'],
    expanded: false,
  );
}


  ApplicationRecord copyWith({
    String? status,
    String? rejectionReason,
    bool? expanded,
  }) {
    return ApplicationRecord(
      applicationId: applicationId,
      status: status ?? this.status,
      studentName: studentName,
      collegeId: collegeId,
      submissionDate: submissionDate,
      coverLetter: coverLetter,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      expanded: expanded ?? this.expanded,
    );
  }
}
