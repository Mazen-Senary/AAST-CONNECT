class Student {
  final int studentID;
  final String studentName;
  final String studentEmail;
  final String major;
  final String academicYear;
  final int requiredTrainingHours;
  final int completedTrainingHours;
  final double? gpa;
  final String? collegeID;
  final String? phoneNumber;
  final String? bio;
  final String? address;
  final String? skills;
  final String? profileImageURL;
  final String? linkedinURL;

  Student({
    required this.studentID,
    required this.studentName,
    required this.studentEmail,
    required this.major,
    required this.academicYear,
    required this.requiredTrainingHours,
    required this.completedTrainingHours,
    this.gpa,
    this.collegeID,
    this.phoneNumber,
    this.address,
    this.bio,
    this.skills,
    this.profileImageURL,
    this.linkedinURL,
  });
  //here converting supabase data to student object
factory Student.fromMap(Map<String, dynamic> map){
return Student(

  studentID: map['studentid'] as int,
  studentName: map['name']?.toString() ?? '',
  studentEmail: map['email']?.toString() ?? '',
  major: map['major']?.toString() ?? '',
  academicYear: map['academicyear']?.toString() ?? '',
  requiredTrainingHours: map['requiredtraininghours'] as int? ?? 0,
  completedTrainingHours: map['completedtraininghours'] as int? ?? 0,
  gpa: (map['gpa'] as num?)?.toDouble(),
  collegeID: map['college_id']?.toString(),
  phoneNumber: map['phone']?.toString(),
  address: map['address']?.toString(),
  bio: map['bio']?.toString(),
  skills: map['skills']?.toString(),
  profileImageURL: map['profile_image_url']?.toString(),
  linkedinURL: map['linkedin_url']?.toString(),
);

}
//map used when sending data from app to database updating student info map
  Map<String, dynamic> toMap() { // only for information that student can update
    return {
      'name': studentName,
      'phone': phoneNumber,
      'address': address,
      'bio': bio,
      'skills': skills,
      'profile_image_url': profileImageURL,
      'linkedin_url': linkedinURL,
    };
  }
}
