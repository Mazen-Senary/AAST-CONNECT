import 'package:flutter/material.dart';
import 'rounded_container.dart';

class DocumentCard extends StatelessWidget {
  final String name;
  final String date;
  final String type;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDeleteButton;

  const DocumentCard({
    super.key,
    required this.name,
    required this.date,
    required this.type,
    this.onTap,
    this.onDelete,
    this.showDeleteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      backgroundColor: Colors.white,
      borderColor: Colors.grey.shade200,
      borderRadius: 15.0,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD6E2F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.file_present,
              color: Color(0xFF284B8C),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          if (showDeleteButton && onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            )
          else if (onTap != null)
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
