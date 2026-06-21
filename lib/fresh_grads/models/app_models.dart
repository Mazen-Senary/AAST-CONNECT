import 'package:flutter/material.dart';

class CareerPath {
  final String title;
  final int roles;
  final String avgSalary;
  final String growth;

  const CareerPath({
    required this.title,
    required this.roles,
    required this.avgSalary,
    required this.growth,
  });
}

class Skill {
  String name;
  String category;
  String level;
  Skill({required this.name, required this.category, required this.level});
}

class Document {
  String name;
  String type;
  String date;
  String size;
  String status;
  String? rejectionReason;
  Document({
    required this.name,
    required this.type,
    required this.date,
    required this.size,
    required this.status,
    this.rejectionReason,
  });
}

class PortfolioLink {
  String title;
  String url;
  IconData icon;
  Color iconBg;
  Color iconColor;
  PortfolioLink({
    required this.title,
    required this.url,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}

class JobOpportunity {
  final String vacancyId;
  final String title;
  final String company;
  final String salaryRange;
  final String workType;
  final String level;
  final String applicationMethod;
  final String? externalApplyUrl;
  final String? companyLogoUrl;
  final String? description;
  final String? requirements;
  final String? location;
  final String? deadline;

  const JobOpportunity({
    required this.vacancyId,
    required this.title,
    required this.company,
    required this.salaryRange,
    required this.workType,
    this.level = 'Entry Level',
    this.applicationMethod = 'INTERNAL',
    this.externalApplyUrl,
    this.companyLogoUrl,
    this.description,
    this.requirements,
    this.location,
    this.deadline,
  });

  factory JobOpportunity.fromMap(Map<String, dynamic> map) {
    return JobOpportunity(
      vacancyId: map['vacancyid'] ?? '',
      title: map['title'] ?? 'Unknown Title',
      company: map['company_name'] ?? 'Unknown Company',
      salaryRange: (map['paidstatus'] == true) ? 'Paid' : 'Unpaid',
      workType: _mapWorkMode(map['work_mode']),
      level: map['type'] ?? 'JOB',
      applicationMethod: map['application_method'] ?? 'INTERNAL',
      externalApplyUrl: map['external_apply_url'],
      companyLogoUrl: map['company_logo_url'],
      description: map['description'],
      requirements: map['requiredskills'],
      location: map['location'],
      deadline: map['deadline']?.toString(),
    );
  }

  static String _mapWorkMode(String? mode) {
    switch (mode) {
      case 'ONSITE':
        return 'On-site';
      case 'HYBRID':
        return 'Hybrid';
      case 'REMOTE':
        return 'Remote';
      default:
        return 'On-site';
    }
  }
}

class AppData {
  static const List<CareerPath> careerPaths = [
    CareerPath(
      title: 'Software Engineering',
      roles: 15,
      avgSalary: '\$70k',
      growth: '+12%',
    ),
    CareerPath(
      title: 'Data Science',
      roles: 8,
      avgSalary: '\$75k',
      growth: '+18%',
    ),
    CareerPath(
      title: 'Product Management',
      roles: 6,
      avgSalary: '\$80k',
      growth: '+10%',
    ),
  ];

  static const List<JobOpportunity> opportunities = [];
}
