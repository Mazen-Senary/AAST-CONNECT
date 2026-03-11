import 'package:flutter/material.dart';


class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const ActionButton({required this.label, required this.icon, required this.bg,
    required this.color, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(color: isDark ? color.withOpacity(0.15) : bg,
            borderRadius: BorderRadius.circular(14)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    ));
  }
}