import 'package:flutter/material.dart';

class StudentProfilePortfolioModal {
  static void show(BuildContext context) {
    final List<Map<String, String>> links = [
      {"title": "Personal Portfolio", "url": "sarahjohnson.dev", "type": "Website"},
      {"title": "GitHub Profile", "url": "github.com/sarahjohnson", "type": "GitHub"},
      {"title": "LinkedIn", "url": "linkedin.com/in/sarahjohnson", "type": "LinkedIn"},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Portfolio Links",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFD6E2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Your professional links help recruiters and program coordinators learn more about your work and experience",
                style: TextStyle(color: Color(0xFF284B8C)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Add New Link",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                hintText: "https://",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF284B8C)),
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your Links",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: links.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6E2F2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            links[index]['type'] == 'GitHub'
                                ? Icons.code
                                : links[index]['type'] == 'LinkedIn'
                                ? Icons.work
                                : Icons.link,
                            color: const Color(0xFF284B8C),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                links[index]['title']!,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                links[index]['url']!,
                                style: const TextStyle(
                                  color: Color(0xFF284B8C),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}