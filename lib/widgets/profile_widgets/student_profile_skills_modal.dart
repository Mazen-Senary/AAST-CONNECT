import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'dart:async';

class StudentProfileSkillsModal {
  static void show(BuildContext context, int studentId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => _SkillsModalContent(studentId: studentId),
    );
  }
}

class _SkillsModalContent extends StatefulWidget {
  final int studentId;
  const _SkillsModalContent({required this.studentId});

  @override
  State<_SkillsModalContent> createState() => _SkillsModalContentState();
}

class _SkillsModalContentState extends State<_SkillsModalContent> {
  List<Map<String, String>> _skills = [];
  List<String> _interests = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String _selectedLevel = 'Beginner';
  String _selectedCategory = 'Technical';
  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _categories = ['Technical', 'Soft'];

  // skill name controller for autocomplete
  String _skillInputValue = '';

  // interest name controller for autocomplete
  String _interestInputValue = '';

  // Banner state for in-modal feedback
  String? _bannerMessage;
  bool _isBannerError = false;
  Timer? _bannerTimer;

  final List<String> _commonSkills = [
    // Programming Languages
    'Python', 'Java', 'JavaScript', 'TypeScript', 'C++', 'C#',
    'Swift', 'Kotlin', 'Dart', 'PHP', 'Ruby', 'Go',
    // Web
    'React', 'Flutter', 'Angular', 'Vue.js', 'Node.js',
    'HTML', 'CSS', 'Django', 'Laravel', 'Spring Boot',
    // Data
    'Machine Learning', 'Data Analysis', 'SQL', 'TensorFlow',
    'PyTorch', 'Pandas', 'NumPy', 'Power BI', 'Tableau',
    // Design
    'UI Design', 'UX Design', 'Figma', 'Adobe XD', 'Photoshop',
    'Illustrator', 'Canva',
    // Tools
    'Git', 'Docker', 'AWS', 'Firebase', 'Supabase', 'Linux',
    'Jira', 'Postman',
    // Soft Skills
    'Communication', 'Leadership', 'Teamwork', 'Problem Solving',
    'Time Management', 'Critical Thinking', 'Presentation',
    'Negotiation', 'Adaptability',
    // Business
    'Project Management', 'Agile', 'Scrum', 'Microsoft Office', 'Excel',
  ];

  final List<String> _commonInterests = [
    'Web Development', 'Mobile Development', 'Machine Learning',
    'Artificial Intelligence', 'Data Science', 'Cybersecurity',
    'Cloud Computing', 'DevOps', 'Blockchain', 'Game Development',
    'UI/UX Design', 'Digital Marketing', 'Entrepreneurship',
    'Robotics', 'Internet of Things', 'AR/VR', 'Open Source',
    'Research', 'Teaching', 'Photography', 'Graphic Design',
  ];

  @override
  void initState() {
    super.initState();
    _fetchSkills();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _showBanner(String message, {bool isError = false}) {
    _bannerTimer?.cancel();
    setState(() {
      _bannerMessage = message;
      _isBannerError = isError;
    });
    // Auto-hide banner after 3 seconds
    _bannerTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _bannerMessage = null);
      }
    });
  }

  List<Map<String, String>> _parseSkills(String? skillsStr) {
    if (skillsStr == null || skillsStr.isEmpty) return [];
    return skillsStr.split(',').where((s) => s.trim().isNotEmpty).map((s) {
      final parts = s.trim().split(':');
      return {
        'name': parts[0].trim(),
        'level': parts.length > 1 ? parts[1].trim() : 'Beginner',
        'category': parts.length > 2 ? parts[2].trim() : 'Technical',
      };
    }).toList();
  }

  String _serializeSkills(List<Map<String, String>> skills) {
    return skills.map((s) => '${s['name']}:${s['level']}:${s['category']}').join(',');
  }

  List<String> _parseInterests(String? interestsStr) {
    if (interestsStr == null || interestsStr.isEmpty) return [];
    return interestsStr.split(',').where((s) => s.trim().isNotEmpty).map((s) => s.trim()).toList();
  }

  String _serializeInterests(List<String> interests) {
    return interests.join(',');
  }

  Future<void> _fetchSkills() async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('student')
          .select('skills, interests')
          .eq('studentid', widget.studentId)
          .single();

      setState(() {
        _skills = _parseSkills(data['skills']);
        _interests = _parseInterests(data['interests']);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching skills: $e');
      setState(() => _isLoading = false);
    }
  }

   Future<void> _saveToDatabase() async {
     try {
       setState(() => _isSaving = true);
       final supabase = Supabase.instance.client;
       await supabase.from('student').update({
         'skills': _serializeSkills(_skills),
         'interests': _serializeInterests(_interests),
       }).eq('studentid', widget.studentId);
      } catch (e) {
        _showBanner('Error saving: $e', isError: true);
     } finally {
       setState(() => _isSaving = false);
     }
   }

   void _addSkill() {
     final name = _skillInputValue.trim();
     if (name.isEmpty) {
       _showBanner('Please enter a skill name', isError: true);
       return;
     }
     // check if skill already exists
     if (_skills.any((s) => s['name']?.toLowerCase() == name.toLowerCase())) {
       _showBanner('Skill already added!', isError: true);
       return;
     }
    setState(() {
      _skills.add({
        'name': name,
        'level': _selectedLevel,
        'category': _selectedCategory,
      });
      _skillInputValue = '';
    });
    _showBanner('Skill added successfully!');
    _saveToDatabase();
  }

  void _deleteSkill(int index) {
    setState(() => _skills.removeAt(index));
    _saveToDatabase();
  }

   void _addInterest() {
     final interest = _interestInputValue.trim();
     if (interest.isEmpty) return;
     if (_interests.any((i) => i.toLowerCase() == interest.toLowerCase())) {
       _showBanner('Interest already added!', isError: true);
       return;
     }
    setState(() {
      _interests.add(interest);
      _interestInputValue = '';
    });
    _showBanner('Interest added successfully!');
    _saveToDatabase();
  }

  void _deleteInterest(int index) {
    setState(() => _interests.removeAt(index));
    _saveToDatabase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // header
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
                  icon: Icon(Icons.close,
                      color: isDark ? Colors.white : Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Feedback banner for in-modal messages using AwesomeSnackbar styling
          if (_bannerMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: AwesomeSnackbarContent(
                title: _isBannerError ? 'Error' : 'Success',
                message: _bannerMessage!,
                contentType: _isBannerError ? ContentType.failure : ContentType.success,
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skills section header
                  Text(
                    "Skills",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Add skill form
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2C2C2C)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        // skill autocomplete
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue value) {
                            _skillInputValue = value.text;
                            if (value.text.isEmpty) {
                              return const Iterable<String>.empty();
                            }
                            return _commonSkills.where((skill) =>
                                skill.toLowerCase().contains(
                                  value.text.toLowerCase(),
                                ),
                            );
                          },
                          onSelected: (String selection) {
                            setState(() => _skillInputValue = selection);
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(
                                          option,
                                          style: TextStyle(
                                            color: isDark ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: "Type or search a skill...",
                                hintStyle: TextStyle(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                                ),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 15),

                        // category and level dropdowns
                        Row(
                          children: [
                            Expanded(
                              child: _buildRealDropdown(
                                value: _selectedCategory,
                                items: _categories,
                                isDark: isDark,
                                onChanged: (val) => setState(() => _selectedCategory = val!),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildRealDropdown(
                                value: _selectedLevel,
                                items: _levels,
                                isDark: isDark,
                                onChanged: (val) => setState(() => _selectedLevel = val!),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _addSkill,
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

                  // Technical Skills list
                  if (_skills.where((s) => s['category'] == 'Technical').isNotEmpty) ...[
                    Text(
                      "Technical Skills",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._skills.asMap().entries
                        .where((e) => e.value['category'] == 'Technical')
                        .map((e) => _buildSkillChip(
                      e.value['name']!,
                      e.value['level']!,
                      isDark,
                      e.key,
                    )),
                    const SizedBox(height: 20),
                  ],

                  // Soft Skills list
                  if (_skills.where((s) => s['category'] == 'Soft').isNotEmpty) ...[
                    Text(
                      "Soft Skills",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._skills.asMap().entries
                        .where((e) => e.value['category'] == 'Soft')
                        .map((e) => _buildSkillChip(
                      e.value['name']!,
                      e.value['level']!,
                      isDark,
                      e.key,
                    )),
                    const SizedBox(height: 25),
                  ],

                  // no skills message
                  if (_skills.isEmpty) ...[
                    Center(
                      child: Text(
                        "No skills added yet",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],

                  // Interests section
                  Text(
                    "Interests",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // interest autocomplete field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2C2C2C)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Autocomplete<String>(
                            optionsBuilder: (TextEditingValue value) {
                              _interestInputValue = value.text;
                              if (value.text.isEmpty) {
                                return const Iterable<String>.empty();
                              }
                              return _commonInterests.where((interest) =>
                                  interest.toLowerCase().contains(
                                    value.text.toLowerCase(),
                                  ),
                              );
                            },
                            onSelected: (String selection) {
                              setState(() => _interestInputValue = selection);
                              _addInterest();
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    constraints: const BoxConstraints(maxHeight: 200),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder: (context, index) {
                                        final option = options.elementAt(index);
                                        return ListTile(
                                          title: Text(
                                            option,
                                            style: TextStyle(
                                              color: isDark ? Colors.white : Colors.black,
                                            ),
                                          ),
                                          onTap: () => onSelected(option),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  hintText: "Add an interest...",
                                  hintStyle: TextStyle(
                                    color: isDark ? Colors.grey.shade400 : Colors.grey,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                onSubmitted: (_) => _addInterest(),
                              );
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Color(0xFF284B8C)),
                          onPressed: _addInterest,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // interest chips
                  _interests.isEmpty
                      ? Text(
                    "No interests added yet",
                    style: TextStyle(color: Colors.grey.shade500),
                  )
                      : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _interests.asMap().entries.map((e) =>
                        _buildInterestChip(e.value, isDark, e.key),
                    ).toList(),
                  ),

                  const SizedBox(height: 25),

                  // tip box
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF284B8C).withOpacity(0.2)
                          : const Color(0xFFD6E2F2).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF284B8C).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF284B8C),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Improve Your Profile\nAdding skills and interests helps match you with relevant opportunities and training programs.",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Done button
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
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                child: Text(
                  _isSaving ? "Saving..." : "Done",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealDropdown({
    required String value,
    required List<String> items,
    required bool isDark,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3C3C3C) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 13,
            ),
          ),
        )).toList(),
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: isDark ? const Color(0xFF3C3C3C) : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildSkillChip(String skill, String level, bool isDark, int index) {
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
          Row(
            children: [
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
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _deleteSkill(index),
                child: Icon(Icons.close, size: 16, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterestChip(String interest, bool isDark, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF284B8C).withOpacity(0.2)
            : const Color(0xFF284B8C).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF284B8C).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            interest,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF284B8C),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _deleteInterest(index),
            child: Icon(
              Icons.close,
              size: 14,
              color: isDark ? Colors.white70 : const Color(0xFF284B8C),
            ),
          ),
        ],
      ),
    );
  }
}