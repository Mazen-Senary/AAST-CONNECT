import 'package:flutter/material.dart';

class StudentOpportunities extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;
  const StudentOpportunities({super.key, required this.toggleTheme, required this.isDark});

  @override
  State<StudentOpportunities> createState() => _StudentOpportunitiesState();
}

class _StudentOpportunitiesState extends State<StudentOpportunities> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _showFilters = false;

  final List<Map<String, dynamic>> _allPrograms = [
    {
      'title': 'Database Management',
      'company': 'AAST IT',
      'hours': '30h',
      'location': 'On Campus',
      'category': 'IT',
      'type': 'Training',
      'applied': false,
      'description': 'Learn advanced database management systems, SQL optimization, and data modeling. Perfect for computer science students.',
      'requirements': 'Basic SQL knowledge, Database fundamentals',
      'duration': '6 weeks',
      'startDate': 'March 1, 2024',
      'icon': Icons.storage,
      'color': Colors.blue.shade100,
    },
    {
      'title': 'Mobile App Dev',
      'company': 'App Studio',
      'hours': '50h',
      'location': 'Online',
      'category': 'Development',
      'type': 'Internship',
      'applied': true,
      'description': 'Build cross-platform mobile applications using Flutter. Work on real projects with industry mentors.',
      'requirements': 'Basic programming knowledge, OOP concepts',
      'duration': '10 weeks',
      'startDate': 'April 15, 2024',
      'icon': Icons.phone_android,
      'color': Colors.green.shade100,
    },
    {
      'title': 'Backend Intern',
      'company': 'DevCo',
      'hours': '640h',
      'location': 'On-site',
      'category': 'Development',
      'type': 'Internship',
      'applied': false,
      'description': 'Intensive backend development internship working with Node.js, Python, and cloud services.',
      'requirements': 'Python/JavaScript, API basics',
      'duration': '4 months',
      'startDate': 'May 1, 2024',
      'icon': Icons.computer,
      'color': Colors.purple.shade100,
    },
    {
      'title': 'Cybersecurity',
      'company': 'Security Plus',
      'hours': '25h',
      'location': 'Hybrid',
      'category': 'Security',
      'type': 'Workshop',
      'applied': false,
      'description': 'Introduction to ethical hacking, network security, and penetration testing.',
      'requirements': 'Networking basics, Linux fundamentals',
      'duration': '5 days',
      'startDate': 'March 20, 2024',
      'icon': Icons.security,
      'color': Colors.red.shade100,
    },
    {
      'title': 'UI/UX Design',
      'company': 'Creative Agency',
      'hours': '520h',
      'location': 'Hybrid',
      'category': 'Design',
      'type': 'Training',
      'applied': false,
      'description': 'Master UI/UX design principles, Figma, and user research methods.',
      'requirements': 'Creativity, basic design tools',
      'duration': '3 months',
      'startDate': 'April 10, 2024',
      'icon': Icons.design_services,
      'color': Colors.orange.shade100,
    },
    {
      'title': 'Data Science',
      'company': 'DataLab Inc.',
      'hours': '60h',
      'location': 'Online',
      'category': 'Data',
      'type': 'Training',
      'applied': false,
      'description': 'Learn data analysis, machine learning, and visualization with Python.',
      'requirements': 'Python, Statistics basics',
      'duration': '8 weeks',
      'startDate': 'May 5, 2024',
      'icon': Icons.analytics,
      'color': Colors.teal.shade100,
    },
    {
      'title': 'Cloud Computing',
      'company': 'CloudTech',
      'hours': '45h',
      'location': 'Online',
      'category': 'Cloud',
      'type': 'Workshop',
      'applied': false,
      'description': 'AWS and Azure fundamentals, cloud architecture, and deployment.',
      'requirements': 'Networking basics',
      'duration': '6 weeks',
      'startDate': 'June 1, 2024',
      'icon': Icons.cloud,
      'color': Colors.lightBlue.shade100,
    },
    {
      'title': 'AI & Machine Learning',
      'company': 'AI Lab',
      'hours': '80h',
      'location': 'Hybrid',
      'category': 'AI',
      'type': 'Training',
      'applied': false,
      'description': 'Deep learning, neural networks, and AI applications.',
      'requirements': 'Python, Linear Algebra',
      'duration': '12 weeks',
      'startDate': 'April 22, 2024',
      'icon': Icons.psychology,
      'color': Colors.indigo.shade100,
    },
  ];

  List<Map<String, dynamic>> get _filteredPrograms {
    return _allPrograms.where((program) {
      final matchesSearch = _searchQuery.isEmpty ||
          program['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          program['company'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          program['category'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'All' || program['category'] == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<String> get _categories {
    final categories = _allPrograms.map((p) => p['category'] as String).toSet().toList();
    categories.insert(0, 'All');
    return categories;
  }

  void _showApplyModal(BuildContext context, String title) {
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
              "Apply for $title",
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Application Submitted Successfully!"),
                    ),
                  );
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

  void _showDetailsModal(BuildContext context, Map<String, dynamic> program) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    program['title'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text(
              program['company'],
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: program['color'],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(program['icon'], size: 30),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${program['hours']} • ${program['location']}'),
                        Text('Type: ${program['type']}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(program['description']),
            
            const SizedBox(height: 20),
            
            const Text(
              'Requirements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(program['requirements']),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Start Date: ${program['startDate']}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Duration: ${program['duration']}'),
              ],
            ),
            
            const Spacer(),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Color(0xFF284B8C)),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF284B8C),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showApplyModal(context, program['title']);
                    },
                    child: const Text(
                      'Apply Now',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, 
                       color: const Color(0xFF284B8C)),
            onPressed: widget.toggleTheme,
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout, color: Colors.grey, size: 18),
            label: const Text(
              "Logout",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search programs...",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_outlined),
                            onPressed: () {
                              setState(() {
                                _showFilters = !_showFilters;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Filters
                if (_showFilters) ...[
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: _selectedFilter == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = category;
                              });
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: const Color(0xFFD6E2F2),
                            checkmarkColor: const Color(0xFF284B8C),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_filteredPrograms.length} programs available",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (_searchQuery.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                        child: const Text('Clear Search'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Programs List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredPrograms.length,
              itemBuilder: (context, index) {
                final program = _filteredPrograms[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: program['color'],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(program['icon'], size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  program['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  program['company'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6E2F2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              program['type'],
                              style: const TextStyle(
                                color: Color(0xFF284B8C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "${program['hours']} • ${program['location']}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _showDetailsModal(context, program),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(color: Color(0xFF284B8C)),
                              ),
                              child: const Text(
                                'View Details',
                                style: TextStyle(color: Color(0xFF284B8C)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: program['applied'] 
                                ? () => _showDetailsModal(context, program)
                                : () => _showApplyModal(context, program['title']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: program['applied']
                                    ? Colors.grey.shade200
                                    : const Color(0xFF637E99),
                                foregroundColor: program['applied'] ? Colors.black87 : Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                program['applied'] ? 'Applied' : 'Apply Now',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}