import 'package:flutter/material.dart';

class AppColors {

  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color lightOrange = Color(0xFFFFF3E0);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color scaffoldBg = Color(0xFFF5F5F5);
  static const Color applyButton = Color(0xFF37474F);

  // Dark mode
  static const Color darkScaffoldBg = Color(0xFF121212);
  static const Color darkCardBg = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF2A2A2A);
  static const Color darkGreen = Color(0xFF1B3A1F);
  static const Color darkBlue = Color(0xFF0D2137);
  static const Color darkOrange = Color(0xFF2D1F0A);

  // 🌐 Backgrounds
  static const Color background = Color(0xFFFAF9F6);
  static const Color foreground = Color(0xFF2D2D2D);

  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkForeground = Color(0xFFF5F5F5);

  // 🧱 Cards
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF2D2D2D);

  static const Color darkCard = Color(0xFF242424);
  static const Color darkCardForeground = Color(0xFFF5F5F5);

  // 🎯 Accents
  static const Color accentProgress = Color(0xFFFFE8CC);
  static const Color accentProgressText = Color(0xFF8B6914);

  static const Color accentAlert = Color(0xFFFFD7D7);
  static const Color accentAlertText = Color(0xFF8B3A3A);

  static const Color accentSuccess = Color(0xFFD4E8D4);
  static const Color accentSuccessText = Color(0xFF2D5F2D);

  static const Color accentInfo = Color(0xFFD4E4F7);
  static const Color accentInfoText = Color(0xFF2D4F7C);

  // 🌙 Dark accents
  static const Color darkAccentProgress = Color(0xFF3D3420);
  static const Color darkAccentAlert = Color(0xFF3D2020);
  static const Color darkAccentSuccess = Color(0xFF203D20);
  static const Color darkAccentInfo = Color(0xFF202D3D);

  // 🖋️ Text hierarchy
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textMuted = Color(0xFF9B9B9B);

  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextMuted = Color(0xFF808080);

  // 📐 Borders & dividers
  static const Color border = Color(0xFFE8E8E8);
  static const Color divider = Color(0xFFF0F0F0);

  static const Color darkBorder = Color(0xFF333333);
  static const Color darkDivider = Color(0xFF2A2A2A);

  // 🖱️ Interactive
  static const Color interactive = Color(0xFF5B7C99);
  static const Color interactiveHover = Color(0xFF4A6780);

  static const Color darkInteractive = Color(0xFF7A9BB8);
  static const Color darkInteractiveHover = Color(0xFF8BAEC9);

  //navabr colors
  static const Color navSelectedBackground = Color(0xFFD6EAF2);
  static const Color navSelectedIcon = Color(0xFF057C99);
  static const Color navUnselectedIcon = Color(0xFF9E9E9E);

  // 📏 Radius
  static const double radius = 14.0;

  static const Color caption = Color(0xFF6A7282);
  // 🔍 Inputs / Search
  static const Color inputBackground = Color(0xFFFFFFFF); // #FFFFFF
  static const Color inputBorder = Color(0xFFE5E7EB);     // #E5E7EB
  static const Color inputHint = Color(0xFF99A1AF); // #99A1AF


}

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.02,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.01,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12, // line-height / font-size
    letterSpacing: 0,
    color: AppColors.caption,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
}

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
