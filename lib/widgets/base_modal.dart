import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseModal extends StatelessWidget {
  final String title;
  final Widget child;
  final double? heightFactor;
  final List<Widget>? actions;

  const BaseModal({
    super.key,
    required this.title,
    required this.child,
    this.heightFactor = 0.9,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * heightFactor!,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: Column(
        children: [
          // Fixed Header
          Padding(
            padding: EdgeInsets.all(25.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Row(
                  children: [
                    if (actions != null) ...actions!,
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  static void show({
    required BuildContext context,
    required String title,
    required Widget child,
    double? heightFactor,
    List<Widget>? actions,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => BaseModal(
        title: title,
        heightFactor: heightFactor,
        actions: actions,
        child: child,
      ),
    );
  }
}
