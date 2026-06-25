 // Use show to avoid namespace conflicts on web
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' hide FormField;
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import '../utils/profile_provider.dart';
import '../widgets/action_button.dart';
import '../widgets/application_summary_card.dart';
import '../widgets/doc_stat_chip.dart';
import '../widgets/document_item.dart';
import '../widgets/documents_list_section.dart';
import '../widgets/profile_card.dart';
import '../widgets/saved_jobs_sections.dart';
import '../widgets/section_box.dart';
import '../widgets/form_field.dart';
import '../widgets/skill_chip.dart';
import '../../services/fresh_grad_vacancy_service.dart';
import '../../services/app_refresh_service.dart';
import '../../services/user_session.dart';

// ─── Profile Screen ───────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<Skill> _skills = [];
  final List<String> _interests = [];
  final List<PortfolioLink> _portfolioLinks = [];

  List<Document> _documents = [];
  int? _profileId;

  @override
  void initState() {
    super.initState();
    _fetchRealDocuments();
    _loadProfileExtras();
    AppRefreshService.instance.addListener(_handleRefreshSignal);
  }

  @override
  void dispose() {
    AppRefreshService.instance.removeListener(_handleRefreshSignal);
    super.dispose();
  }

  void _handleRefreshSignal() {
    if (!mounted) return;
    _fetchRealDocuments();
    _loadProfileExtras();
    context.read<ProfileProvider>().loadFromDatabase();
  }

  Future<void> _loadProfileExtras() async {
    try {
      final collegeId = UserSession.instance.collegeId;
      if (collegeId == null || collegeId.isEmpty) return;

      final supabase = Supabase.instance.client;
      final row = await supabase
          .from('freshgraduate')
          .select('skills, interests, portfolio_links')
          .eq('college_id', collegeId)
          .maybeSingle();

      if (row == null || !mounted) return;

      final parsedSkills = _parseSkills(row['skills']?.toString());
      final parsedInterests = _parseInterests(row['interests']?.toString());
      final parsedLinks = _parsePortfolioLinks(row['portfolio_links']?.toString());

      setState(() {
        _skills
          ..clear()
          ..addAll(parsedSkills);
        _interests
          ..clear()
          ..addAll(parsedInterests);
        _portfolioLinks
          ..clear()
          ..addAll(parsedLinks);
      });
    } catch (e) {
      debugPrint('Error loading fresh grad profile extras: $e');
    }
  }

  Future<void> _fetchRealDocuments() async {
    try {
      final supabase = Supabase.instance.client;
      _profileId ??= await FreshGradVacancyService.resolveOrCreateProfileId();
      if (_profileId == null) return;

      final rows = await supabase
          .from('document')
          .select('documentid, documenttype, filepath, uploaddate, status')
          .eq('ownerprofileid', _profileId!)
          .order('uploaddate', ascending: false);

      if (mounted) {
        setState(() {
          _documents = List<Map<String, dynamic>>.from(rows).map((row) {
            final filepath = row['filepath']?.toString() ?? '';
            final filename = _extractFileName(filepath);
            final ext = filename.contains('.')
                ? filename.split('.').last.toUpperCase()
                : 'FILE';
            return Document(
              id: row['documentid']?.toString(),
              name: filename,
              type: ext,
              date: _formatUploadDate(row['uploaddate']?.toString()),
              size: 'Uploaded',
              status: _mapStatus(row['status']?.toString()),
              filepath: filepath,
            );
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching documents: $e');
    }
  }

  String _extractFileName(String filepath) {
    try {
      final uri = Uri.parse(filepath);
      final fullName = uri.pathSegments.last;
      final parts = fullName.split('_');
      if (parts.length > 2) return parts.sublist(2).join('_');
      return fullName;
    } catch (_) {
      return 'Document';
    }
  }

  String _formatUploadDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'Recent';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return 'Recent';
    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }

  String _mapStatus(String? status) {
    switch ((status ?? 'PENDING').toUpperCase()) {
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      default:
        return 'Pending Review';
    }
  }

  List<Skill> _parseSkills(String? skillsStr) {
    if (skillsStr == null || skillsStr.trim().isEmpty) return [];
    return skillsStr
        .split(',')
        .where((value) => value.trim().isNotEmpty)
        .map((value) {
          final parts = value.trim().split(':');
          return Skill(
            name: parts.isNotEmpty ? parts[0].trim() : '',
            level: parts.length > 1 ? parts[1].trim() : 'Beginner',
            category: parts.length > 2 ? parts[2].trim() : 'Technical',
          );
        })
        .where((skill) => skill.name.isNotEmpty)
        .toList();
  }

  List<String> _parseInterests(String? interestsStr) {
    if (interestsStr == null || interestsStr.trim().isEmpty) return [];
    return interestsStr
        .split(',')
        .where((value) => value.trim().isNotEmpty)
        .map((value) => value.trim())
        .toList();
  }

  List<PortfolioLink> _parsePortfolioLinks(String? linksStr) {
    if (linksStr == null || linksStr.trim().isEmpty) return [];
    return linksStr
        .split(',')
        .where((value) => value.trim().isNotEmpty)
        .map((value) => value.trim().split('|'))
        .map((parts) {
          final title = parts.isNotEmpty ? parts[0].trim() : 'Website';
          final url = parts.length > 1 ? parts[1].trim() : '';
          final type = parts.length > 2 ? parts[2].trim() : 'Website';
          return _buildPortfolioLink(title: title, url: url, type: type);
        })
        .where((link) => link.url.isNotEmpty)
        .toList();
  }

  String _serializeSkills() => _skills
      .map((skill) => '${skill.name}:${skill.level}:${skill.category}')
      .join(',');

  String _serializeInterests() => _interests.join(',');

  String _serializePortfolioLinks() => _portfolioLinks
      .map((link) => '${link.title}|${link.url}|${_getPortfolioType(link)}')
      .join(',');

  String _getPortfolioType(PortfolioLink link) {
    if (link.icon == Icons.code) return 'GitHub';
    if (link.icon == Icons.work) return 'LinkedIn';
    if (link.icon == Icons.brush) return 'Behance';
    if (link.icon == Icons.sports_basketball) return 'Dribbble';
    return 'Website';
  }

  PortfolioLink _buildPortfolioLink({
    required String title,
    required String url,
    String type = 'Website',
  }) {
    switch (type) {
      case 'GitHub':
        return PortfolioLink(
          title: title,
          url: url,
          icon: Icons.code,
          iconBg: const Color(0xFFEEEEEE),
          iconColor: const Color(0xFF333333),
        );
      case 'LinkedIn':
        return PortfolioLink(
          title: title,
          url: url,
          icon: Icons.work,
          iconBg: const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF0077B5),
        );
      case 'Behance':
        return PortfolioLink(
          title: title,
          url: url,
          icon: Icons.brush,
          iconBg: const Color(0xFFE8EAF6),
          iconColor: const Color(0xFF1769FF),
        );
      case 'Dribbble':
        return PortfolioLink(
          title: title,
          url: url,
          icon: Icons.sports_basketball,
          iconBg: const Color(0xFFFCE4EC),
          iconColor: const Color(0xFFEA4C89),
        );
      default:
        return PortfolioLink(
          title: title,
          url: url,
          icon: Icons.language,
          iconBg: AppColors.lightBlue,
          iconColor: AppColors.accentBlue,
        );
    }
  }

  String _inferPortfolioType(String title, String url) {
    final value = '$title $url'.toLowerCase();
    if (value.contains('github')) return 'GitHub';
    if (value.contains('linkedin')) return 'LinkedIn';
    if (value.contains('behance')) return 'Behance';
    if (value.contains('dribbble')) return 'Dribbble';
    return 'Website';
  }

  Future<void> _saveSkillsAndInterests() async {
    final collegeId = UserSession.instance.collegeId;
    if (collegeId == null || collegeId.isEmpty) return;

    await Supabase.instance.client.from('freshgraduate').update({
      'skills': _serializeSkills(),
      'interests': _serializeInterests(),
    }).eq('college_id', collegeId);
  }

  Future<void> _savePortfolioLinks() async {
    final collegeId = UserSession.instance.collegeId;
    if (collegeId == null || collegeId.isEmpty) return;

    await Supabase.instance.client.from('freshgraduate').update({
      'portfolio_links': _serializePortfolioLinks(),
    }).eq('college_id', collegeId);
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<ProfileProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('My Profile',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Manage your information and documents',
              style: TextStyle(fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
          const SizedBox(height: 20),

          Row(children: [
            ActionButton(label: 'Edit Profile', icon: Icons.edit_outlined,
                bg: AppColors.lightBlue, color: AppColors.accentBlue, isDark: isDark,
                onTap: () => _showEditProfile(context, isDark)),
            const SizedBox(width: 10),
            ActionButton(label: 'Skills & Interests', icon: Icons.military_tech_outlined,
                bg: AppColors.lightGreen, color: AppColors.primaryGreen, isDark: isDark,
                onTap: () => _showSkillsInterests(context, isDark)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            ActionButton(label: 'Documents', icon: Icons.description_outlined,
                bg: AppColors.lightOrange, color: AppColors.accentOrange, isDark: isDark,
                onTap: () => _showDocuments(context, isDark)),
            const SizedBox(width: 10),
            ActionButton(label: 'Portfolio Links', icon: Icons.bookmark_outline,
                bg: const Color(0xFFFCE4EC), color: const Color(0xFFE91E63), isDark: isDark,
                onTap: () => _showPortfolioLinks(context, isDark)),
          ]),
          const SizedBox(height: 20),

          ProfileInfoCard(
            initials: profile.initials,
            firstName: profile.firstName, lastName: profile.lastName,
            major: profile.major, gpa: profile.gpa,
            email: profile.email, phone: profile.phone, bio: profile.bio,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          ApplicationSummaryCard(isDark: isDark),
          const SizedBox(height: 16),
          DocumentsListSection(documents: _documents, isDark: isDark,
              onManage: () => _showDocuments(context, isDark)),
          const SizedBox(height: 16),
          SavedJobsSection(isDark: isDark),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showResumeChecker(context, isDark),
              icon: const Icon(Icons.description_outlined, color: Colors.white, size: 18),
              label: const Text('Resume Checker',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.applyButton,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Documents Modal ───────────────────────────────────────────────────────
  void _showDocuments(BuildContext context, bool isDark) {
    bool isUploading = false; 

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        final approved = _documents.where((d) => d.status == 'Approved').length;
        final pending = _documents.where((d) => d.status == 'Pending Review').length;
        final rejected = _documents.where((d) => d.status == 'Rejected').length;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBg : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Document Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                    Text('Upload and manage your documents', style: TextStyle(fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                  ]),
                  GestureDetector(onTap: () => Navigator.pop(ctx),
                      child: Icon(Icons.close, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                ]),
              ),
              Flexible(child: SingleChildScrollView(padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    DocStatChip(value: '${_documents.length}', label: 'Total', bg: AppColors.lightBlue, color: AppColors.accentBlue),
                    const SizedBox(width: 8),
                    DocStatChip(value: '$approved', label: 'Approved', bg: AppColors.lightGreen, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    DocStatChip(value: '$pending', label: 'Pending', bg: AppColors.lightOrange, color: AppColors.accentOrange),
                    const SizedBox(width: 8),
                    DocStatChip(value: '$rejected', label: 'Rejected', bg: const Color(0xFFFCE4EC), color: const Color(0xFFE91E63)),
                  ]),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    ),
                    child: Column(children: [
                      Container(width: 52, height: 52,
                          decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.upload_outlined, color: AppColors.accentBlue, size: 26)),
                      const SizedBox(height: 12),
                      Text('Drop files here or click to upload',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text('PDF, DOC, DOCX up to 10MB',
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                      const SizedBox(height: 14),
                      
                      ElevatedButton(
                  onPressed: isUploading ? null : () async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true, // IMPORTANT: always get bytes (works on all platforms)
    );

    if (result != null) {
      final file = result.files.first;
      final ext = file.extension?.toLowerCase();

      if (ext != 'pdf' && ext != 'doc' && ext != 'docx') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unsupported file. Only PDF, DOC, or DOCX allowed.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (file.bytes == null) {
        throw Exception('File bytes are null (this should not happen).');
      }

      setS(() => isUploading = true);

      final supabase = Supabase.instance.client;
      _profileId ??= await FreshGradVacancyService.resolveOrCreateProfileId();
      if (_profileId == null) {
        throw Exception('No profile found for this account.');
      }
      final uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final storagePath = 'student_$_profileId/$uniqueFileName';

      // ✅ SINGLE upload method for ALL platforms
      await supabase.storage.from('documents').uploadBinary(
        storagePath,
        file.bytes!,
        fileOptions: const FileOptions(upsert: true),
      );

      final fileUrl = supabase.storage.from('documents').getPublicUrl(storagePath);
      final inserted = await supabase
          .from('document')
          .insert({
            'ownerprofileid': _profileId,
            'documenttype': 'ATTACHMENT',
            'filepath': fileUrl,
          })
          .select('documentid, filepath, uploaddate, status')
          .single();

      setState(() {
        _documents.insert(
          0,
          Document(
            id: inserted['documentid']?.toString(),
            name: file.name,
            type: ext!.toUpperCase(),
            date: _formatUploadDate(inserted['uploaddate']?.toString()),
            size: '${(file.size / 1024).toStringAsFixed(0)} KB',
            status: _mapStatus(inserted['status']?.toString()),
            filepath: inserted['filepath']?.toString(),
          ),
        );
      });

      setS(() {});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    setS(() => isUploading = false);
  }
},
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.applyButton,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                        child: isUploading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Browse Files', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  Text('Your Documents', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                  const SizedBox(height: 12),

                  ..._documents.map((doc) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DocumentItem(
                      doc: doc, 
                      isDark: isDark,
                      onDelete: () async {
                        try {
                          final supabase = Supabase.instance.client;
                          if (doc.id == null) {
                            throw Exception('Document id is missing.');
                          }

                          final linkedApplications = await supabase
                              .from('application')
                              .select('applicationid')
                              .eq('document_id', doc.id!)
                              .limit(1);

                          if (linkedApplications.isNotEmpty) {
                            await supabase
                                .from('document')
                                .update({'ownerprofileid': null})
                                .eq('documentid', doc.id!);
                          } else {
                            final sharedDocuments = await supabase
                                .from('document')
                                .select('documentid')
                                .eq('filepath', doc.filepath ?? '')
                                .neq('documentid', doc.id!)
                                .limit(1);

                            await supabase
                                .from('document')
                                .delete()
                                .eq('documentid', doc.id!);

                            if (sharedDocuments.isEmpty && doc.filepath != null) {
                              final uri = Uri.parse(doc.filepath!);
                              final storagePath = uri.pathSegments
                                  .skipWhile((s) => s != 'documents')
                                  .skip(1)
                                  .join('/');
                              await supabase.storage
                                  .from('documents')
                                  .remove([storagePath]);
                            }
                          }

                          setState(() {
                            _documents.remove(doc);
                          });
                          setS(() {});

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Document removed from your profile.',
                                ),
                                backgroundColor: Colors.blueGrey,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      }
                    ),
                  )),
                ]),
              )),

              Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(width: double.infinity,
                  child: ElevatedButton(onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.applyButton,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
              ),
            ]),
          ),
        );
      }),
    );
  }

  // ─── Edit Profile Modal ────────────────────────────────────────────────────
  void _showEditProfile(BuildContext context, bool isDark) {
    final profile = context.read<ProfileProvider>();
    final fnCtrl = TextEditingController(text: profile.firstName);
    final lnCtrl = TextEditingController(text: profile.lastName);
    final emailCtrl = TextEditingController(text: profile.email);
    final phoneCtrl = TextEditingController(text: profile.phone);
    final bioCtrl = TextEditingController(text: profile.bio);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBg : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                  GestureDetector(onTap: () => Navigator.pop(ctx),
                      child: Icon(Icons.close, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                ]),
              ),
              const SizedBox(height: 16),
              Flexible(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Center(child: Stack(children: [
                    Container(width: 80, height: 80,
                      decoration: BoxDecoration(color: AppColors.accentBlue.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16)),
                      child: Center(child: Text('${fnCtrl.text.isNotEmpty ? fnCtrl.text[0] : ''}${lnCtrl.text.isNotEmpty ? lnCtrl.text[0] : ''}'.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
                    ),
                    Positioned(bottom: 0, right: 0,
                      child: Container(width: 26, height: 26,
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
                          child: const Icon(Icons.camera_alt, size: 14, color: Colors.grey)),
                    ),
                  ])),
                  const SizedBox(height: 6),
                  Center(child: Text('ID: ${UserSession.instance.userId ?? ''}', style: TextStyle(fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary))),
                  const SizedBox(height: 20),

                  SectionBox(title: 'Basic Information', isDark: isDark, children: [
                    Row(children: [
                      Expanded(child: FormField(label: 'First Name', controller: fnCtrl,
                          icon: Icons.person_outline, isDark: isDark, readOnly: true)),
                      const SizedBox(width: 10),
                      Expanded(child: FormField(label: 'Last Name', controller: lnCtrl,
                          icon: Icons.person_outline, isDark: isDark, readOnly: true)),
                    ]),
                    const SizedBox(height: 12),
                    FormField(label: 'Email', controller: emailCtrl,
                        icon: Icons.email_outlined, isDark: isDark),
                    const SizedBox(height: 12),
                    FormField(label: 'Phone Number', controller: phoneCtrl,
                        icon: Icons.phone_outlined, isDark: isDark),
                    const SizedBox(height: 10),
                    Text('Name is managed by the university and cannot be edited.',
                        style: TextStyle(fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                  ]),
                  const SizedBox(height: 12),

                  SectionBox(title: 'Academic Information', isDark: isDark, children: [
                    FormField(label: 'Major', controller: profile.major.isEmpty ? TextEditingController(text: 'N/A') : TextEditingController(text: profile.major), isDark: isDark, readOnly: true),
                    const SizedBox(height: 12),
                    FormField(label: 'Academic Year', controller: TextEditingController(text: profile.academicYear.isEmpty ? 'Graduate' : profile.academicYear), isDark: isDark, readOnly: true),
                    const SizedBox(height: 12),
                    FormField(label: 'GPA', controller: TextEditingController(text: profile.gpa), icon: Icons.school_outlined, isDark: isDark, readOnly: true),
                  ]),
                  const SizedBox(height: 12),

                  SectionBox(title: 'Bio', isDark: isDark, children: [
                    StatefulBuilder(builder: (_, setBio) => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: bioCtrl,
                            maxLines: 4,
                            maxLength: 500,
                            onChanged: (_) => setBio(() {}),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding: const EdgeInsets.all(12),
                              hintText: 'Write about yourself...',
                              hintStyle: TextStyle(fontSize: 13,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                            ),
                            style: TextStyle(fontSize: 13,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                          ),
                        ),
                        Text('${bioCtrl.text.length}/500',
                            style: TextStyle(fontSize: 11,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 20),
                ]),
              )),

              Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Row(children: [
                  Expanded(child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Cancel', style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final supabase = Supabase.instance.client;
                        await supabase
                            .from('freshgraduate')
                            .update({
                              'email': emailCtrl.text.trim(),
                              'phone': phoneCtrl.text.trim(),
                              'bio': bioCtrl.text.trim(),
                            })
                            .eq('college_id', profile.collegeId);
                        await profile.loadFromDatabase();
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              content: AwesomeSnackbarContent(
                                title: 'Success',
                                message: 'Profile updated successfully!',
                                contentType: ContentType.success,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            content: AwesomeSnackbarContent(
                              title: 'Error',
                              message: 'Error saving profile: $e',
                              contentType: ContentType.failure,
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save_outlined, size: 16, color: Colors.white),
                    label: const Text('Save Changes',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.applyButton,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  )),
                ]),
              ),
            ]),
          ),
        );
      }),
    );
  }

  // ─── Skills & Interests Modal ──────────────────────────────────────────────
  void _showSkillsInterests(BuildContext context, bool isDark) {
    final skillCtrl = TextEditingController();
    final interestCtrl = TextEditingController();
    String skillCategory = 'Technical';
    String skillLevel = 'Beginner';
    final categories = ['Technical', 'Soft'];
    final levels = ['Beginner', 'Intermediate', 'Advanced'];

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        final techSkills = _skills.where((s) => s.category == 'Technical').toList();
        final softSkills = _skills.where((s) => s.category == 'Soft').toList();

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBg : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Skills & Interests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                  GestureDetector(onTap: () => Navigator.pop(ctx),
                      child: Icon(Icons.close, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                ]),
              ),
              Flexible(child: SingleChildScrollView(padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Row(children: [
                    Icon(Icons.military_tech_outlined, color: AppColors.accentBlue, size: 20),
                    const SizedBox(width: 8),
                    Text('Skills', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                  ]),
                  const SizedBox(height: 12),

                  Container(padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(children: [
                      TextField(controller: skillCtrl,
                        decoration: InputDecoration(
                          hintText: 'Add a new skill...',
                          hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          filled: true,
                          fillColor: isDark ? AppColors.darkCardBg : Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Category', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCardBg : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                              value: skillCategory, isExpanded: true,
                              dropdownColor: isDark ? AppColors.darkCardBg : Colors.white,
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (v) => setS(() => skillCategory = v!),
                            )),
                          ),
                        ])),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Level', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCardBg : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                              value: skillLevel, isExpanded: true,
                              dropdownColor: isDark ? AppColors.darkCardBg : Colors.white,
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                              items: levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                              onChanged: (v) => setS(() => skillLevel = v!),
                            )),
                          ),
                        ])),
                      ]),
                      const SizedBox(height: 10),
                      SizedBox(width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final skillName = skillCtrl.text.trim();
                            if (skillName.isEmpty) return;
                            if (_skills.any((s) => s.name.toLowerCase() == skillName.toLowerCase())) {
                              return;
                            }

                            setState(() => _skills.add(Skill(
                                  name: skillName,
                                  category: skillCategory,
                                  level: skillLevel,
                                )));
                            setS(() {});
                            skillCtrl.clear();
                            await _saveSkillsAndInterests();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.applyButton,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                          child: const Text('+ Add Skill', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  if (techSkills.isNotEmpty) ...[
                    Text('Technical Skills', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: techSkills.map((s) => SkillChip(
                      skill: s, bgColor: AppColors.lightBlue, textColor: AppColors.accentBlue,
                      onRemove: () async {
                        setState(() => _skills.remove(s));
                        setS(() {});
                        await _saveSkillsAndInterests();
                      },
                    )).toList()),
                    const SizedBox(height: 14),
                  ],

                  if (softSkills.isNotEmpty) ...[
                    Text('Soft Skills', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: softSkills.map((s) => SkillChip(
                      skill: s, bgColor: AppColors.lightGreen, textColor: AppColors.primaryGreen,
                      onRemove: () async {
                        setState(() => _skills.remove(s));
                        setS(() {});
                        await _saveSkillsAndInterests();
                      },
                    )).toList()),
                    const SizedBox(height: 20),
                  ],

                  Row(children: [
                    Icon(Icons.blur_circular_outlined, color: AppColors.accentBlue, size: 20),
                    const SizedBox(width: 8),
                    Text('Interests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: TextField(controller: interestCtrl,
                      decoration: InputDecoration(
                        hintText: 'Add an interest...',
                        hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    )),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        final interest = interestCtrl.text.trim();
                        if (interest.isNotEmpty &&
                            !_interests.any((i) => i.toLowerCase() == interest.toLowerCase())) {
                          setState(() => _interests.add(interest));
                          setS(() {});
                          interestCtrl.clear();
                          await _saveSkillsAndInterests();
                        }
                      },
                      child: Container(width: 42, height: 42,
                          decoration: BoxDecoration(color: AppColors.accentBlue, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.add, color: Colors.white, size: 22)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: _interests.map((i) =>
                      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.lightOrange, borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(i, style: const TextStyle(fontSize: 13, color: AppColors.accentOrange, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 6),
                          GestureDetector(onTap: () async {
                            setState(() => _interests.remove(i));
                            setS(() {});
                            await _saveSkillsAndInterests();
                          },
                              child: const Icon(Icons.close, size: 14, color: AppColors.accentOrange)),
                        ]),
                      )
                  ).toList()),
                  const SizedBox(height: 16),

                  Container(padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.lightOrange, borderRadius: BorderRadius.circular(12)),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('💡', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Improve Your Profile', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accentOrange)),
                        const SizedBox(height: 4),
                        Text('Adding skills and interests helps match you with relevant opportunities and training programs.',
                            style: TextStyle(fontSize: 12, color: Colors.orange.shade700)),
                      ])),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ]),
              )),

              Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(width: double.infinity,
                  child: ElevatedButton(onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.applyButton,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
              ),
            ]),
          ),
        );
      }),
    );
  }

  // ─── Portfolio Links Modal ─────────────────────────────────────────────────
  void _showPortfolioLinks(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBg : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Portfolio & Links', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                    Text('Share your online presence', style: TextStyle(fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                  ]),
                  GestureDetector(onTap: () => Navigator.pop(ctx),
                      child: Icon(Icons.close, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                ]),
              ),
              Flexible(child: SingleChildScrollView(padding: const EdgeInsets.all(20),
                child: Column(children: [
                  GestureDetector(
                    onTap: () => _showAddLinkDialog(ctx, isDark, setS),
                    child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      ),
                      child: const Center(child: Text('+ Add New Link',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.accentBlue))),
                    ),
                  ),
                  const SizedBox(height: 14),

                  ..._portfolioLinks.map((link) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        Container(width: 38, height: 38,
                            decoration: BoxDecoration(color: link.iconBg, borderRadius: BorderRadius.circular(10)),
                            child: Icon(link.icon, color: link.iconColor, size: 18)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(link.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                          Row(children: [
                            Expanded(child: Text(link.url, style: TextStyle(fontSize: 12, color: AppColors.accentBlue),
                                overflow: TextOverflow.ellipsis)),
                            const Icon(Icons.open_in_new, size: 12, color: AppColors.accentBlue),
                          ]),
                        ])),
                        const SizedBox(width: 8),
                        GestureDetector(
                            onTap: () async {
                              setState(() => _portfolioLinks.remove(link));
                              setS(() {});
                              await _savePortfolioLinks();
                            },
                            child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20)),
                      ]),
                    ),
                  )),
                  const SizedBox(height: 8),

                  Container(padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(12)),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('💡', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Tip: Adding your professional links helps recruiters and program coordinators learn more about your work and experience.',
                          style: TextStyle(fontSize: 12, color: Colors.green.shade700))),
                    ]),
                  ),
                ]),
              )),

              Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(width: double.infinity,
                  child: ElevatedButton(onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.applyButton,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
              ),
            ]),
          ),
        );
      }),
    );
  }

  void _showAddLinkDialog(BuildContext ctx, bool isDark, StateSetter setS) {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    showDialog(context: ctx, builder: (ctx2) => AlertDialog(
      backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
      title: Text('Add New Link', style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Title (e.g. GitHub)',
            labelStyle: TextStyle(color: AppColors.textSecondary))),
        const SizedBox(height: 12),
        TextField(controller: urlCtrl, decoration: InputDecoration(labelText: 'URL',
            labelStyle: TextStyle(color: AppColors.textSecondary))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          final title = titleCtrl.text.trim();
          final rawUrl = urlCtrl.text.trim();
          if (title.isNotEmpty && rawUrl.isNotEmpty) {
            final finalUrl = rawUrl.startsWith('http') ? rawUrl : 'https://$rawUrl';
            final type = _inferPortfolioType(title, finalUrl);
            setState(() => _portfolioLinks.add(_buildPortfolioLink(
                  title: title,
                  url: finalUrl,
                  type: type,
                )));
            setS(() {});
            await _savePortfolioLinks();
          }
          Navigator.pop(ctx2);
        }, child: const Text('Add')),
      ],
    ));
  }

  // ─── Resume Checker Modal ──────────────────────────────────────────────────
  void _showResumeChecker(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBg : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(width: 40, height: 40,
                    decoration: const BoxDecoration(color: Color(0xFFEDE7F6), shape: BoxShape.circle),
                    child: const Icon(Icons.auto_awesome, color: Color(0xFF7C4DFF), size: 20)),
                const SizedBox(width: 12),
                Text('Resume Checker', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
              ]),
              GestureDetector(onTap: () => Navigator.pop(ctx),
                  child: Icon(Icons.close, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
            ]),
            const SizedBox(height: 24),

            Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(children: [
                Container(width: 56, height: 56,
                    decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.upload_outlined, color: AppColors.accentBlue, size: 28)),
                const SizedBox(height: 14),
                Text('Upload Your CV', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text('Click to browse or drag and drop',
                    style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('Supports PDF, DOC, DOCX (Max 5MB)',
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
