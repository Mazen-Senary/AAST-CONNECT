import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../../services/vacancy_service.dart';

class StudentProfileSubmitHoursModal {
  static void show(
    BuildContext context, {
    required int studentId,
    VoidCallback? onSubmitted,
  }) async {
    // ✅ FIX: Check if training is already completed before showing modal
    try {
      final trainingService = TrainingService();
      final trainingProgress = await trainingService.calculateTrainingProgress(studentId);
      
      final approvedHours = (trainingProgress['approvedHours'] as int?) ?? 0;
      final requiredHours = (trainingProgress['requiredHours'] as int?) ?? 0;
      final progress = requiredHours > 0 ? (approvedHours / requiredHours).clamp(0.0, 1.0) : 0.0;
      
      // If training is 100% completed, show error and return
      if (progress >= 1.0) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: const AwesomeSnackbarContent(
            title: 'Training Complete',
            message: 'You have already completed your required training hours! No more submissions allowed.',
            contentType: ContentType.warning,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    } catch (e) {
      print('Error checking training progress: $e');
      // Continue with normal flow if check fails
    }
    final companyController = TextEditingController();
    final hoursController = TextEditingController();
    final supervisorController = TextEditingController();
    final descriptionController = TextEditingController();
    final proofUrlController = TextEditingController();

    DateTime? startDate;
    DateTime? endDate;
    bool isSubmitting = false;

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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 25,
          left: 25,
          right: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Submit Training Hours",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: companyController,
              decoration: InputDecoration(
                labelText: "Company Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: hoursController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Hours Completed",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: supervisorController,
              decoration: InputDecoration(
                labelText: "Supervisor Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () => pickDate(context, true, setModalState),
                    icon: const Icon(Icons.date_range),
                    label: Text('Start: ${formatDate(startDate)}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () => pickDate(context, false, setModalState),
                    icon: const Icon(Icons.event),
                    label: Text('End: ${formatDate(endDate)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: proofUrlController,
              decoration: InputDecoration(
                labelText: "Proof URL (optional)",
                hintText: "https://...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF284B8C),
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final company = companyController.text.trim();
                        final supervisor = supervisorController.text.trim();
                        final description = descriptionController.text.trim();
                        final proofUrl = proofUrlController.text.trim();
                        final submittedHours = int.tryParse(hoursController.text.trim()) ?? 0;

                        if (company.isEmpty ||
                            supervisor.isEmpty ||
                            description.isEmpty ||
                            submittedHours <= 0 ||
                            startDate == null ||
                            endDate == null ||
                            endDate!.isBefore(startDate!)) {
                          final snackBar = SnackBar(
                            elevation: 0,
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            content: const AwesomeSnackbarContent(
                              title: 'Invalid Data',
                              message: 'Please complete all required fields and check date range.',
                              contentType: ContentType.warning,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                    Navigator.pop(context);
                    final snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: const AwesomeSnackbarContent(
                        title: 'Success',
                        message: 'Training hours submitted successfully!',
                        contentType: ContentType.success,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } catch (e) {
                    setModalState(() => isSubmitting = false);
                    final snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Error',
                        message: 'Error: $e',
                        contentType: ContentType.failure,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: const Text(
                  "Submit Hours",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      ),
    );
  }
}