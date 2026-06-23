class Student {
  final String id;
  final String name;
  final String email;
  final String major;
  final String year;
  final double gpa;
  final int applications;
  final int trainingHours;
  final String? collegeId;
  final String? phone;
  final String? address;
  final String? dateOfBirth;
  final String? gender;
  final String? linkedinUrl;
  final String? skills;
  final String? bio;
  final String? profileImageUrl;
  final bool expanded; 
  final int requiredTrainingHours;
  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.major,
    required this.year,
    required this.gpa,
    required this.applications,
    required this.trainingHours,
    this.collegeId,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.linkedinUrl,
    this.skills,
    this.bio,
    this.profileImageUrl,
    this.expanded = false, 
    required this.requiredTrainingHours
  });

  Student copyWith({bool? expanded , String? collegeId}) {
    return Student(
      id: id,
      name: name,
      email: email,
      major: major,
      year: year,
      gpa: gpa,
      applications: applications,
      trainingHours: trainingHours,
      collegeId: collegeId ?? this.collegeId,
      phone: phone,
      address: address,
      dateOfBirth: dateOfBirth,
      gender: gender,
      linkedinUrl: linkedinUrl,
      skills: skills,
      bio: bio,
      profileImageUrl: profileImageUrl,
      expanded: expanded ?? this.expanded,
      requiredTrainingHours: requiredTrainingHours,
    );
  }
}
