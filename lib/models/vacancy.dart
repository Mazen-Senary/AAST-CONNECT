class Vacancy {
  final String vacancyId;
  final String title;
  final String? description;
  final String type;
  final String? location;
  final String? requiredSkills;
  final bool paidStatus;
  final DateTime? deadline;
  final String? companyId;
  final int? postedByAdminId;
  final DateTime createdAt;
  final String workMode;
  final String targetAudience;
  final String applicationMethod;
  final String? externalApplyUrl;
  final String? companyName;

  Vacancy({
    required this.vacancyId,
    required this.title,
    this.description,
    required this.type,
    this.location,
    this.requiredSkills,
    required this.paidStatus,
    this.deadline,
    this.companyId,
    this.postedByAdminId,
    required this.createdAt,
    required this.workMode,
    required this.targetAudience,
    required this.applicationMethod,
    this.externalApplyUrl,
    this.companyName,
  });

  factory Vacancy.fromMap(Map<String, dynamic> map) {
    return Vacancy(
      vacancyId: map['vacancyid']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString(),
      type: map['type']?.toString() ?? '',
      location: map['location']?.toString(),
      requiredSkills: map['requiredskills']?.toString(),
      paidStatus: map['paidstatus'] as bool? ?? false,
      deadline: map['deadline'] != null
          ? DateTime.tryParse(map['deadline'].toString())
          : null,
      companyId: map['companyid']?.toString(),
      postedByAdminId: map['postedbyadminid'] as int?,
      createdAt:
          DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now(),
      workMode: map['work_mode']?.toString() ?? 'ONSITE',
      targetAudience: map['target_audience']?.toString() ?? 'STUDENT',
      applicationMethod: map['application_method']?.toString() ?? 'INTERNAL',
      externalApplyUrl: map['external_apply_url']?.toString(),
      companyName: map['company_name']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vacancyid': vacancyId,
      'title': title,
      'description': description,
      'type': type,
      'location': location,
      'requiredskills': requiredSkills,
      'paidstatus': paidStatus,
      'deadline': deadline?.toIso8601String(),
      'companyid': companyId,
      'postedbyadminid': postedByAdminId,
      'created_at': createdAt.toIso8601String(),
      'work_mode': workMode,
      'target_audience': targetAudience,
      'application_method': applicationMethod,
      'external_apply_url': externalApplyUrl,
      'company_name': companyName,
    };
  }

  // Helper method to get display data similar to the static format
  Map<String, dynamic> toDisplayMap() {
    return {
      'title': title,
      'company': companyName ?? 'Unknown Company',
      'hours': 'Varies',
      'location': location ?? 'Not specified',
      'category': _getCategoryFromType(type),
      'type': type,
      'applied': false, // This will be determined by checking applications
      'description': description ?? 'No description available',
      'requirements': requiredSkills ?? 'No specific requirements',
      'duration': _getDurationFromType(type),
      'startDate': deadline?.toString().split(' ')[0] ?? 'Flexible',
      'vacancyId': vacancyId,
      'workMode': workMode,
      'paidStatus': paidStatus,
      'applicationMethod': applicationMethod,
      'externalApplyUrl': externalApplyUrl,
    };
  }

  String _getCategoryFromType(String type) {
    switch (type.toLowerCase()) {
      case 'internship':
        return 'Development';
      case 'training':
        return 'IT';
      case 'job':
        return 'Development';
      default:
        return 'General';
    }
  }

  String _getDurationFromType(String type) {
    switch (type.toLowerCase()) {
      case 'internship':
        return '3-6 months';
      case 'training':
        return '2-8 weeks';
      case 'job':
        return 'Full-time';
      default:
        return 'Varies';
    }
  }
}
