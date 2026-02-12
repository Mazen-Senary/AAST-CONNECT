class Opportunity {
  final String id;
  final String title;
  final String company;
  final String type;
  final int applicants;
  final DateTime posted;
  final DateTime deadline;

  // ✅ NEW
  final String targetAudience;      // STUDENT | GRADUATE | BOTH
  final String applicationMethod;   // INTERNAL | EXTERNAL
  final String? externalApplyUrl;   // nullable

  Opportunity({
    required this.id,
    required this.title,
    required this.company,
    required this.type,
    required this.applicationMethod,
    required this.applicants,
    required this.posted,
    required this.deadline,
    required this.targetAudience,
    this.externalApplyUrl,
  });
}
