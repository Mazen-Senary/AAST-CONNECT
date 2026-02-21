import 'package:flutter/material.dart';

class StudentProfile extends StatelessWidget {
  const StudentProfile({super.key});

  void _showEditProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // Fixed header (doesn't scroll)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Profile Header with Initials (fixed)
            Row(
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF637E99),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Text(
                      "SJ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sarah Johnson",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "ID: 3333333333",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            
            const Divider(height: 40),
            
            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    const Text(
                      "Basic Information",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    
                    _buildEditField("First Name", "Sarah"),
                    _buildEditField("Last Name", "Johnson"),
                    _buildEditField("Email", "sarah.johnson@aast.edu"),
                    _buildEditField("Phone Number", "+20 123 456 7890"),
                    
                    const SizedBox(height: 25),
                    
                    // Academic Information
                    const Text(
                      "Academic Information",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    
                    Row(
                      children: [
                        Expanded(child: _buildEditField("Major", "Computer Science")),
                        const SizedBox(width: 15),
                        Expanded(child: _buildEditField("Academic Year", "2024")),
                      ],
                    ),
                    
                    const SizedBox(height: 15),
                    
                    Row(
                      children: [
                        Expanded(child: _buildEditField("GPA", "3.8")),
                        const SizedBox(width: 15),
                        Expanded(child: _buildEditField("Year Level", "Junior")),
                      ],
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // Bio
                    const Text(
                      "Bio",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Text(
                        "Passionate computer science student interested in web development and AI.",
                        style: TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                    
                    // Add extra space at the bottom for comfortable scrolling
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            
            // Save Button (fixed at bottom)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF284B8C),
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showSkillsModal(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Fixed Header
          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Skills & Interests",
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skills Section
                  Text(
                    "Skills",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Add new skill form
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Add a new skill...",
                            hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF3C3C3C) : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Category",
                                      style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                                    ),
                                    Icon(Icons.arrow_drop_down, color: isDark ? Colors.grey.shade400 : Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF3C3C3C) : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Level",
                                      style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                                    ),
                                    Icon(Icons.arrow_drop_down, color: isDark ? Colors.grey.shade400 : Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF3C3C3C) : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Technical",
                                      style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                                    ),
                                    Icon(Icons.arrow_drop_down, color: isDark ? Colors.grey.shade400 : Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF3C3C3C) : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Beginner",
                                      style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                                    ),
                                    Icon(Icons.arrow_drop_down, color: isDark ? Colors.grey.shade400 : Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add),
                            label: const Text("Add Skill"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF284B8C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Technical Skills
                  Text(
                    "Technical Skills",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSkillChip("React", "Advanced", isDark),
                  _buildSkillChip("TypeScript", "Intermediate", isDark),
                  _buildSkillChip("Python", "Advanced", isDark),

                  const SizedBox(height: 20),

                  // Soft Skills
                  Text(
                    "Soft Skills",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSkillChip("Communication", "Advanced", isDark),
                  _buildSkillChip("Team Leadership", "Intermediate", isDark),

                  const SizedBox(height: 25),

                  // Interests Section
                  Text(
                    "Interests",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Add interest field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Add an interest...",
                        hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add, color: const Color(0xFF284B8C)),
                          onPressed: () {},
                        ),
                      ),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Interest chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInterestChip("Web Development", isDark),
                      _buildInterestChip("Machine Learning", isDark),
                      _buildInterestChip("UI/UX Design", isDark),
                      _buildInterestChip("Cloud Computing", isDark),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Improve Profile Tip
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark 
                        ? const Color(0xFF284B8C).withOpacity(0.2)
                        : const Color(0xFFD6E2F2).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF284B8C).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline, 
                          color: isDark ? Colors.white : const Color(0xFF284B8C)
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Improve Your Profile\nAdding skills and interests helps match you with relevant opportunities and training programs.",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30), // Extra space at bottom
                ],
              ),
            ),
          ),

          // Fixed Done Button at Bottom
          Padding(
            padding: const EdgeInsets.all(25),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF284B8C),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Done",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Helper widgets (keep these outside the function)
Widget _buildSkillChip(String skill, String level, bool isDark) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
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
            color: level == "Advanced" 
                ? Colors.green.shade100 
                : level == "Intermediate"
                    ? Colors.orange.shade100
                    : Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            level,
            style: TextStyle(
              fontSize: 11,
              color: level == "Advanced" 
                  ? Colors.green.shade800 
                  : level == "Intermediate"
                      ? Colors.orange.shade800
                      : Colors.blue.shade800,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildInterestChip(String interest, bool isDark) {
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

  void _showDocumentsModal(BuildContext context) {
    final List<Map<String, String>> documents = [
      {
        "name": "Resume_Sarah_Johnson.pdf",
        "date": "CV • Jan 15",
        "type": "CV",
      },
      {
        "name": "Python_Certificate.pdf",
        "date": "Certificate • Jan 10",
        "type": "Certificate",
      },
      {
        "name": "Cover_Letter.pdf",
        "date": "Document • Feb 1",
        "type": "Cover Letter",
      },
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
                  "Documents",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload),
              label: const Text("Upload New Document"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF284B8C),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your Documents",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: documents.length,
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
                                documents[index]['name']!,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                documents[index]['date']!,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
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

  void _showPortfolioModal(BuildContext context) {
    final List<Map<String, String>> links = [
      {
        "title": "Personal Portfolio",
        "url": "sarahjohnson.dev",
        "type": "Website",
      },
      {
        "title": "GitHub Profile",
        "url": "github.com/sarahjohnson",
        "type": "GitHub",
      },
      {
        "title": "LinkedIn",
        "url": "linkedin.com/in/sarahjohnson",
        "type": "LinkedIn",
      },
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
                "💡 Your professional links help recruiters and program coordinators learn more about your work and experience",
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

  void _showSubmitHoursModal(BuildContext context) {
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
            const Text(
              "Submit Training Hours",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: "Program Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: "Hours Completed",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: "Supervisor Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFD6E2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.upload_file, color: Color(0xFF284B8C)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Upload Certificate",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "PDF or Image (Max 5MB)",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Choose File"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF284B8C),
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Training hours submitted successfully!"),
                    ),
                  );
                },
                child: const Text(
                  "Submit Hours",
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

  void _showSavedProgramDetails(BuildContext context, String title, String company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(company, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),
            const Text(
              "Program Details:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("• Duration: 6 months"),
            const Text("• Location: Hybrid"),
            const Text("• Start Date: March 2024"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF284B8C),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Application started!")),
              );
            },
            child: const Text("Apply Now"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "AAST Connect",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode_outlined, color: Color(0xFF284B8C)),
            onPressed: () {},
          ),
          const Icon(Icons.logout, color: Colors.black54),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Profile",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Manage your information and documents",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 25),

            // Top Quick Actions Grid - Now Clickable
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showEditProfileModal(context),
                    child: _buildQuickAction(
                      Icons.email_outlined,
                      "Edit Profile",
                      const Color(0xFFD6E2F2),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showSkillsModal(context),
                    child: _buildQuickAction(
                      Icons.eco_outlined,
                      "Skills & Interests",
                      const Color(0xFFCFE3CF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showDocumentsModal(context),
                    child: _buildQuickAction(
                      Icons.description_outlined,
                      "Documents",
                      const Color(0xFFF9EAD2),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showPortfolioModal(context),
                    child: _buildQuickAction(
                      Icons.bookmark_border,
                      "Portfolio Links",
                      const Color(0xFFF2C6C6),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // User Info Card
            _buildUserInfoCard(),

            const SizedBox(height: 30),

            // Documents Section - Now Interactive
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Documents",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showDocumentsModal(context),
                  icon: const Icon(Icons.upload, size: 16),
                  label: const Text("Manage"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF637E99),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => _showDocumentsModal(context),
              child: _buildDocItem(
                "Resume_Sarah_Johnson.pdf",
                "CV • Jan 15",
                true,
              ),
            ),
            GestureDetector(
              onTap: () => _showDocumentsModal(context),
              child: _buildDocItem(
                "Python_Certificate.pdf",
                "Certificate • Jan 10",
                true,
              ),
            ),

            const SizedBox(height: 30),

            // Saved Programs - Now Clickable
            const Row(
              children: [
                Icon(Icons.bookmark_outline, size: 20),
                SizedBox(width: 8),
                Text(
                  "Saved Programs",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => _showSavedProgramDetails(
                context,
                "Software Engineering Intern",
                "TechCorp",
              ),
              child: _buildSavedItem("Software Engineering Intern", "TechCorp"),
            ),
            GestureDetector(
              onTap: () => _showSavedProgramDetails(
                context,
                "Data Science Workshop",
                "DataLab Inc.",
              ),
              child: _buildSavedItem("Data Science Workshop", "DataLab Inc."),
            ),

            const SizedBox(height: 30),

            // Bottom Action Buttons - Removed Resume Checker, Submit Hours is clickable
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showSubmitHoursModal(context),
                icon: const Icon(Icons.anchor),
                label: const Text("Submit Training Hours"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6E2F2),
                  foregroundColor: const Color(0xFF284B8C),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF637E99),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    "SJ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sarah Johnson",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Computer Science • Junior",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "ID: 33333333",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 40),
          _buildInfoRow(Icons.email_outlined, "Email", "sarah.johnson@aast.edu"),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.phone_outlined, "Phone", "+20 123 456 7890"),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.workspace_premium_outlined, "GPA", "3.8"),
          const SizedBox(height: 20),
          const Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
          const Text(
            "Passionate computer science student interested in web development and AI.",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocItem(String name, String date, [bool isClickable = false]) {
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
          if (isClickable)
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
        ],
      ),
    );
  }

  Widget _buildSavedItem(String title, String company) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                company,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}