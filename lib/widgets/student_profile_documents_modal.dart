
//new modal document
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentProfileDocumentsModal {
  static void show(BuildContext context, int? profileId,{VoidCallback? onUpdate}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => _DocumentsModalContent(profileId: profileId,
        onUpdate: onUpdate,),
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
      // pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result == null) return; // user cancelled

      setState(() => _isUploading = true);

      final file = result.files.first;
      final fileName = '${widget.profileId}_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final supabase = Supabase.instance.client;

      // upload file to Supabase Storage
      await supabase.storage
          .from('documents')
          .uploadBinary(
        'student_${widget.profileId}/$fileName',
        file.bytes!,
      );

      // get public URL
      final fileUrl = supabase.storage
          .from('documents')
          .getPublicUrl('student_${widget.profileId}/$fileName');

      // save to document table
      await supabase.from('document').insert({
        'ownerprofileid': widget.profileId,
        'documenttype': _selectedType,
        'filepath': fileUrl,

      });

      // refresh list
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

      // extract file path from URL for storage deletion
      final uri = Uri.parse(filePath);
      final storagePath = uri.pathSegments
          .skipWhile((s) => s != 'documents')
          .skip(1)
          .join('/');

      // delete from storage
      await supabase.storage
          .from('documents')
          .remove([storagePath]);

      // delete from document table
      await supabase
          .from('document')
          .delete()
          .eq('documentid', documentId);

      // refresh list
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
          // header
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

          // upload button
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

          // documents list
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
                  Text(
                    "No documents yet",
                    style: TextStyle(color: Colors.grey),
                  ),
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

                return Container(
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
                            Text(
                              doc['documenttype'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _deleteDocument(
                          doc['documentid'].toString(),
                          doc['filepath'] ?? '',
                        ),
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