import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentProfileDocumentsModal {
  static void show(BuildContext context, int? profileId, {VoidCallback? onUpdate}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      builder: (context) => _DocumentsModalContent(
        profileId: profileId,
        onUpdate: onUpdate,
      ),
    );
  }
}

class _DocumentsModalContent extends StatefulWidget {
  final VoidCallback? onUpdate;
  final int? profileId;

  const _DocumentsModalContent({required this.profileId, this.onUpdate});

  @override
  State<_DocumentsModalContent> createState() => _DocumentsModalContentState();
}

class _DocumentsModalContentState extends State<_DocumentsModalContent> {
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = true;
  bool _isUploading = false;
  String _selectedType = 'CV';

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('document')
          .select()
          .eq('ownerprofileid', widget.profileId ?? 0)
          .order('uploaddate', ascending: false);

      setState(() {
        _documents = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );
      if (result == null) return;

      setState(() => _isUploading = true);

      final file = result.files.first;
      final originalFileName = file.name;
      final storagePath =
          'student_${widget.profileId}/${widget.profileId}_${DateTime.now().millisecondsSinceEpoch}_$originalFileName';
      final supabase = Supabase.instance.client;

      await supabase.storage.from('documents').uploadBinary(storagePath, file.bytes!);
      final fileUrl = supabase.storage.from('documents').getPublicUrl(storagePath);

      await supabase.from('document').insert({
        'ownerprofileid': widget.profileId,
        'documenttype': _selectedType,
        'filepath': fileUrl,
      });

      await _fetchDocuments();
      widget.onUpdate?.call();
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: AwesomeSnackbarContent(
            title: 'Success',
            message: 'Document uploaded successfully!',
            contentType: ContentType.success,
          ),
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: 'Error uploading: $e',
            contentType: ContentType.failure,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteDocument(String documentId, String filePath) async {
    try {
      final supabase = Supabase.instance.client;
      final linkedApplications = await supabase
          .from('application')
          .select('applicationid')
          .eq('document_id', documentId)
          .limit(1);

      final isUsedByApplication = linkedApplications.isNotEmpty;

      if (isUsedByApplication) {
        await supabase
            .from('document')
            .update({'ownerprofileid': null})
            .eq('documentid', documentId);

        await _fetchDocuments();
        widget.onUpdate?.call();
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: AwesomeSnackbarContent(
              title: 'Removed',
              message:
                  'Document removed from your profile and kept for submitted applications.',
              contentType: ContentType.success,
            ),
          ),
        );
        return;
      }

      final sharedDocuments = await supabase
          .from('document')
          .select('documentid')
          .eq('filepath', filePath)
          .neq('documentid', documentId)
          .limit(1);

      await supabase.from('document').delete().eq('documentid', documentId);

      if (sharedDocuments.isEmpty) {
        final uri = Uri.parse(filePath);
        final storagePath = uri.pathSegments
            .skipWhile((s) => s != 'documents')
            .skip(1)
            .join('/');
        await supabase.storage.from('documents').remove([storagePath]);
      }

      await _fetchDocuments();
      widget.onUpdate?.call();
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: AwesomeSnackbarContent(
            title: 'Success',
            message: 'Document deleted!',
            contentType: ContentType.success,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: 'Error deleting: $e',
            contentType: ContentType.failure,
          ),
        ),
      );
    }
  }

  Future<void> _openDocument(String filePath) async {
    try {
      final uri = Uri.parse(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
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

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(25.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Document Type",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            _buildTypeOption('CV', Icons.description, 'Your resume or CV'),
            _buildTypeOption('CERTIFICATE', Icons.workspace_premium, 'Training certificate'),
            _buildTypeOption('ATTACHMENT', Icons.attach_file, 'Cover letter or other'),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String type, IconData icon, String subtitle) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: const Color(0xFFD6E2F2),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: const Color(0xFF284B8C)),
      ),
      title: Text(type),
      subtitle: Text(subtitle),
      onTap: () {
        setState(() => _selectedType = type);
        Navigator.pop(context);
        _uploadDocument();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(25.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Documents",
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _showUploadOptions,
              icon: _isUploading
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.upload),
              label: Text(_isUploading ? "Uploading..." : "Upload New Document"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF284B8C),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50.h),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Your Documents",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15.h),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _documents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open, size: 50.sp, color: Colors.grey),
                              SizedBox(height: 10.h),
                              Text("No documents yet", style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                              Text(
                                "Upload your CV, certificates or other files",
                                style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _documents.length,
                          itemBuilder: (context, index) {
                            final doc = _documents[index];
                            final uploadDate = doc['uploaddate'] != null
                                ? DateTime.parse(doc['uploaddate'])
                                : DateTime.now();
                            final dateStr = "${uploadDate.day}/${uploadDate.month}/${uploadDate.year}";
                            final realFileName = _extractFileName(doc['filepath'] ?? '');
                            return GestureDetector(
                              onTap: () => _openDocument(doc['filepath'] ?? ''),
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
                                      child: const Icon(
                                        Icons.file_present,
                                        color: Color(0xFF284B8C),
                                      ),
                                    ),
                                    SizedBox(width: 15.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            realFileName,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "${doc['documenttype']} • $dateStr",
                                            style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => _deleteDocument(
                                        doc['documentid'].toString(),
                                        doc['filepath'] ?? '',
                                      ),
                                    ),
                                  ],
                                ),
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
