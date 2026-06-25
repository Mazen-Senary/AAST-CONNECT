import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:aast_connect/providers/CachedChatProvider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/user_session.dart';
import '../../services/vacancy_service.dart';

class StudentProfileSubmitHoursModal {
  static Future<int?> _resolveStudentId() async {
    final session = UserSession.instance;
    if (session.studentId != null) {
      return session.studentId;
    }

    final userId = session.userId;
    if (userId == null) return null;

    final supabase = Supabase.instance.client;

    final byUserId = await supabase
        .from('student')
        .select('studentid')
        .eq('studentid', userId)
        .maybeSingle();
    if (byUserId != null) {
      return byUserId['studentid'] as int?;
    }

    final collegeId = session.collegeId;
    if (collegeId == null || collegeId.isEmpty) return null;

    final byCollegeId = await supabase
        .from('student')
        .select('studentid')
        .eq('college_id', collegeId)
        .maybeSingle();

    return byCollegeId?['studentid'] as int?;
  }

  static Future<int?> _resolveProfileId() async {
    final userId = UserSession.instance.userId;
    if (userId == null) return null;

    final profile = await Supabase.instance.client
        .from('profile')
        .select('profileid')
        .eq('userid', userId)
        .maybeSingle();

    return profile?['profileid'] as int?;
  }

  static String _extractFileName(String filepath) {
    try {
      final uri = Uri.parse(filepath);
      final fullName = uri.pathSegments.last;
      final parts = fullName.split('_');
      if (parts.length > 2) return parts.sublist(2).join('_');
      return fullName;
    } catch (_) {
      return 'Certificate';
    }
  }

  static Future<void> show(
    BuildContext context, {
    required int studentId,
    VoidCallback? onSubmitted,
  }) async {
    final resolvedStudentId = await _resolveStudentId() ?? studentId;
    final resolvedProfileId = await _resolveProfileId();

    try {
      final trainingService = TrainingService();
      final trainingProgress =
          await trainingService.calculateTrainingProgress(resolvedStudentId);
      final approvedHours = (trainingProgress['approvedHours'] as int?) ?? 0;
      final requiredHours = (trainingProgress['requiredHours'] as int?) ?? 0;
      final progress = requiredHours > 0
          ? (approvedHours / requiredHours).clamp(0.0, 1.0)
          : 0.0;

      if (progress >= 1.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: AwesomeSnackbarContent(
              title: 'Training Complete',
              message:
                  'You have already completed your required training hours! No more submissions allowed.',
              contentType: ContentType.warning,
            ),
          ),
        );
        return;
      }
    } catch (e) {
      debugPrint('Error checking training progress: $e');
    }

    final companyController = TextEditingController();
    final hoursController = TextEditingController();
    final supervisorController = TextEditingController();
    final descriptionController = TextEditingController();
    final proofUrlController = TextEditingController();

    DateTime? startDate;
    DateTime? endDate;
    String? selectedCertificateUrl;
    String? selectedCertificateLabel;
    bool isLoadingCertificates = false;
    bool isUploadingCertificate = false;
    bool isSubmitting = false;
    bool certificatesLoaded = false;
    List<Map<String, dynamic>> savedCertificates = [];
    String? companyError;
    String? hoursError;
    String? supervisorError;
    String? descriptionError;
    String? startDateError;
    String? endDateError;

    Future<void> loadSavedCertificates(StateSetter setModalState) async {
      if (resolvedProfileId == null) {
        setModalState(() {
          certificatesLoaded = true;
          isLoadingCertificates = false;
        });
        return;
      }

      try {
        setModalState(() => isLoadingCertificates = true);

        final data = await Supabase.instance.client
            .from('document')
            .select('documentid, filepath, uploaddate')
            .eq('ownerprofileid', resolvedProfileId)
            .eq('documenttype', 'CERTIFICATE')
            .order('uploaddate', ascending: false);

        setModalState(() {
          savedCertificates = List<Map<String, dynamic>>.from(data);
          certificatesLoaded = true;
          isLoadingCertificates = false;
        });
      } catch (e) {
        debugPrint('Error loading certificates: $e');
        setModalState(() {
          certificatesLoaded = true;
          isLoadingCertificates = false;
        });
      }
    }

    Future<void> uploadCertificate(StateSetter setModalState) async {
      try {
        if (resolvedProfileId == null) {
          throw Exception('No profile found for this account.');
        }

        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'webp'],
          withData: true,
        );
        if (result == null) return;

        final file = result.files.first;
        final bytes = file.bytes;
        if (bytes == null) {
          throw Exception('Unable to read the selected file.');
        }

        setModalState(() => isUploadingCertificate = true);

        final safeName =
            file.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
        final storagePath =
            'student_$resolvedProfileId/${resolvedProfileId}_${DateTime.now().millisecondsSinceEpoch}_$safeName';
        final supabase = Supabase.instance.client;

        await supabase.storage.from('documents').uploadBinary(storagePath, bytes);
        final uploadedUrl =
            supabase.storage.from('documents').getPublicUrl(storagePath);

        await supabase.from('document').insert({
          'ownerprofileid': resolvedProfileId,
          'documenttype': 'CERTIFICATE',
          'filepath': uploadedUrl,
        });

        await loadSavedCertificates(setModalState);
        setModalState(() {
          selectedCertificateUrl = uploadedUrl;
          selectedCertificateLabel = file.name;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: AwesomeSnackbarContent(
              title: 'Error',
              message: 'Could not upload certificate: $e',
              contentType: ContentType.failure,
            ),
          ),
        );
      } finally {
        setModalState(() => isUploadingCertificate = false);
      }
    }

    Future<void> pickDate(
      BuildContext ctx,
      bool isStart,
      StateSetter setModalState,
    ) async {
      final initialDate = isStart
          ? (startDate ?? DateTime.now())
          : (endDate ?? startDate ?? DateTime.now());

      final pickedDate = await showDatePicker(
        context: ctx,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );

      if (pickedDate != null) {
        setModalState(() {
          if (isStart) {
            startDate = pickedDate;
            if (endDate != null && endDate!.isBefore(pickedDate)) {
              endDate = null;
            }
          } else {
            endDate = pickedDate;
          }
        });
      }
    }

    String formatDate(DateTime? date) {
      if (date == null) return 'Select date';
      return '${date.day}/${date.month}/${date.year}';
    }

    InputDecoration fieldDecoration(
      BuildContext context,
      String label, {
      String? errorText,
    }) {
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;
      final isDark = theme.brightness == Brightness.dark;

      return InputDecoration(
        labelText: label,
        errorText: errorText,
        filled: true,
        fillColor: isDark ? const Color(0xFF232A33) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: errorText != null
                ? scheme.error
                : scheme.outlineVariant.withValues(alpha: isDark ? 0.85 : 0.55),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: errorText != null ? scheme.error : scheme.primary,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
      );
    }

    ButtonStyle dateButtonStyle(BuildContext context, bool hasError) {
      final scheme = Theme.of(context).colorScheme;
      return OutlinedButton.styleFrom(
        side: BorderSide(
          color: hasError
              ? scheme.error
              : scheme.outlineVariant.withValues(alpha: 0.75),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        foregroundColor: scheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      );
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (!certificatesLoaded && !isLoadingCertificates) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  loadSavedCertificates(setModalState);
                }
              });
            }

            return AnimatedPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: FractionallySizedBox(
                heightFactor: 0.92,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(25.w, 25.h, 25.w, 30.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submit Training Hours',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus &&
                              companyController.text.trim().isEmpty) {
                            setModalState(
                              () => companyError = 'Company name is required',
                            );
                          }
                        },
                        child: TextField(
                          controller: companyController,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onChanged: (_) =>
                              setModalState(() => companyError = null),
                          decoration: fieldDecoration(
                            context,
                            'Company Name',
                            errorText: companyError,
                          ),
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus) {
                            final parsed =
                                int.tryParse(hoursController.text.trim()) ?? 0;
                            if (parsed <= 0) {
                              setModalState(
                                () => hoursError =
                                    'Enter a valid number greater than 0',
                              );
                            }
                          }
                        },
                        child: TextField(
                          controller: hoursController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onChanged: (_) =>
                              setModalState(() => hoursError = null),
                          decoration: fieldDecoration(
                            context,
                            'Hours Completed',
                            errorText: hoursError,
                          ),
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus &&
                              supervisorController.text.trim().isEmpty) {
                            setModalState(
                              () => supervisorError =
                                  'Supervisor name is required',
                            );
                          }
                        },
                        child: TextField(
                          controller: supervisorController,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onChanged: (_) =>
                              setModalState(() => supervisorError = null),
                          decoration: fieldDecoration(
                            context,
                            'Supervisor Name',
                            errorText: supervisorError,
                          ),
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isSubmitting
                                  ? null
                                  : () => pickDate(
                                        context,
                                        true,
                                        setModalState,
                                      ),
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                startDate == null
                                    ? 'Start Date'
                                    : 'Start: ${formatDate(startDate)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: dateButtonStyle(
                                context,
                                startDateError != null,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isSubmitting
                                  ? null
                                  : () => pickDate(
                                        context,
                                        false,
                                        setModalState,
                                      ),
                              icon: const Icon(Icons.event),
                              label: Text(
                                endDate == null
                                    ? 'End Date'
                                    : 'End: ${formatDate(endDate)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: dateButtonStyle(
                                context,
                                endDateError != null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (startDateError != null) ...[
                        SizedBox(height: 6.h),
                        Text(
                          startDateError!,
                          style: TextStyle(color: Colors.red, fontSize: 12.sp),
                        ),
                      ],
                      if (endDateError != null) ...[
                        SizedBox(height: 6.h),
                        Text(
                          endDateError!,
                          style: TextStyle(color: Colors.red, fontSize: 12.sp),
                        ),
                      ],
                      SizedBox(height: 15.h),
                      Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus &&
                              descriptionController.text.trim().isEmpty) {
                            setModalState(
                              () =>
                                  descriptionError = 'Description is required',
                            );
                          }
                        },
                        child: TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onChanged: (_) =>
                              setModalState(() => descriptionError = null),
                          decoration: fieldDecoration(
                            context,
                            'Description',
                            errorText: descriptionError,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      TextField(
                        controller: proofUrlController,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Proof URL (optional)',
                          hintText: 'https://...',
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF232A33)
                                  : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.55),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'Upload Certificate',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      if (selectedCertificateUrl != null)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 16.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF1E2B45)
                                    : const Color(0xFFF3F6FB),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: const Color(0xFF284B8C),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf,
                                color: Color(0xFF284B8C),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  selectedCertificateLabel ??
                                      'Certificate selected',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF284B8C),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF284B8C),
                              ),
                            ],
                          ),
                        )
                      else if (isLoadingCertificates)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (savedCertificates.isNotEmpty)
                        Column(
                          children: savedCertificates.map((row) {
                            final url = row['filepath']?.toString() ?? '';
                            final filename = _extractFileName(url);
                            final isSelected = selectedCertificateUrl == url;

                            return Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16.r),
                                onTap: () {
                                  setModalState(() {
                                    selectedCertificateUrl = url;
                                    selectedCertificateLabel = filename;
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 18.w,
                                    vertical: 16.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF1F2430)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF284B8C)
                                          : Theme.of(context)
                                              .colorScheme
                                              .outlineVariant
                                              .withValues(alpha: 0.5),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.picture_as_pdf,
                                        color: Color(0xFF284B8C),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Text(
                                          filename,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        isSelected
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: const Color(0xFF284B8C),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF232A33)
                                    : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Theme.of(context)
                                          .colorScheme
                                          .outlineVariant
                                      : Colors.orange.shade200,
                            ),
                          ),
                          child: Text(
                            'No saved certificates found. Upload one below.',
                            style: TextStyle(fontSize: 13.sp),
                          ),
                        ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isUploadingCertificate
                              ? null
                              : () => uploadCertificate(setModalState),
                          icon: isUploadingCertificate
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.upload_file),
                          label: Text(
                            isUploadingCertificate
                                ? 'Uploading...'
                                : savedCertificates.isEmpty
                                    ? 'Upload Certificate'
                                    : 'Upload a Different Certificate',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            side: const BorderSide(
                              color: Color(0xFF284B8C),
                            ),
                            foregroundColor: const Color(0xFF284B8C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF284B8C),
                            padding: EdgeInsets.all(15.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final company = companyController.text.trim();
                                  final supervisor =
                                      supervisorController.text.trim();
                                  final description =
                                      descriptionController.text.trim();
                                  final proofUrl =
                                      proofUrlController.text.trim();
                                  final submittedHours =
                                      int.tryParse(hoursController.text.trim()) ??
                                          0;

                                  final hasCompanyError = company.isEmpty;
                                  final hasHoursError = submittedHours <= 0;
                                  final hasSupervisorError =
                                      supervisor.isEmpty;
                                  final hasDescriptionError =
                                      description.isEmpty;
                                  final hasStartDateError = startDate == null;
                                  final hasEndDateError = endDate == null ||
                                      (startDate != null &&
                                          endDate!.isBefore(startDate!));

                                  setModalState(() {
                                    companyError = hasCompanyError
                                        ? 'Company name is required'
                                        : null;
                                    hoursError = hasHoursError
                                        ? 'Enter a valid number greater than 0'
                                        : null;
                                    supervisorError = hasSupervisorError
                                        ? 'Supervisor name is required'
                                        : null;
                                    descriptionError = hasDescriptionError
                                        ? 'Description is required'
                                        : null;
                                    startDateError = hasStartDateError
                                        ? 'Start date is required'
                                        : null;
                                    endDateError = hasEndDateError
                                        ? (endDate == null
                                            ? 'End date is required'
                                            : 'End date must be after start date')
                                        : null;
                                  });

                                  if (hasCompanyError ||
                                      hasHoursError ||
                                      hasSupervisorError ||
                                      hasDescriptionError ||
                                      hasStartDateError ||
                                      hasEndDateError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        content: AwesomeSnackbarContent(
                                          title: 'Missing Information',
                                          message:
                                              'Please fill in all required fields.',
                                          contentType: ContentType.warning,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setModalState(() => isSubmitting = true);
                                  try {
                                    final studentRecordId = resolvedStudentId;
                                    if (studentRecordId == null) {
                                      throw Exception(
                                        'No linked student record found for this account.',
                                      );
                                    }

                                    await Supabase.instance.client
                                        .from('trainingrecord')
                                        .insert({
                                      'studentid': studentRecordId,
                                      'companyname': company,
                                      'hourssubmitted': submittedHours,
                                      'supervisorname': supervisor,
                                      'startdate': startDate!
                                          .toIso8601String()
                                          .split('T')
                                          .first,
                                      'enddate': endDate!
                                          .toIso8601String()
                                          .split('T')
                                          .first,
                                      'name': description,
                                      'status': 'PENDING',
                                      'proof_image_url':
                                          proofUrl.isEmpty ? null : proofUrl,
                                      'certificate_url':
                                          selectedCertificateUrl,
                                    });

                                    onSubmitted?.call();
                                    if (context.mounted) Navigator.pop(context);
                                    Provider.of<CachedChatProvider>(
                                      context,
                                      listen: false,
                                    ).invalidateCache();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        content: AwesomeSnackbarContent(
                                          title: 'Success',
                                          message:
                                              'Training hours submitted successfully!',
                                          contentType: ContentType.success,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        content: AwesomeSnackbarContent(
                                          title: 'Error',
                                          message: 'Error: $e',
                                          contentType: ContentType.failure,
                                        ),
                                      ),
                                    );
                                  }
                                },
                          child: Text(
                            'Submit Hours',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
