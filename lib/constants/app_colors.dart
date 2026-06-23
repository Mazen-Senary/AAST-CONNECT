import 'package:flutter/material.dart';

/// Centralized color constants for the AAST-CONNECT app
/// All colors should be referenced from this class instead of hardcoded values
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF284B8C);
  static const Color lightSecondary = Color(0xFF637E99);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFF9F9F9);
  static const Color lightError = Color(0xFFF44336);

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF8FC7FF);
  static const Color darkSecondary = Color(0xFF95A7BA);
  static const Color darkSurface = Color(0xFF1B2026);
  static const Color darkBackground = Color(0xFF111418);
  static const Color darkError = Color(0xFFF44336);

  // Status Colors
  static const Color approved = Color(0xFF4CAF50);
  static const Color pending = Color(0xFFFFC107);
  static const Color rejected = Color(0xFFF44336);
  static const Color canceled = Color(0xFF757575);

  // Skill Level Colors
  static const Color beginner = Color(0xFF2196F3);
  static const Color intermediate = Color(0xFFFF9800);
  static const Color advanced = Color(0xFF4CAF50);

  // Category Colors
  static const Color development = Color(0xFF4CAF50);
  static const Color it = Color(0xFF2196F3);
  static const Color security = Color(0xFFF44336);
  static const Color design = Color(0xFFFF9800);
  static const Color data = Color(0xFF009688);
  static const Color cloud = Color(0xFF03A9F4);
  static const Color ai = Color(0xFF3F51B5);

  // Document Colors
  static const Color documentBackground = Color(0xFFD6E2F2);
  static const Color documentIcon = Color(0xFF284B8C);

  // Dark Mode Specific Colors
  static const Color darkContainer = Color(0xFF202731);
  static const Color darkModal = Color(0xFF171C22);
  static const Color darkDropdown = Color(0xFF252D36);
  //navbar colors
  static const Color navSelectedBackground = Color(0xFFD6EAF2);
  static const Color navSelectedIcon = Color(0xFF057C99);
  static const Color navUnselectedIcon = Color(0xFF9E9E9E);

  // Opacity Variants
  static Color primaryWithOpacity(double opacity) =>
      lightPrimary.withOpacity(opacity);
  static Color primaryWithOpacityDark(double opacity) =>
      darkPrimary.withOpacity(opacity);

  // Category Color Mapping
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'development':
        return development;
      case 'it':
        return it;
      case 'security':
        return security;
      case 'design':
        return design;
      case 'data':
        return data;
      case 'cloud':
        return cloud;
      case 'ai':
        return ai;
      default:
        return Colors.grey.shade100;
    }
  }

  // Skill Level Color Mapping
  static Color getSkillLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'advanced':
        return advanced;
      case 'intermediate':
        return intermediate;
      case 'beginner':
      default:
        return beginner;
    }
  }

  // Status Color Mapping
  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return approved;
      case 'REJECTED':
        return rejected;
      case 'CANCELED':
        return canceled;
      case 'PENDING':
      default:
        return pending;
    }
  }

  // Additional UI Colors
  static const Color statPending = Color(0xffF2C6C6);
  static const Color statApproved = Color(0xffCFE3CF);
  static const Color backgroundBeige = Color(0xFFF9EAD2);
  static const Color backgroundPink = Color(0xFFF2C6C6);
  static const Color progressGreen = Color(0xFF206E54);
  static const Color quickActionEdit = Color(0xFFD6E2F2);
  static const Color quickActionSkills = Color(0xFFCFE3CF);
  static const Color quickActionDocuments = Color(0xFFF9EAD2);
  static const Color quickActionPortfolio = Color(0xFFF2C6C6);
  static const Color supportChat = Color(0xFFD6E2F2);
  static const Color supportGuide = Color(0xFFCFE3CF);
  static const Color toggleSelected = Color(0xFFD6E2F2);
  static const Color trainingProgress = Color(0xFFEAD2B7);
}
