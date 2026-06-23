import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileInfoField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoField({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: Colors.grey),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
            ),
            Text(value, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp)),
          ],
        ),
      ],
    );
  }
}
