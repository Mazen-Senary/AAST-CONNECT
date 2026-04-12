import 'package:flutter/material.dart';

class StudentOpportunitiesApplyModal {
  static void show(
    BuildContext context,
    Map<String, dynamic> program,
    VoidCallback? onConfirm,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 25,
          left: 25,
          right: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Apply for ${program['title']}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Please confirm your application details below.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const ListTile(
              leading: Icon(Icons.description),
              title: Text("Resume_Sarah_Johnson.pdf"),
              subtitle: Text("Will be shared with employer"),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF284B8C),
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (onConfirm != null) {
                    onConfirm();
                  }
                },
                child: const Text(
                  "Confirm Application",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
