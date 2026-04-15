class Application {
  final int applicationId;
  final String status;
  final String studentName;
  final String collegeId;
  final DateTime submissionDate;
  final String? coverLetter;
  final String? rejectionReason;
  final bool expanded;

  Application({
    required this.applicationId,
    required this.status,
    required this.studentName,
    required this.collegeId,
    required this.submissionDate,
    this.coverLetter,
    this.rejectionReason,
    this.expanded = false,
  });

  Application copyWith({
    String? status,
    String? rejectionReason,
    bool? expanded,
  }) {
    return Application(
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