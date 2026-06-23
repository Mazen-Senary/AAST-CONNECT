import '../../domain/entities/application.dart';

class ApplicationModel extends Application {
  ApplicationModel({
    required super.applicationId,
    required super.status,
    required super.studentName,
    required super.collegeId,
    required super.submissionDate,
    super.coverLetter,
    super.documentId,
    super.rejectionReason,
    super.expanded,
    super.gpa,
    super.profileImageUrl,
  });

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    print('APP MODEL IMAGE = ${map['profile_image_url']}');
    return ApplicationModel(
      applicationId: map['applicationid'],
      status: map['status'],
      studentName: map['applicant_name'] ?? 'Unknown Student',
      collegeId: map['college_id'] ?? 'N/A',
      submissionDate: map['submissiondate'] != null
          ? DateTime.parse(map['submissiondate'])
          : DateTime.now(),
      coverLetter: map['coverletter'],
      documentId: map['document_id'],
      rejectionReason: map['rejectionreason'],
      gpa: (map['gpa'] as num?)?.toDouble(),
      profileImageUrl: map['profile_image_url'],
      );
  }
}