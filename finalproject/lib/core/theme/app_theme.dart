import 'package:flutter/material.dart';
import 'package:finalproject/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Pattanakarn',
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        background: AppColors.lightBackground,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Pattanakarn',
          fontWeight: FontWeight.bold,
          fontSize: 48,
          color: AppColors.lightMainText,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Pattanakarn',
          fontWeight: FontWeight.bold,
          fontSize: 24.2,
          color: AppColors.lightMainText,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Pattanakarn',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.lightMainText,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Pattanakarn',
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.lightMainText,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Open Sans',
          fontSize: 14,
          color: AppColors.lightBodyText,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Open Sans',
          fontSize: 12,
          color: AppColors.lightBodyText,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.primary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: AppColors.primary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.lightDivider, width: 1),
        ),
        margin: EdgeInsets.all(24),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightDivider),
        ),
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        errorStyle: TextStyle(color: AppColors.error),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: TextStyle(
            fontFamily: 'Pattanakarn',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      iconTheme: IconThemeData(color: AppColors.primary, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightAppBarBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          fontFamily: 'Pattanakarn',
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: AppColors.lightMainText,
        ),
      ),
    );
  }
}
