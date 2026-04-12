import 'package:flutter/material.dart';

class SkillChip extends StatelessWidget {
  final String skill;
  final String level;
  final bool isDark;

  const SkillChip({
    super.key,
    required this.skill,
    required this.level,
    required this.isDark,
  });

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'advanced':
        return Colors.green.shade100;
      case 'intermediate':
        return Colors.orange.shade100;
      case 'beginner':
      default:
        return Colors.blue.shade100;
    }
  }

  Color _getLevelTextColor(String level) {
    switch (level.toLowerCase()) {
      case 'advanced':
        return Colors.green.shade800;
      case 'intermediate':
        return Colors.orange.shade800;
      case 'beginner':
      default:
        return Colors.blue.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            skill,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getLevelColor(level),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              level,
              style: TextStyle(
                fontSize: 11,
                color: _getLevelTextColor(level),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InterestChip extends StatelessWidget {
  final String interest;
  final bool isDark;

  const InterestChip({
    super.key,
    required this.interest,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF284B8C).withOpacity(0.2)
            : const Color(0xFF284B8C).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF284B8C).withOpacity(0.3)),
      ),
      child: Text(
        interest,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF284B8C),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
