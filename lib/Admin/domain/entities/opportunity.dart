class Opportunity {
  final String id;
  final String title;
  final String company;
  final String type;
  final String applicationMethod;
  final int applicants;
  final DateTime posted;
  final DateTime deadline;
  final String? location;
  final String? workMode;
  final bool paidStatus;
  final String targetAudience;
  final String? externalApplyUrl;
  final String? description;
  final String? requiredSkills;
  final String? companyLogoUrl;

  const Opportunity({
    required this.id,
    required this.title,
    required this.company,
    required this.type,
    required this.applicationMethod,
    required this.applicants,
    required this.posted,
    required this.deadline,
    this.location,
    this.workMode,
    required this.paidStatus,
    required this.targetAudience,
    this.externalApplyUrl,
    this.description,
    this.requiredSkills,
    this.companyLogoUrl,
  });
}
