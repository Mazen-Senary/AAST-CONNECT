import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.card,
      dividerColor: AppColors.divider,
      primaryColor: AppColors.interactive,

      textTheme: const TextTheme(
        titleLarge: AppTextStyles.h1,
        titleMedium: AppTextStyles.h2,
        titleSmall: AppTextStyles.h3,
        bodyMedium: AppTextStyles.body,
        labelMedium: AppTextStyles.label,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.interactive,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radius),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkCard,
      dividerColor: AppColors.darkDivider,
      primaryColor: AppColors.darkInteractive,
    );
  }
}
