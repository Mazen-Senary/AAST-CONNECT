class TrainingSubmission {
  final String id;
  final String studentName;
  final String company;
  final String duration; 
  final int hours;
  final String supervisor;
  final DateTime submittedDate;
  String status; // pending | approved | rejected

  TrainingSubmission({
    required this.id,
    required this.studentName,
    required this.company,
    required this.duration,
    required this.hours,
    required this.supervisor,
    required this.submittedDate,
    required this.status,
  });
}
