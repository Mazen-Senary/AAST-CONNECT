import 'package:flutter/material.dart';
import '../models/app_models.dart';

class SkillChip extends StatelessWidget {
  final Skill skill;
  final Color bgColor, textColor;
  final VoidCallback onRemove;
  const SkillChip({required this.skill, required this.bgColor, required this.textColor, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(skill.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
          Text(skill.level, style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7))),
        ]),
        const SizedBox(width: 6),
        GestureDetector(onTap: onRemove, child: Icon(Icons.close, size: 14, color: textColor)),
      ]),
    );
  }
}