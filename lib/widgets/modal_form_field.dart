import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'rounded_container.dart';

class ModalFormField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final int? maxLines;
  final bool isDark;
  final TextInputType? keyboardType;

  const ModalFormField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.maxLines = 1,
    this.isDark = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15.h),
        ],
        RoundedContainer(
          backgroundColor: isDark
              ? const Color(0xFF2C2C2C)
              : Colors.grey.shade50,
          borderColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: 15.0,
          padding: EdgeInsets.all(15.w),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey,
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }
}

class ModalDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?>? onChanged;
  final bool isDark;

  const ModalDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    this.onChanged,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15.h),
        RoundedContainer(
          backgroundColor: isDark ? const Color(0xFF3C3C3C) : Colors.white,
          borderColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          borderRadius: 8.0,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            isExpanded: true,
            underline: const SizedBox(),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
