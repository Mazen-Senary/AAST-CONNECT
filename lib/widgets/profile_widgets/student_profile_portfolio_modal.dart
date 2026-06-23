import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentProfilePortfolioModal {
  static void show(BuildContext context, int studentId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      builder: (context) => _PortfolioModalContent(studentId: studentId),
    );
  }
}

class _PortfolioModalContent extends StatefulWidget {
  final int studentId;
  const _PortfolioModalContent({required this.studentId});

  @override
  State<_PortfolioModalContent> createState() => _PortfolioModalContentState();
}

class _PortfolioModalContentState extends State<_PortfolioModalContent> {
  List<Map<String, String>> _links = [];
  bool _isLoading = true;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  String _selectedType = 'Website';
  String? _bannerMessage;
  bool _isBannerError = false;
  Timer? _bannerTimer;
  final List<String> _linkTypes = ['Website', 'GitHub', 'LinkedIn', 'Behance', 'Dribbble', 'Other'];

  @override
  void initState() {
    super.initState();
    _fetchLinks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
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

  List<Map<String, String>> _parseLinks(String? linksStr) {
    if (linksStr == null || linksStr.isEmpty) return [];
    return linksStr.split(',').where((s) => s.trim().isNotEmpty).map((s) {
      final parts = s.trim().split('|');
      return {
        'title': parts.isNotEmpty ? parts[0].trim() : '',
        'url': parts.length > 1 ? parts[1].trim() : '',
        'type': parts.length > 2 ? parts[2].trim() : 'Website',
      };
    }).toList();
  }

  String _serializeLinks(List<Map<String, String>> links) {
    return links.map((l) => '${l['title']}|${l['url']}|${l['type']}').join(',');
  }

  Future<void> _fetchLinks() async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('student')
          .select('portfolio_links, linkedin_url')
          .eq('studentid', widget.studentId)
          .single();
      final links = _parseLinks(data['portfolio_links']);
      final linkedinUrl = data['linkedin_url'] ?? '';
      if (linkedinUrl.isNotEmpty && !links.any((l) => l['type'] == 'LinkedIn')) {
        links.insert(0, {'title': 'LinkedIn', 'url': linkedinUrl, 'type': 'LinkedIn'});
      }
      setState(() {
        _links = links;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLinks() async {
    try {
      final supabase = Supabase.instance.client;
      final linkedinLink = _links.firstWhere((l) => l['type'] == 'LinkedIn', orElse: () => {'url': ''});
      final otherLinks = _links.where((l) => l['type'] != 'LinkedIn').toList();
      await supabase.from('student').update({
        'portfolio_links': _serializeLinks(otherLinks),
        'linkedin_url': linkedinLink['url'] ?? '',
      }).eq('studentid', widget.studentId);
      _showBanner('Changes saved!');
    } catch (e) {
      _showBanner('Error saving: $e', isError: true);
    }
  }

  Future<void> _addLink() async {
    final title = _titleController.text.trim();
    final url = _urlController.text.trim();
    if (title.isEmpty || url.isEmpty) {
      _showBanner('Please enter both title and URL', isError: true);
      return;
    }
    final finalUrl = url.startsWith('http') ? url : 'https://$url';
    setState(() {
      _links.add({'title': title, 'url': finalUrl, 'type': _selectedType});
      _titleController.clear();
      _urlController.clear();
    });
    await _saveLinks();
  }

  Future<void> _deleteLink(int index) async {
    setState(() => _links.removeAt(index));
    await _saveLinks();
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showBanner('Cannot open this link', isError: true);
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'GitHub':
        return Icons.code;
      case 'LinkedIn':
        return Icons.work;
      case 'Behance':
        return Icons.brush;
      case 'Dribbble':
        return Icons.sports_basketball;
      default:
        return Icons.link;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    InputDecoration fieldDecoration(String hint, {Widget? suffixIcon}) {
      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.45)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? const Color(0xFF232A33) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: isDark ? 0.85 : 0.55),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      );
    }

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: EdgeInsets.all(25.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Portfolio Links", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: 10.h),
            if (_bannerMessage != null)
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                child: AwesomeSnackbarContent(
                  title: _isBannerError ? 'Error' : 'Success',
                  message: _bannerMessage!,
                  contentType: _isBannerError ? ContentType.failure : ContentType.success,
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(15.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1D3143)
                            : const Color(0xFFD6E2F2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        "Your professional links help recruiters and program coordinators learn more about your work and experience",
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF284B8C),
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text("Add New Link", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF232A33) : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(
                            alpha: isDark ? 0.85 : 0.55,
                          ),
                        ),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedType,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: isDark ? const Color(0xFF232A33) : Colors.white,
                        items: _linkTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Row(
                                  children: [
                                    Icon(_getIconForType(type), size: 18.sp, color: const Color(0xFF284B8C)),
                                    SizedBox(width: 8.w),
                                    Text(
                                      type,
                                      style: TextStyle(color: scheme.onSurface),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _selectedType = val!),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: _titleController,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: fieldDecoration("Link title (e.g. My Portfolio)"),
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: _urlController,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: fieldDecoration(
                        "https://",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add, color: Color(0xFF284B8C)),
                          onPressed: _addLink,
                        ),
                      ),
                      onSubmitted: (_) => _addLink(),
                    ),
                    SizedBox(height: 20.h),
                    Text("Your Links", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15.h),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _links.isEmpty
                            ? Center(
                                child: Text("No links added yet", style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _links.length,
                                itemBuilder: (context, index) {
                                  final link = _links[index];
                                  return GestureDetector(
                                    onTap: () => _openLink(link['url'] ?? ''),
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 10.h),
                                      padding: EdgeInsets.all(15.w),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(15.r),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10.w),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFD6E2F2),
                                              borderRadius: BorderRadius.circular(10.r),
                                            ),
                                            child: Icon(_getIconForType(link['type'] ?? 'Website'), color: const Color(0xFF284B8C)),
                                          ),
                                          SizedBox(width: 15.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(link['title'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                                                Text(
                                                  link['url'] ?? '',
                                                  style: TextStyle(color: const Color(0xFF284B8C), fontSize: 12.sp),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            onPressed: () => _deleteLink(index),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF284B8C),
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Done", style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
