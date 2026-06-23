import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentProfileSkillsModal {
  static void show(BuildContext context, int studentId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
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
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _categories = ['Technical', 'Soft'];
  String? _bannerMessage;
  bool _isBannerError = false;
  Timer? _bannerTimer;

  final List<String> _commonSkills = [
    'Python', 'Java', 'JavaScript', 'TypeScript', 'C++', 'C#', 'Swift', 'Kotlin',
    'Dart', 'PHP', 'Ruby', 'Go', 'React', 'Flutter', 'Angular', 'Vue.js',
    'Node.js', 'HTML', 'CSS', 'Django', 'Laravel', 'Spring Boot', 'Machine Learning',
    'Data Analysis', 'SQL', 'TensorFlow', 'PyTorch', 'Git', 'Docker', 'AWS', 'Firebase',
    'Supabase', 'Communication', 'Leadership', 'Teamwork', 'Problem Solving',
  ];

  final List<String> _commonInterests = [
    'Web Development', 'Mobile Development', 'Machine Learning', 'Artificial Intelligence',
    'Data Science', 'Cybersecurity', 'Cloud Computing', 'DevOps', 'UI/UX Design',
    'Digital Marketing', 'Entrepreneurship', 'Research', 'Photography', 'Graphic Design',
  ];

  List<String> get _filteredSkillSuggestions {
    final query = _skillController.text.trim().toLowerCase();
    if (query.isEmpty) return [];
    final matches = _commonSkills
        .where((skill) => !_skills.any((s) => s['name']?.toLowerCase() == skill.toLowerCase()))
        .where((skill) => skill.toLowerCase().contains(query))
        .toList();
    matches.sort((a, b) {
      final aStarts = a.toLowerCase().startsWith(query);
      final bStarts = b.toLowerCase().startsWith(query);
      if (aStarts != bStarts) {
        return aStarts ? -1 : 1;
      }
      return a.compareTo(b);
    });
    return matches.take(6).toList();
  }

  List<String> get _filteredInterestSuggestions {
    final query = _interestController.text.trim().toLowerCase();
    if (query.isEmpty) return [];
    final matches = _commonInterests
        .where((interest) => !_interests.any((i) => i.toLowerCase() == interest.toLowerCase()))
        .where((interest) => interest.toLowerCase().contains(query))
        .toList();
    matches.sort((a, b) {
      final aStarts = a.toLowerCase().startsWith(query);
      final bStarts = b.toLowerCase().startsWith(query);
      if (aStarts != bStarts) {
        return aStarts ? -1 : 1;
      }
      return a.compareTo(b);
    });
    return matches.take(6).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchSkills();
  }

  @override
  void dispose() {
    _skillController.dispose();
    _interestController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _showBanner(String message, {bool isError = false}) {
    _bannerTimer?.cancel();
    setState(() {
      _bannerMessage = message;
      _isBannerError = isError;
    });
    _bannerTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _bannerMessage = null);
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

  List<String> _parseInterests(String? interestsStr) {
    if (interestsStr == null || interestsStr.isEmpty) return [];
    return interestsStr.split(',').where((s) => s.trim().isNotEmpty).map((s) => s.trim()).toList();
  }

  String _serializeSkills(List<Map<String, String>> skills) => skills.map((s) => '${s['name']}:${s['level']}:${s['category']}').join(',');
  String _serializeInterests(List<String> interests) => interests.join(',');

  Future<void> _fetchSkills() async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase.from('student').select('skills, interests').eq('studentid', widget.studentId).single();
      setState(() {
        _skills = _parseSkills(data['skills']);
        _interests = _parseInterests(data['interests']);
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveToDatabase() async {
    try {
      setState(() => _isSaving = true);
      await Supabase.instance.client.from('student').update({
        'skills': _serializeSkills(_skills),
        'interests': _serializeInterests(_interests),
      }).eq('studentid', widget.studentId);
      _showBanner('Changes saved!');
    } catch (e) {
      _showBanner('Error saving: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _addSkill() async {
    final name = _skillController.text.trim();
    if (name.isEmpty) return _showBanner('Please enter a skill name', isError: true);
    if (_skills.any((s) => s['name']?.toLowerCase() == name.toLowerCase())) {
      return _showBanner('Skill already added!', isError: true);
    }
    setState(() {
      _skills.add({'name': name, 'level': _selectedLevel, 'category': _selectedCategory});
      _skillController.clear();
    });
    await _saveToDatabase();
  }

  Future<void> _deleteSkill(int index) async {
    setState(() => _skills.removeAt(index));
    await _saveToDatabase();
  }

  Future<void> _addInterest() async {
    final interest = _interestController.text.trim();
    if (interest.isEmpty) return;
    if (_interests.any((i) => i.toLowerCase() == interest.toLowerCase())) {
      return _showBanner('Interest already added!', isError: true);
    }
    setState(() {
      _interests.add(interest);
      _interestController.clear();
    });
    await _saveToDatabase();
  }

  Future<void> _deleteInterest(int index) async {
    setState(() => _interests.removeAt(index));
    await _saveToDatabase();
  }

  Future<void> _selectSkillSuggestion(String skill) async {
    _skillController.text = skill;
    await _addSkill();
  }

  Future<void> _selectInterestSuggestion(String interest) async {
    _interestController.text = interest;
    await _addInterest();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(25.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Skills & Interests", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  IconButton(icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            if (_bannerMessage != null)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
                      padding: EdgeInsets.symmetric(horizontal: 25.w).copyWith(bottom: 150.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Skills", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                          SizedBox(height: 15.h),
                          Container(
                            padding: EdgeInsets.all(15.w),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(15.r),
                              border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _skillController,
                                  decoration: InputDecoration(
                                    hintText: "Type or search a skill...",
                                    hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                  onChanged: (_) => setState(() {}),
                                  onSubmitted: (_) => _addSkill(),
                                ),
                                if (_filteredSkillSuggestions.isNotEmpty) ...[
                                  SizedBox(height: 8.h),
                                  _buildAutocompleteList(
                                    items: _filteredSkillSuggestions,
                                    isDark: isDark,
                                    onTap: _selectSkillSuggestion,
                                  ),
                                ],
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    Expanded(child: _buildDropdown(value: _selectedCategory, items: _categories, isDark: isDark, onChanged: (val) => setState(() => _selectedCategory = val!))),
                                    SizedBox(width: 10.w),
                                    Expanded(child: _buildDropdown(value: _selectedLevel, items: _levels, isDark: isDark, onChanged: (val) => setState(() => _selectedLevel = val!))),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _addSkill,
                                    icon: const Icon(Icons.add),
                                    label: const Text("Add Skill"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF284B8C),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: _skills.asMap().entries.map((e) => _buildSkillChip(e.value['name']!, e.value['level']!, isDark, e.key)).toList(),
                          ),
                          SizedBox(height: 24.h),
                          Text("Interests", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                          SizedBox(height: 15.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _interestController,
                                    decoration: InputDecoration(
                                      hintText: "Add an interest...",
                                      hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                    onChanged: (_) => setState(() {}),
                                    onSubmitted: (_) => _addInterest(),
                                  ),
                                ),
                                IconButton(icon: const Icon(Icons.add, color: Color(0xFF284B8C)), onPressed: _addInterest),
                              ],
                            ),
                          ),
                          if (_filteredInterestSuggestions.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            _buildAutocompleteList(
                              items: _filteredInterestSuggestions,
                              isDark: isDark,
                              onTap: _selectInterestSuggestion,
                            ),
                          ],
                          SizedBox(height: 15.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: _interests.asMap().entries.map((e) => _buildInterestChip(e.value, isDark, e.key)).toList(),
                          ),
                          SizedBox(height: 25.h),
                          Container(
                            padding: EdgeInsets.all(15.w),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF284B8C).withOpacity(0.2) : const Color(0xFFD6E2F2).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: const Color(0xFF284B8C).withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lightbulb_outline, color: isDark ? Colors.white : const Color(0xFF284B8C)),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    "Adding skills and interests helps match you with relevant opportunities and training programs.",
                                    style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(25.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF284B8C),
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  child: Text(_isSaving ? "Saving..." : "Done", style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required bool isDark,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3C3C3C) : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13.sp)),
              ),
            )
            .toList(),
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: isDark ? const Color(0xFF3C3C3C) : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildAutocompleteList({
    required List<String> items,
    required bool isDark,
    required Future<void> Function(String value) onTap,
  }) {
    return Container(
      constraints: BoxConstraints(maxHeight: 180.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3C3C3C) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -2),
            title: Text(
              item,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => onTap(item),
          );
        },
      ),
    );
  }

  Widget _buildSkillChip(String skill, String level, bool isDark, int index) {
    final levelColor = _getLevelColor(level);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(skill, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              level,
              style: TextStyle(
                color: levelColor,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => _deleteSkill(index),
            child: Icon(Icons.close, size: 16.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestChip(String interest, bool isDark, int index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF284B8C).withOpacity(0.2) : const Color(0xFF284B8C).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF284B8C).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(interest, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF284B8C), fontWeight: FontWeight.w500)),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: () => _deleteInterest(index),
            child: Icon(Icons.close, size: 14.sp, color: isDark ? Colors.white70 : const Color(0xFF284B8C)),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'advanced':
        return const Color(0xFF37A95D);
      case 'intermediate':
        return const Color(0xFFF0A11E);
      case 'beginner':
      default:
        return const Color(0xFF4C8DFF);
    }
  }
}
