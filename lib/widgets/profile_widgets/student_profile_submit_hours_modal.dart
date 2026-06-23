import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:aast_connect/providers/CachedChatProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/vacancy_service.dart';

class StudentProfileSubmitHoursModal {
  static Future<void> show(
    BuildContext context, {
    required int studentId,
    VoidCallback? onSubmitted,
  }) async {
    try {
      final trainingService = TrainingService();
      final trainingProgress = await trainingService.calculateTrainingProgress(studentId);
      final approvedHours = (trainingProgress['approvedHours'] as int?) ?? 0;
      final requiredHours = (trainingProgress['requiredHours'] as int?) ?? 0;
      final progress = requiredHours > 0 ? (approvedHours / requiredHours).clamp(0.0, 1.0) : 0.0;
      if (progress >= 1.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: AwesomeSnackbarContent(
              title: 'Training Complete',
              message: 'You have already completed your required training hours! No more submissions allowed.',
              contentType: ContentType.warning,
            ),
          ),
        );
        return;
      }
    } catch (e) {
      print('Error checking training progress: $e');
    }

    final companyController = TextEditingController();
    final hoursController = TextEditingController();
    final supervisorController = TextEditingController();
    final descriptionController = TextEditingController();
    final proofUrlController = TextEditingController();

    DateTime? startDate;
    DateTime? endDate;
    bool isSubmitting = false;
    String? companyError;
    String? hoursError;
    String? supervisorError;
    String? descriptionError;
    String? startDateError;
    String? endDateError;

    Future<void> pickDate(BuildContext ctx, bool isStart, StateSetter setModalState) async {
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
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;
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
            return AnimatedPadding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20.h),
                      Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus && companyController.text.trim().isEmpty) {
                            setModalState(() => companyError = 'Company name is required');
                          }
                        },
                        child: TextField(
                          controller: companyController,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          onChanged: (_) => setModalState(() => companyError = null),
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
                            final parsed = int.tryParse(hoursController.text.trim()) ?? 0;
                            if (parsed <= 0) {
                              setModalState(() => hoursError = 'Enter a valid number greater than 0');
                            }
                          }
                        },
                        child: TextField(
                          controller: hoursController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          onChanged: (_) => setModalState(() => hoursError = null),
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
                          if (!hasFocus && supervisorController.text.trim().isEmpty) {
                            setModalState(() => supervisorError = 'Supervisor name is required');
                          }
                        },
                        child: TextField(
                          controller: supervisorController,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          onChanged: (_) => setModalState(() => supervisorError = null),
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
                              onPressed: isSubmitting ? null : () => pickDate(context, true, setModalState),
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                startDate == null ? 'Start Date' : 'Start: ${formatDate(startDate)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: dateButtonStyle(context, startDateError != null),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isSubmitting ? null : () => pickDate(context, false, setModalState),
                              icon: const Icon(Icons.event),
                              label: Text(
                                endDate == null ? 'End Date' : 'End: ${formatDate(endDate)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: dateButtonStyle(context, endDateError != null),
                            ),
                          ),
                        ],
                      ),
                      if (startDateError != null) ...[
                        SizedBox(height: 6.h),
                        Text(startDateError!, style: TextStyle(color: Colors.red, fontSize: 12.sp)),
                      ],
                      if (endDateError != null) ...[
                        SizedBox(height: 6.h),
                        Text(endDateError!, style: TextStyle(color: Colors.red, fontSize: 12.sp)),
                      ],
                      SizedBox(height: 15.h),
                      Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus && descriptionController.text.trim().isEmpty) {
                            setModalState(() => descriptionError = 'Description is required');
                          }
                        },
                        child: TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          onChanged: (_) => setModalState(() => descriptionError = null),
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
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Proof URL (optional)',
                          hintText: 'https://...',
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark
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
                                  final supervisor = supervisorController.text.trim();
                                  final description = descriptionController.text.trim();
                                  final proofUrl = proofUrlController.text.trim();
                                  final submittedHours =
                                      int.tryParse(hoursController.text.trim()) ?? 0;

                                  final hasCompanyError = company.isEmpty;
                                  final hasHoursError = submittedHours <= 0;
                                  final hasSupervisorError = supervisor.isEmpty;
                                  final hasDescriptionError = description.isEmpty;
                                  final hasStartDateError = startDate == null;
                                  final hasEndDateError =
                                      endDate == null || (startDate != null && endDate!.isBefore(startDate!));

                                  setModalState(() {
                                    companyError = hasCompanyError ? 'Company name is required' : null;
                                    hoursError = hasHoursError ? 'Enter a valid number greater than 0' : null;
                                    supervisorError = hasSupervisorError ? 'Supervisor name is required' : null;
                                    descriptionError = hasDescriptionError ? 'Description is required' : null;
                                    startDateError = hasStartDateError ? 'Start date is required' : null;
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
                                          message: 'Please fill in all required fields.',
                                          contentType: ContentType.warning,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setModalState(() => isSubmitting = true);
                                  try {
                                    final supabase = Supabase.instance.client;
                                    await supabase.from('trainingrecord').insert({
                                      'studentid': studentId,
                                      'companyname': company,
                                      'hourssubmitted': submittedHours,
                                      'supervisorname': supervisor,
                                      'startdate': startDate!.toIso8601String().split('T').first,
                                      'enddate': endDate!.toIso8601String().split('T').first,
                                      'name': description,
                                      'status': 'PENDING',
                                      'proof_image_url': proofUrl.isEmpty ? null : proofUrl,
                                    });

                                    onSubmitted?.call();
                                    if (context.mounted) Navigator.pop(context);
                                    Provider.of<CachedChatProvider>(context, listen: false).invalidateCache();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        content: AwesomeSnackbarContent(
                                          title: 'Success',
                                          message: 'Training hours submitted successfully!',
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
                            style: TextStyle(color: Colors.white, fontSize: 15.sp),
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
