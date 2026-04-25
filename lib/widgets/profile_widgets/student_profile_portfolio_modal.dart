import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'dart:async';

class StudentProfilePortfolioModal {
  static void show(BuildContext context, int studentId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
  // links stored as list of maps {title, url, type}
  List<Map<String, String>> _links = [];
  bool _isLoading = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  String _selectedType = 'Website';

  // Banner state for in-modal feedback
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
    // Auto-hide banner after 3 seconds
    _bannerTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _bannerMessage = null);
      }
    });
  }

  // parse "Personal Portfolio|https://ahmed.dev|Website,GitHub|https://github.com/ahmed|GitHub"
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

  // convert back to string
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

      // auto add linkedin if exists and not already in list
      final linkedinUrl = data['linkedin_url'] ?? '';
      if (linkedinUrl.isNotEmpty &&
          !links.any((l) => l['type'] == 'LinkedIn')) {
        links.insert(0, {
          'title': 'LinkedIn',
          'url': linkedinUrl,
          'type': 'LinkedIn',
        });
      }

      setState(() {
        _links = links;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching links: $e');
      setState(() => _isLoading = false);
    }
  }

   Future<void> _saveLinks() async {
     try {
       final supabase = Supabase.instance.client;

       // separate linkedin from other links
       final linkedinLink = _links.firstWhere(
             (l) => l['type'] == 'LinkedIn',
         orElse: () => {'url': ''},
       );
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

   void _addLink() {
      final title = _titleController.text.trim();
      final url = _urlController.text.trim();

      if (title.isEmpty || url.isEmpty) {
        _showBanner('Please enter both title and URL', isError: true);
        return;
      }

     // add https:// if missing
     final finalUrl = url.startsWith('http') ? url : 'https://$url';

     setState(() {
       _links.add({
         'title': title,
         'url': finalUrl,
         'type': _selectedType,
       });
       _titleController.clear();
       _urlController.clear();
     });
     _saveLinks();
     _showBanner('Link added successfully!');
   }

  void _deleteLink(int index) {
    setState(() => _links.removeAt(index));
    _saveLinks();
  }

   Future<void> _openLink(String url) async {
     try {
       final uri = Uri.parse(url);
       if (await canLaunchUrl(uri)) {
         await launchUrl(uri, mode: LaunchMode.externalApplication);
       }
      } catch (e) {
        _showBanner('Cannot open this link', isError: true);
     }
   }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'GitHub': return Icons.code;
      case 'LinkedIn': return Icons.work;
      case 'Behance': return Icons.brush;
      case 'Dribbble': return Icons.sports_basketball;
      default: return Icons.link;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
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

          // Feedback banner for in-modal messages
          if (_bannerMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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
                  // tip box
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6E2F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Your professional links help recruiters and program coordinators learn more about your work and experience",
                      style: TextStyle(color: Color(0xFF284B8C), fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Add new link section
                  const Text(
                    "Add New Link",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // type dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedType,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _linkTypes.map((type) => DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(_getIconForType(type), size: 18, color: const Color(0xFF284B8C)),
                            const SizedBox(width: 8),
                            Text(type),
                          ],
                        ),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedType = val!),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // title field
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "Link title (e.g. My Portfolio)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // url field
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: "https://",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add, color: Color(0xFF284B8C)),
                        onPressed: _addLink,
                      ),
                    ),
                    onSubmitted: (_) => _addLink(),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Your Links",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // links list
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _links.isEmpty
                      ? const Center(
                    child: Text(
                      "No links added yet",
                      style: TextStyle(color: Colors.grey),
                    ),
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
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
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
                                  _getIconForType(link['type'] ?? 'Website'),
                                  color: const Color(0xFF284B8C),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      link['title'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      link['url'] ?? '',
                                      style: const TextStyle(
                                        color: Color(0xFF284B8C),
                                        fontSize: 12,
                                      ),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Done button
          Padding(
            padding: const EdgeInsets.only(top: 20),
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
    );
  }
}