
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // NEW: for opening documents

class StudentProfileDocumentsModal {
  static void show(BuildContext context, int? profileId, {VoidCallback? onUpdate}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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

  const _DocumentsModalContent({
    required this.profileId,
    this.onUpdate,
  });

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
      print('Error fetching documents: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result == null) return;

      setState(() => _isUploading = true);

      final file = result.files.first;
      // CHANGED: store original filename separately for display
      final originalFileName = file.name;
      final storagePath = 'student_${widget.profileId}/${widget.profileId}_${DateTime.now().millisecondsSinceEpoch}_$originalFileName';
      final supabase = Supabase.instance.client;

      await supabase.storage
          .from('documents')
          .uploadBinary(storagePath, file.bytes!);

      final fileUrl = supabase.storage
          .from('documents')
          .getPublicUrl(storagePath);

      // CHANGED: removed 'filename' field (not in DB schema)
      // original filename is extracted from filepath URL when displaying
      await supabase.from('document').insert({
        'ownerprofileid': widget.profileId,
        'documenttype': _selectedType,
        'filepath': fileUrl,
      });

      await _fetchDocuments();
      widget.onUpdate?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Document uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteDocument(String documentId, String filePath) async {
    try {
      final supabase = Supabase.instance.client;

      final uri = Uri.parse(filePath);
      final storagePath = uri.pathSegments
          .skipWhile((s) => s != 'documents')
          .skip(1)
          .join('/');

      await supabase.storage.from('documents').remove([storagePath]);

      await supabase
          .from('document')
          .delete()
          .eq('documentid', documentId);

      await _fetchDocuments();
      widget.onUpdate?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Document deleted!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting: $e")),
      );
    }
  }

  // NEW: opens document URL in browser/PDF viewer
  Future<void> _openDocument(String filePath) async {
    try {
      final uri = Uri.parse(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot open this file")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error opening file: $e")),
      );
    }
  }

  // NEW: extracts real filename from the storage URL
  String _extractFileName(String filepath) {
    try {
      final uri = Uri.parse(filepath);
      final fullName = uri.pathSegments.last;
      // storage path is: profileId_timestamp_originalfilename.pdf
      // split by _ and skip first 2 parts (profileId and timestamp)
      final parts = fullName.split('_');
      if (parts.length > 2) {
        return parts.sublist(2).join('_');
      }
      return fullName;
    } catch (e) {
      return 'Document';
    }
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Document Type",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFD6E2F2),
          borderRadius: BorderRadius.circular(8),
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
    return Container(
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
            onPressed: _isUploading ? null : _showUploadOptions,
            icon: _isUploading
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.upload),
            label: Text(_isUploading ? "Uploading..." : "Upload New Document"),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _documents.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No documents yet", style: TextStyle(color: Colors.grey)),
                  Text(
                    "Upload your CV, certificates or other files",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
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

                // CHANGED: extract real filename from URL instead of showing type
                final realFileName = _extractFileName(doc['filepath'] ?? '');

                // CHANGED: wrapped in GestureDetector to open document on tap
                return GestureDetector(
                  onTap: () => _openDocument(doc['filepath'] ?? ''),
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
                              // CHANGED: shows real filename now
                              Text(
                                realFileName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              // shows type + date
                              Text(
                                "${doc['documenttype']} • $dateStr",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
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
    );
  }
}