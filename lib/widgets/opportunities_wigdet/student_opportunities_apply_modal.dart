//new code
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/vacancy_service.dart';
import '../../services/user_session.dart';

class StudentOpportunitiesApplyModal {
  static void show(
      BuildContext context,
      Map<String, dynamic> program,
      VoidCallback? onConfirm, {
        int? profileId,
        int? studentId,
        String? collegeId,
        String? studentName,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => _ApplyModalContent(
        program: program,
        onConfirm: onConfirm,
        profileId: profileId,
        studentId: studentId,
        collegeId: collegeId,
        studentName: studentName,
      ),
    );
  }
}

class _ApplyModalContent extends StatefulWidget {
  final Map<String, dynamic> program;
  final VoidCallback? onConfirm;
  final int? profileId;
  final int? studentId;
  final String? collegeId;
  final String? studentName;

  const _ApplyModalContent({
    required this.program,
    this.onConfirm,
    this.profileId,
    this.studentId,
    this.collegeId,
    this.studentName,
  });

  @override
  State<_ApplyModalContent> createState() => _ApplyModalContentState();
}

class _ApplyModalContentState extends State<_ApplyModalContent> {
  final TextEditingController _coverLetterController = TextEditingController();

  List<Map<String, dynamic>> _cvDocuments = [];
  String? _selectedDocumentId;
  String? _selectedDocumentName;
  bool _isLoadingCVs = true;
  bool _isSubmitting = false;
  bool _isUploadingCV = false;

  @override
  void initState() {
    super.initState();
    _fetchCVDocuments();
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _fetchCVDocuments() async {
    try {
      if (widget.profileId == null) {
        setState(() => _isLoadingCVs = false);
        return;
      }

      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('document')
          .select()
          .eq('ownerprofileid', widget.profileId!)
          .eq('documenttype', 'CV')
          .order('uploaddate', ascending: false);

      setState(() {
        _cvDocuments = List<Map<String, dynamic>>.from(data);
        // auto select first CV if available
        if (_cvDocuments.isNotEmpty) {
          _selectedDocumentId = _cvDocuments.first['documentid'].toString();
          _selectedDocumentName = _extractFileName(
            _cvDocuments.first['filepath'] ?? '',
          );
        }
        _isLoadingCVs = false;
      });
    } catch (e) {
      print('Error fetching CVs: $e');
      setState(() => _isLoadingCVs = false);
    }
  }

  // extract real filename from storage URL
  String _extractFileName(String filepath) {
    try {
      final uri = Uri.parse(filepath);
      final fullName = uri.pathSegments.last;
      final parts = fullName.split('_');
      if (parts.length > 2) return parts.sublist(2).join('_');
      return fullName;
    } catch (e) {
      return 'CV Document';
    }
  }

  Future<void> _uploadNewCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result == null) return;

      setState(() => _isUploadingCV = true);

      final file = result.files.first;
      final supabase = Supabase.instance.client;
      final storagePath =
          'student_${widget.profileId}/${widget.profileId}_${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      // upload to storage
      await supabase.storage
          .from('documents')
          .uploadBinary(storagePath, file.bytes!);

      // get public URL
      final fileUrl = supabase.storage
          .from('documents')
          .getPublicUrl(storagePath);

      // save to document table
      final inserted = await supabase
          .from('document')
          .insert({
        'ownerprofileid': widget.profileId,
        'documenttype': 'CV',
        'filepath': fileUrl,
      })
          .select()
          .single();

      // refresh CV list and auto select new one
      await _fetchCVDocuments();

      setState(() {
        _selectedDocumentId = inserted['documentid'].toString();
        _selectedDocumentName = file.name;
        _isUploadingCV = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("CV uploaded successfully!")),
      );
    } catch (e) {
      setState(() => _isUploadingCV = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading CV: $e")),
      );
    }
  }

  Future<void> _submitApplication() async {
    if (_selectedDocumentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select or upload a CV first")),
      );
      return;
    }

    if (_coverLetterController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write a cover letter")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final vacancyService = VacancyService();
      await vacancyService.submitApplication(
        vacancyId: widget.program['vacancyId'],
        applicantId: widget.studentId ?? UserSession.instance.userId!,
        applicantName: widget.studentName ?? UserSession.instance.name ?? 'Student',
        collegeId: widget.collegeId ?? UserSession.instance.collegeId ?? '',
        coverLetter: _coverLetterController.text.trim(),
        documentId: _selectedDocumentId,
      );

      Navigator.pop(context);
      if (widget.onConfirm != null) widget.onConfirm!();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Application submitted successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 25,
        left: 25,
        right: 25,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Text(
              "Apply for ${widget.program['title']}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.program['company'] ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // CV section
            const Text(
              "Select CV",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            _isLoadingCVs
                ? const Center(child: CircularProgressIndicator())
                : _cvDocuments.isEmpty
            // no CVs uploaded yet
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.orange.shade700),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "No CV found. Please upload your CV to apply.",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                    _isUploadingCV ? null : _uploadNewCV,
                    icon: _isUploadingCV
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2),
                    )
                        : const Icon(Icons.upload_file),
                    label: Text(_isUploadingCV
                        ? "Uploading..."
                        : "Upload CV"),
                    style: OutlinedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(
                          color: Color(0xFF284B8C)),
                      foregroundColor: const Color(0xFF284B8C),
                    ),
                  ),
                ),
              ],
            )
            // has CVs — show list to pick from
                : Column(
              children: [
                // CV list
                ..._cvDocuments.map((doc) {
                  final docId = doc['documentid'].toString();
                  final fileName =
                  _extractFileName(doc['filepath'] ?? '');
                  final isSelected = _selectedDocumentId == docId;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedDocumentId = docId;
                      _selectedDocumentName = fileName;
                    }),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF284B8C)
                            .withOpacity(0.08)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF284B8C)
                              : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            color: isSelected
                                ? const Color(0xFF284B8C)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              fileName,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFF284B8C)
                                    : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF284B8C),
                            ),
                        ],
                      ),
                    ),
                  );
                }),

                // upload different CV option
                GestureDetector(
                  onTap: _isUploadingCV ? null : _uploadNewCV,
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isUploadingCV
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        )
                            : const Icon(Icons.upload_file,
                            color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _isUploadingCV
                              ? "Uploading..."
                              : "Upload a different CV",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // cover letter section
            const Text(
              "Cover Letter",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _coverLetterController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                "Tell us why you are a great fit for this position...",
                hintStyle:
                const TextStyle(color: Colors.grey, fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF284B8C)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF637E99),
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitApplication,
                child: _isSubmitting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  "Submit Application",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}