import 'package:flutter/material.dart';

class AppColors {
  static const Color primary100 = Color(0xFFF1525E);
  static const Color primary200 = Color(0xFFEF3C4B);
  static const Color primary300 = Color(0xFFEE2737);
  static const Color primary400 = Color(0xFFD62331);
  static const Color primary500 = Color(0xFFBE1F2C);

  static const Color secondary100 = Color(0xFFFFFFFF);
  static const Color secondary200 = Color(0xFFEEEEEE);
  static const Color secondary300 = Color(0xFF929292);
  static const Color secondary400 = Color(0xFF3D3D3D);
  static const Color secondary500 = Color(0xFF262626);
  static const Color secondary600 = Color(0xFF161616);
  static const Color secondary700 = Color(0xFF424242);
  static const Color secondary800 = Color(0xFF929292);
  static const Color secondary900 = Color(0xFFD9D9D9);

  static const Color green300 = Color(0xFF5AC152);
  static const Color orange300 = Color(0xFFF76E34);
  static const Color purple300 = Color(0xFF9747FF);
  static const Color info300 = Color(0xFF276BEE);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Pattanakarn',
      scaffoldBackgroundColor: AppColors.secondary100,
      primaryColor: AppColors.primary300,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary300,
        secondary: AppColors.secondary300,
        background: AppColors.secondary100,
        error: AppColors.orange300,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Pattanakarn',
          fontWeight: FontWeight.bold,
          fontSize: 48,
          color: AppColors.secondary400,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Pattanakarn',
          fontWeight: FontWeight.bold,
          fontSize: 24.2,
          color: AppColors.secondary400,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Pattanakarn',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.secondary400,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Pattanakarn',
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.secondary400,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Open Sans',
          fontSize: 14,
          color: AppColors.secondary400,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Open Sans',
          fontSize: 12,
          color: AppColors.secondary300,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.primary300,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: AppColors.primary300,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.secondary100,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.secondary200, width: 1),
        ),
        margin: EdgeInsets.all(24),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.secondary200),
        ),
        filled: true,
        fillColor: AppColors.secondary100,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        errorStyle: TextStyle(color: AppColors.orange300),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary300,
          foregroundColor: AppColors.secondary100,
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
      iconTheme: IconThemeData(color: AppColors.primary300, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.secondary100,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary300),
        titleTextStyle: TextStyle(
          fontFamily: 'Pattanakarn',
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: AppColors.secondary400,
        ),
      ),
    );
  }
}
