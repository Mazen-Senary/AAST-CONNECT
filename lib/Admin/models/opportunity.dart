class Opportunity {
  final String id;
  final String title;
  final String company;
  final String type;
  final int applicants;
  final DateTime posted;
  final DateTime deadline;
  final String? location;
  final String? workMode;
  final bool paidStatus;

  final String? description;
  final String? requiredSkills;
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
    this.location,
    this.workMode,
    required this.paidStatus,
    this.description,
    this.requiredSkills,
  });
}
