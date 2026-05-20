import '../../domain/entities/opportunity.dart';
class OpportunityModel extends Opportunity {
  OpportunityModel({
    required super.id,
    required super.title,
    required super.company,
    required super.type,
    required super.applicationMethod,
    required super.applicants,
    required super.posted,
    required super.deadline,
    super.location,
    super.workMode,
    required super.paidStatus,
    required super.targetAudience,
    super.externalApplyUrl,
    super.description,
    super.requiredSkills,
    super.companyLogoUrl,
  });

  factory OpportunityModel.fromJson(
    Map<String, dynamic> row,
    int applicants,
  ) {
    return OpportunityModel(
      id: row['vacancyid'].toString(),
      title: row['title'] ?? '',
      company: row['company_name'] ?? '',
      type: row['type'] ?? '',
      applicationMethod: row['application_method'] ?? 'INTERNAL',
      applicants: applicants,
      posted: DateTime.parse(row['created_at']),
      deadline: DateTime.parse(row['deadline']),
      location: row['location'],
      workMode: row['work_mode'],
      paidStatus: row['paidstatus'] ?? false,
      targetAudience: row['target_audience'] ?? 'STUDENT',
      externalApplyUrl: row['external_apply_url'],
      description: row['description'],
      requiredSkills: row['requiredskills'],
      companyLogoUrl: row['company_logo_url'],
    );
  }
}