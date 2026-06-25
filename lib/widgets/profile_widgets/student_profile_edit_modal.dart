import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StudentProfileEditModal extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) onSave;

  const StudentProfileEditModal({
    super.key,
    required this.userData,
    required this.onSave,
  });

  static void show(
    BuildContext context,
    Map<String, dynamic> userData,
    Function(Map<String, dynamic>) onSave,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      builder: (context) => StudentProfileEditModal(
        userData: userData,
        onSave: onSave,
      ),
    );
  }

  @override
  State<StudentProfileEditModal> createState() => _StudentProfileEditModalState();
}

class _StudentProfileEditModalState extends State<StudentProfileEditModal> {
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _addressController;
  late final TextEditingController _linkedinController;

  String? _phoneError;
  String? _linkedinError;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.userData['phone'] ?? '');
    _bioController = TextEditingController(text: widget.userData['bio'] ?? '');
    _addressController = TextEditingController(text: widget.userData['address'] ?? '');
    _linkedinController = TextEditingController(
      text: widget.userData['linkedin_url'] ?? '',
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  String? _validatePhone(String value) {
    if (value.trim().isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Enter a valid phone number';
    return null;
  }

  String? _validateLinkedIn(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed.startsWith('http') ? trimmed : 'https://$trimmed');
    if (uri == null || !uri.hasAbsolutePath || uri.host.isEmpty) {
      return 'Enter a valid URL';
    }
    return null;
  }

  InputDecoration _fieldDecoration(
    BuildContext context,
    String label, {
    String? hintText,
    String? errorText,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      hintText: hintText,
      errorText: errorText,
      filled: true,
      fillColor: isDark ? const Color(0xFF232A33) : Colors.white,
      labelStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.75)),
      hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.45)),
      enabledBorder: border(
        errorText != null
            ? scheme.error
            : scheme.outlineVariant.withValues(alpha: isDark ? 0.85 : 0.6),
      ),
      focusedBorder: border(errorText != null ? scheme.error : scheme.primary, 1.4),
      errorBorder: border(scheme.error),
      focusedErrorBorder: border(scheme.error, 1.4),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
    );
  }

  Widget _buildReadOnlyField(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 5.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF232A33) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(
                fontSize: 14.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.82),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    setState(() {
      _submitted = true;
      _phoneError = _validatePhone(_phoneController.text);
      _linkedinError = _validateLinkedIn(_linkedinController.text);
    });

    if (_phoneError != null || _linkedinError != null) {
      return;
    }

    widget.onSave({
      'phone': _phoneController.text.trim(),
      'bio': _bioController.text.trim(),
      'address': _addressController.text.trim(),
      'linkedin_url': _linkedinController.text.trim(),
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: EdgeInsets.all(25.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Container(
                  height: 70.w,
                  width: 70.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF637E99),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Center(
                    child: Text(
                      widget.userData['name']?.isNotEmpty == true
                          ? widget.userData['name'][0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ID: ${widget.userData['college_id'] ?? ''}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.72),
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.userData['major'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.72),
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 40.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 120.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Academic Information",
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "Managed by the university - cannot be edited",
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.65),
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    _buildReadOnlyField(
                      context,
                      "College ID",
                      widget.userData['college_id'] ?? '',
                    ),
                    _buildReadOnlyField(
                      context,
                      "Major",
                      widget.userData['major'] ?? '',
                    ),
                    _buildReadOnlyField(
                      context,
                      "Academic Year",
                      widget.userData['academicYear'] ?? '',
                    ),
                    _buildReadOnlyField(
                      context,
                      "GPA",
                      widget.userData['gpa'] ?? '',
                    ),
                    SizedBox(height: 25.h),
                    Text(
                      "Personal Information",
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "Required fields are validated after you leave them or try to save",
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.65),
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    _buildReadOnlyField(
                      context,
                      "Full Name",
                      widget.userData['name'] ?? '',
                    ),
                    SizedBox(height: 15.h),
                    Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus || _submitted) {
                          setState(() {
                            _phoneError = _validatePhone(_phoneController.text);
                          });
                        }
                      },
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: scheme.onSurface),
                        onChanged: (_) {
                          if (_phoneError != null || _submitted) {
                            setState(() {
                              _phoneError = _validatePhone(_phoneController.text);
                            });
                          }
                        },
                        decoration: _fieldDecoration(
                          context,
                          'Phone Number',
                          errorText: _phoneError,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    TextField(
                      controller: _addressController,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: _fieldDecoration(
                        context,
                        'Address',
                        hintText: 'Optional',
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus || _submitted) {
                          setState(() {
                            _linkedinError = _validateLinkedIn(
                              _linkedinController.text,
                            );
                          });
                        }
                      },
                      child: TextField(
                        controller: _linkedinController,
                        keyboardType: TextInputType.url,
                        style: TextStyle(color: scheme.onSurface),
                        onChanged: (_) {
                          if (_linkedinError != null || _submitted) {
                            setState(() {
                              _linkedinError = _validateLinkedIn(
                                _linkedinController.text,
                              );
                            });
                          }
                        },
                        decoration: _fieldDecoration(
                          context,
                          'LinkedIn URL',
                          hintText: 'Optional',
                          errorText: _linkedinError,
                        ),
                      ),
                    ),
                    SizedBox(height: 25.h),
                    Text(
                      "Bio",
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: _bioController,
                      maxLines: 4,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: _fieldDecoration(
                        context,
                        'Tell us about yourself',
                        hintText: 'Optional',
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
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
                onPressed: _submit,
                child: Text(
                  "Save Changes",
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
