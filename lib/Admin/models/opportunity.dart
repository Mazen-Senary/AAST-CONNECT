class Opportunity {
  final String id;
  final String title;
  final String company;
  final String type;      // Training | Internship | Job
  final String status;    // Internal | External
  final int applicants;
  final DateTime posted;
  final DateTime deadline;

  Opportunity({
    required this.id,
    required this.title,
    required this.company,
    required this.type,
    required this.status,
    required this.applicants,
    required this.posted,
    required this.deadline,
  });
}
