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
  String category; // 'Technical' | 'Soft'
  String level;
  Skill({required this.name, required this.category, required this.level});
}

class Document {
  String name;
  String type;
  String date;
  String size;
  String status; // 'Approved' | 'Pending Review' | 'Rejected'
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
  final String title;
  final String company;
  final String salaryRange;
  final String workType;
  final String level;

  const JobOpportunity({
    required this.title,
    required this.company,
    required this.salaryRange,
    required this.workType,
    this.level = 'Entry Level',
  });
}

class AppData {
  static const List<CareerPath> careerPaths = [
    CareerPath(title: 'Software Engineering', roles: 15, avgSalary: '\$70k', growth: '+12%'),
    CareerPath(title: 'Data Science', roles: 8, avgSalary: '\$75k', growth: '+18%'),
    CareerPath(title: 'Product Management', roles: 6, avgSalary: '\$80k', growth: '+10%'),
  ];

  static const List<JobOpportunity> opportunities = [
    JobOpportunity(
      title: 'Full Stack Developer',
      company: 'Tech Innovators',
      salaryRange: '\$60k - \$80k',
      workType: 'Remote',
      level: 'Entry Level',
    ),
    JobOpportunity(
      title: 'Software Engineer',
      company: 'Digital Solutions',
      salaryRange: '\$55k - \$75k',
      workType: 'Hybrid',
      level: 'Entry Level',
    ),
    JobOpportunity(
      title: 'Data Analyst',
      company: 'Analytics Corp',
      salaryRange: '\$55k - \$70k',
      workType: 'On-site',
      level: 'Entry Level',
    ),
    JobOpportunity(
      title: 'Product Manager',
      company: 'InnovateTech',
      salaryRange: '\$75k - \$95k',
      workType: 'Hybrid',
      level: 'Mid Level',
    ),
    JobOpportunity(
      title: 'UI/UX Designer',
      company: 'Creative Studio',
      salaryRange: '\$50k - \$70k',
      workType: 'Remote',
      level: 'Entry Level',
    ),
    JobOpportunity(
      title: 'Backend Engineer',
      company: 'CloudSystems',
      salaryRange: '\$70k - \$90k',
      workType: 'Remote',
      level: 'Mid Level',
    ),
    JobOpportunity(
      title: 'DevOps Engineer',
      company: 'Infra Solutions',
      salaryRange: '\$80k - \$100k',
      workType: 'On-site',
      level: 'Mid Level',
    ),
    JobOpportunity(
      title: 'ML Engineer',
      company: 'AI Labs',
      salaryRange: '\$85k - \$110k',
      workType: 'Hybrid',
      level: 'Senior',
    ),
  ];
}