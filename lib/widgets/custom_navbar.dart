// import 'package:flutter/material.dart';
// import '../constants/app_colors.dart';
//
// class CustomNavItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const CustomNavItem({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 250),
//           margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? AppColors.navSelectedBackground
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 icon,
//                 size: 24,
//                 color: isSelected
//                     ? AppColors.navSelectedIcon
//                     : AppColors.navUnselectedIcon,
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: isSelected
//                       ? AppColors.navSelectedIcon
//                       : AppColors.navUnselectedIcon,
//                   fontSize: 12,
//                   fontWeight:
//                   isSelected ? FontWeight.w600 : FontWeight.w400,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class CustomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the current theme is dark
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine colors dynamically based on the dark mode state
    final selectedBgColor = isDark
        ? Colors.blueGrey.withOpacity(0.3) // Tailor this to your preferred dark accent background
        : AppColors.navSelectedBackground;

    final selectedIconColor = isDark
        ? AppColors.darkPrimary
        : AppColors.navSelectedIcon;

    final unselectedIconColor = isDark
        ? Colors.grey.shade500
        : AppColors.navUnselectedIcon;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedBgColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24.sp,
                color: isSelected ? selectedIconColor : unselectedIconColor,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? selectedIconColor : unselectedIconColor,
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
