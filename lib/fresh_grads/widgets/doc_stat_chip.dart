import 'package:flutter/material.dart';

class DocStatChip extends StatelessWidget {
  final String value, label;
  final Color bg, color;
  const DocStatChip({required this.value, required this.label, required this.bg, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 10, color: color)),
      ]),
    ));
  }
}