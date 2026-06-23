import '../../domain/entities/student.dart';

class StudentModel extends Student {
  StudentModel({
    required super.id,
    required super.name,
    required super.email,
    required super.major,
    required super.year,
    required super.gpa,
    super.collegeId,
    required super.applications,
    required super.trainingHours,
    required super.requiredTrainingHours,
    super.phone,
    super.address,
    super.dateOfBirth,
    super.gender,
    super.linkedinUrl,
    super.skills,
    super.bio,
    super.profileImageUrl,
    super.expanded,
  });

  factory StudentModel.fromJson(Map<String, dynamic> e) {
    return StudentModel(
      id: e['studentid'].toString(),
      name: e['name'] ?? '',
      email: e['email'] ?? '',
      major: e['major'] ?? '',
      year: e['academicyear'] ?? '',
      gpa: (e['gpa'] ?? 0).toDouble(),
      collegeId: e['college_id']?.toString(),
      applications: e['application_count'] ?? 0,
      trainingHours: e['completedtraininghours'] ?? 0,
      requiredTrainingHours: e['requiredtraininghours'] ?? 0,
      phone: e['phone'],
      address: e['address'],
      dateOfBirth: e['date_of_birth']?.toString(),
      gender: e['gender'],
      linkedinUrl: e['linkedin_url'],
      skills: e['skills'],
      bio: e['bio'],
      profileImageUrl: e['profile_image_url'],
    );
  }
}